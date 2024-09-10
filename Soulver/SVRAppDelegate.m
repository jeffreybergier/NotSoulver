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
  NSArray *filenames;
  NSEnumerator *e;
  NSString *nextF;
  SVRDocumentWindowController *nextC;
  
  filenames = [XPOpenPanel filenamesByRunningAppModalOpenPanel];
  if ([filenames count] == 0) { [XPLog debug:@"%@ Open Cancelled", self]; return; }
  e = [filenames objectEnumerator];
  while ((nextF = [e nextObject])) {
    nextC = [[self openFiles] objectForKey:nextF];
    if (!nextC) {
      nextC = [SVRDocumentWindowController controllerWithFilename:nextF];
      [[self openFiles] setObject:nextC forKey:nextF];
    }
    [[nextC window] makeKeyAndOrderFront:sender];
  }
}

-(void)saveAll:(id)sender;
{
  NSEnumerator *e1;
  NSEnumerator *e2;
  SVRDocumentWindowController *nextC = nil;
  
  XPAlertReturn alertResult = [XPAlert runAppModalWithTitle:@"Save All"
                                                    message:@"Save all documents? This cannot be undone."
                                              defaultButton:@"Save All"
                                            alternateButton:@"Cancel"
                                                otherButton:nil];
  
  switch (alertResult) {
    case XPAlertReturnDefault:   break;
    case XPAlertReturnAlternate: return;
    default: [XPLog error:@"%@ Unexpected alert return: %lu", self, alertResult]; return;
  }
  
  e1 = [[self openUnsaved] objectEnumerator];
  e2 = [[self openFiles] objectEnumerator];
  nextC = [e1 nextObject];
  while (nextC) {
    [nextC save:sender];
    nextC = [e1 nextObject];
    if (!nextC) { nextC = [e2 nextObject]; }
  }
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  SVRDocumentWindowController *controller = nil;
  NSWindow *window = [aNotification object];
  
  if (![window isKindOfClass:[NSWindow class]]) {
    [XPLog error:@"%@ __windowWillCloseNotification: %@", self, aNotification];
  }
  
  controller = (SVRDocumentWindowController*)[window delegate];
  
  if (![controller isKindOfClass:[SVRDocumentWindowController class]]) {
    [XPLog error:@"%@ __windowWillCloseNotification: %@", self, aNotification];
  }
  
  [self __documentWillClose:controller];
}

-(void)__documentDidChangeFilenameNotification:(NSNotification*)aNotification;
{
  id _oldFilename = [[aNotification userInfo] objectForKey:@"oldFilename"];
  NSString *oldFilename = ([_oldFilename isKindOfClass:[NSString class]]) ? _oldFilename : nil;
  SVRDocumentWindowController *controller = [aNotification object];
  
  if (![controller isKindOfClass:[SVRDocumentWindowController class]]) {
    [XPLog error:@"%@ __documentDidChangeFilenameNotification: %@", self, aNotification];
  }
  
  [self __document:controller didChangeOldFilename:oldFilename];
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
  
  [XPLog debug:@"%@ closedWindow: %lu closedFile: %@", self, windowNumber, filename];
  
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
  
  if (oldFilename) {
    [[self openFiles] removeObjectForKey:oldFilename];
  }
  
  if (newFilename) {
    [[self openFiles] setObject:document forKey:newFilename];
  } else {
    [[self openUnsaved] setObject:document forKey:[NSNumber XP_numberWithInteger:windowNumber]];
  }
  
  [XPLog debug:@"%@ fileChanged: %@", newFilename];

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
  [XPLog debug:@"%@ awakeFromNib", self];
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
  SVRDocumentWindowController *nextC;
  XPAlertReturn alertResult;
  BOOL result = YES;
  
  e1 = [[self openUnsaved] objectEnumerator];
  e2 = [[self openFiles] objectEnumerator];
  nextC = [e1 nextObject];
  while (nextC && result) {
    result = ![nextC hasUnsavedChanges];
    nextC = [e1 nextObject];
    if (!nextC) { nextC = [e2 nextObject]; }
  }
  if (result) { return YES; }
  
  // TODO: Improve this to actually save things
  // Change buttons to Quit Without Saving, Cancel, Save All
  alertResult = [XPAlert runAppModalWithTitle:@"Quit [Not] Soulver"
                                      message:@"There are documents with unsaved changes. Save changes before quitting?"
                                defaultButton:@"Review Unsaved Changes"
                              alternateButton:@"Quit Anyway"
                                  otherButton:nil];
  switch (alertResult) {
    case XPAlertReturnDefault:   return NO;
    case XPAlertReturnAlternate: return YES;
    default: [XPLog error:@"%@ Unexpected alert result: %lu", self, alertResult]; return NO;
  }
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
