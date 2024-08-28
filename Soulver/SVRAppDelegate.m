#import "SVRAppDelegate.h"
#import "SVRDocumentWindowController.h"
#import "SVRMathString+Tests.h"

@implementation SVRAppDelegate

// MARK: Properties
-(NSMutableDictionary*)openFiles;
{
  return _openFiles;
}
-(NSMutableDictionary*)openUnsaved;
{
  return _openUnsaved;
}

// MARK: Document Management

- (void)newDoc:(id)sender
{
  SVRDocumentWindowController *controller;
  NSWindow *window;
  NSNumber *windowNumber;

  controller = [SVRDocumentWindowController controllerWithFilename:nil];
  window = [controller window];
  windowNumber = [NSNumber numberWithLong:[window windowNumber]];
  
  [[self openUnsaved] setObject:controller forKey:windowNumber];
  [window makeKeyAndOrderFront:sender];
}

- (void)openDoc:(id)sender
{
  NSOpenPanel *panel;
  NSString *file;
  SVRDocumentWindowController *controller;

  panel = [NSOpenPanel openPanel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [panel setRequiredFileType:@"solv"];
  [panel runModal];
  file = [panel filename];
#pragma clang diagnostic pop
  if (!file) { NSLog(@"Open Cancelled"); return; }
  controller = [[self openFiles] objectForKey:file];
  if (!controller) {
    controller = [SVRDocumentWindowController controllerWithFilename:file];
    [[self openFiles] setObject:controller forKey:file];
  }

  [[controller window] makeKeyAndOrderFront:sender];
}

- (void)saveDoc:(id)sender
{
  NSWindow *window;
  NSNumber *windowNumber;
  SVRDocumentWindowController *documentLHS;
  SVRDocumentWindowController *documentRHS;
  BOOL result;

  window = [[NSApplication sharedApplication] mainWindow];
  windowNumber = [NSNumber numberWithLong:[window windowNumber]];
  documentLHS = [window delegate];
  if ([documentLHS isKindOfClass:[SVRDocumentWindowController class]]) {
    result = [documentLHS saveDocument];
  } else {
    result = NO;
  }
  NSLog(@"Document Save Successful: %d", result);
  if (result) {
    documentRHS = [[self openUnsaved] objectForKey:windowNumber];
    if (documentRHS) {
      NSAssert(documentLHS == documentRHS, @"Open Document Management Error");
      NSAssert([documentRHS filename], @"Open Document Management Error");
      [[self openFiles] setObject:documentRHS forKey: [documentRHS filename]];
      [[self openUnsaved] removeObjectForKey:windowNumber];
      NSLog(@"Confirmed: Moved document from openUnsaved to openFiles");
    } else {
      documentRHS = [[self openFiles] objectForKey:[documentLHS filename]];
      NSAssert(documentLHS == documentRHS, @"Open Document Management Error");
      NSAssert([documentRHS filename], @"Open Document Management Error");
      NSLog(@"Confirmed: Document in saveFiles dictionary");
    }
  }
}

// MARK: Notifications
-(void)closeDoc:(NSNotification*)aNotification;
{
  NSNumber *windowNumber;
  NSString *filename;
  NSDictionary *userInfo = [aNotification userInfo];
  windowNumber = [userInfo objectForKey:@"windowNumber"];
  filename = [userInfo objectForKey:@"filename"];

  if (filename) {
    [[self openFiles] removeObjectForKey:filename];
  }
  if (windowNumber != nil) {
    [[self openUnsaved] removeObjectForKey:windowNumber];
  }
  
  NSLog(@"Closed Windows: %@", userInfo);
}

-(void)awakeFromNib;
{  
  // Execute Tests
  [SVRMathString executeTests];

  // Announce 
  NSLog(@"%@", self);
  
  // Initialize Properties
  _openFiles = [NSMutableDictionary new];
  _openUnsaved = [NSMutableDictionary new];
  
  // Register for Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(closeDoc:)
                                               name:[SVRDocumentWindowController windowDidCloseNotification]
                                             object:nil];
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_openFiles release];
  [_openUnsaved release];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end


@implementation SVRAppDelegate (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
{
  NSEnumerator *e1;
  NSEnumerator *e2;
  SVRDocumentWindowController *value;
  long alertResult;
  BOOL result = YES;

  e1 = [[self openUnsaved] objectEnumerator];
  e2 = [[self openFiles] objectEnumerator];
  value = [e1 nextObject];
  while (value && result) {
    result = ![[value window] isDocumentEdited];
    value = [e1 nextObject] ? [e1 nextObject] : [e2 nextObject];
  }

  if (!result) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    alertResult = NSRunAlertPanel(@"Quit Application",
                                  @"There are documents with unsaved changes.",
                                  @"Review Unsaved Changes", @"Quit Anyway",
                                  nil);
#pragma clang diagnostic pop
    switch (alertResult) {
      case 1: // Review Unsaved
        result = NO;
        break;
      default: // Quit Immediately
        result = YES;
        break;
    }
  }
  return result;
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
{
  SVRDocumentWindowController *controller;
  controller = [[self openFiles] objectForKey:filename];
  if (!controller) {
    controller = [SVRDocumentWindowController controllerWithFilename:filename];
    [[self openFiles] setObject:controller forKey:filename];
  }
  [[controller window] makeKeyAndOrderFront:sender];
  return YES;
}

-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
{
  [self newDoc:sender];
  return YES;
}
@end
