#import "SVRAppDelegate.h"
#import "SVRDocumentController.h"
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
  SVRDocumentController *controller;
  NSWindow *window;
  NSNumber *windowNumber;

  controller = [SVRDocumentController controllerWithFilename:nil];
  window = [controller window];
  windowNumber = [NSNumber numberWithInt:[window windowNumber]];
  
  [[self openUnsaved] setObject:controller forKey:windowNumber];
  [window makeKeyAndOrderFront:sender];
}

- (void)openDoc:(id)sender
{
  NSOpenPanel *panel;
  NSString *file;
  SVRDocumentController *controller;

  panel = [NSOpenPanel openPanel];
  [panel setRequiredFileType:@"solv"];
  [panel runModal];
  file = [panel filename];
  if (!file) { NSLog(@"Open Cancelled"); return; }
  controller = [[self openFiles] objectForKey:file];
  if (!controller) {
    controller = [SVRDocumentController controllerWithFilename:file];
    [[self openFiles] setObject:controller forKey:file];
  }

  [[controller window] makeKeyAndOrderFront:sender];
}

- (void)saveDoc:(id)sender
{
  NSWindow *window;
  NSNumber *windowNumber;
  SVRDocumentController *documentLHS;
  SVRDocumentController *documentRHS;
  BOOL result;

  window = [[NSApplication sharedApplication] mainWindow];
  windowNumber = [NSNumber numberWithInt:[window windowNumber]];
  documentLHS = [window delegate];
  if ([documentLHS isKindOfClass:[SVRDocumentController class]]) {
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
                                               name:[SVRDocumentController windowDidCloseNotification]
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
  SVRDocumentController *value;
  int alertResult;
  BOOL result = YES;

  e1 = [[self openUnsaved] objectEnumerator];
  e2 = [[self openFiles] objectEnumerator];
  value = [e1 nextObject];
  while (value && result) {
    result = ![[value window] isDocumentEdited];
    value = [e1 nextObject] ? [e1 nextObject] : [e2 nextObject];
  }

  if (!result) {
    alertResult = NSRunAlertPanel(@"Quit Application",
                                  @"There are documents with unsaved changes.",
                                  @"Review Unsaved Changes", @"Quit Anyway",
                                  nil);
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
  SVRDocumentController *controller;
  controller = [[self openFiles] objectForKey:filename];
  if (!controller) {
    controller = [SVRDocumentController controllerWithFilename:filename];
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
