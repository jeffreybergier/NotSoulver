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

-(void)newDoc:(id)sender
{
  SVRDocumentWindowController *controller;
  NSWindow *window;
  NSNumber *windowNumber;

  controller = [SVRDocumentWindowController controllerWithFilename:nil];
  window = [controller window];
  windowNumber = [NSNumber XP_numberWithInteger:[window windowNumber]];
  
  [[self openUnsaved] setObject:controller forKey:windowNumber];
  [window makeKeyAndOrderFront:sender];
}

-(void)openDoc:(id)sender
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

-(void)saveAll:(id)sender;
{
  NSLog(@"%@ saveAll: %@", self, sender);
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  SVRDocumentWindowController *controller = nil;
  NSWindow *window = [aNotification object];
  
  NSAssert2([window isKindOfClass:[NSWindow class]],
           @"%@ __windowWillCloseNotification: %@", self, aNotification);
  
  controller = (SVRDocumentWindowController*)[window delegate];
  
  NSAssert2([controller isKindOfClass:[SVRDocumentWindowController class]],
           @"%@ __windowWillCloseNotification: %@", self, aNotification);
  
  [self __documentWillClose:controller];
}

-(void)__documentDidChangeFilenameNotification:(NSNotification*)aNotification;
{
  id _oldFilename = [[aNotification userInfo] objectForKey:@"oldFilename"];
  NSString *oldFilename = ([_oldFilename isKindOfClass:[NSString class]]) ? _oldFilename : nil;
  SVRDocumentWindowController *controller = [aNotification object];
  
  NSAssert2([controller isKindOfClass:[SVRDocumentWindowController class]],
           @"%@ __windowWillCloseNotification: %@", self, aNotification);
  
  [self   __document:controller
didChangeOldFilename:oldFilename];
}

-(void)__documentWillClose:(SVRDocumentWindowController*)document;
{
  XPUInteger windowNumber = [[document window] windowNumber];
  NSString *filename = [document filename];
  
  // Not strictly necessary
  // But might help the NSWindow closing process settle more gracefully
  [document retain];
  
  [[self openUnsaved] removeObjectForKey:[NSNumber XP_numberWithInteger:windowNumber]];
  if (filename) {
    [[self openFiles] removeObjectForKey:filename];
  }
  
  NSLog(@"%@ __documentWillClose: removedWindowNumber: %lu removedFile: %@", self, windowNumber, filename);
  
  [document autorelease];
}

-(void)   __document:(SVRDocumentWindowController*)document
didChangeOldFilename:(NSString*)oldFilename;
{
  XPUInteger windowNumber = [[document window] windowNumber];
  NSString *newFilename = [document filename];

  // Not strictly necessary as the Document should not be released by changing its filename
  [document retain];
  
  [[self openUnsaved] removeObjectForKey:[NSNumber XP_numberWithInteger:windowNumber]];
  NSLog(@"%@ __documentChangedFilename: removedWindowNumber: %lu", self, windowNumber);
  
  if (oldFilename) {
    [[self openFiles] removeObjectForKey:oldFilename];
    NSLog(@"%@ __documentChangedFilename: removedFilename: %@", self, oldFilename);
  }
  
  if (newFilename) {
    [[self openFiles] setObject:document forKey:newFilename];
    NSLog(@"%@ __documentChangedFilename: addedFilename: %@", self, newFilename);
  } else {
    [[self openUnsaved] setObject:document forKey:[NSNumber XP_numberWithInteger:windowNumber]];
    NSLog(@"%@ __documentChangedFilename: addedWindowNumber: %lu", self, windowNumber);
  }

  [document autorelease];
}

-(void)awakeFromNib;
{
  // Initialize Properties
  _openFiles = [NSMutableDictionary new];
  _openUnsaved = [NSMutableDictionary new];
  
  // Register for Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__windowWillCloseNotification:)
                                               name:NSWindowWillCloseNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__documentDidChangeFilenameNotification:)
                                               name:[SVRDocumentWindowController documentDidChangeFilenameNotification]
                                             object:nil];

  // Announce
  NSLog(@"%@", self);
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_openFiles release];
  [_openUnsaved release];
  _openFiles = nil;
  _openUnsaved = nil;
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
  XPInteger alertResult;
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
