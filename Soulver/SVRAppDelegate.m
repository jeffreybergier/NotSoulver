#import "SVRAppDelegate.h"
#import "SVRDocumentWindowController.h"

@implementation SVRAppDelegate

// MARK: Properties
-(NSMutableDictionary*)openFiles;
{
  return _openFiles;
}
-(NSMutableArray*)openUnsaved;
{
  return _openUnsaved;
}
-(NSEnumerator*)openDocumentEnumerator;
{
  NSArray *collections = [NSArray arrayWithObjects:[self openUnsaved], [self openFiles], nil];
  return [MultiEnumerator enumeratorWithCollections:collections];
}

// MARK: Document Management

-(void)newDoc:(id)sender
{
  SVRDocumentWindowController *controller;
  NSWindow *window;

  controller = [SVRDocumentWindowController controllerWithFilename:nil];
  window = [controller window];
  
  [[self openUnsaved] addObject:controller];
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
  // TODO: Is this needed? TextEdit does not do this.
  XPAlertReturn alertResult = [XPAlert runAppModalWithTitle:@"Save All"
                                                    message:@"Save all documents? This cannot be undone."
                                              defaultButton:@"Save All"
                                            alternateButton:@"Cancel"
                                                otherButton:nil];
  
  switch (alertResult) {
    case XPAlertReturnDefault: [self __saveAll:sender]; return;
    case XPAlertReturnAlternate: return;
    default: [XPLog error:@"%@ Unexpected alert return: %lu", self, alertResult]; return;
  }
  
  
}

-(void)__saveAll:(id)sender;
{
  NSEnumerator *e;
  SVRDocumentWindowController *nextC;
  e = [self openDocumentEnumerator];
  while ((nextC = [e nextObject])) {
    [nextC save:sender];
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
  
  if (controller && ![controller isKindOfClass:[SVRDocumentWindowController class]]) {
    [XPLog debug:@"%@ __windowWillCloseNotification: %@", self, aNotification];
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
  XPUInteger unsavedIndex = NSNotFound;
  NSString *savedFilename = nil;
  if (!document) { [XPLog debug:@"__documentWillClose: document was nil"]; return; }
  [document retain];

  savedFilename = [document filename];
  unsavedIndex = [[self openUnsaved] indexOfObject:document];
  if (unsavedIndex != NSNotFound) {
    [[self openUnsaved] removeObjectAtIndex:unsavedIndex];
  }
  if (savedFilename) {
    [[self openFiles] removeObjectForKey:savedFilename];
  }
  [XPLog debug:@"%@ closedWindow: %lu closedFile: %@", self, [[document window] windowNumber], savedFilename];
  
  [document autorelease];
}

-(void)   __document:(SVRDocumentWindowController*)document
didChangeOldFilename:(NSString*)oldFilename;
{
  XPUInteger unsavedIndex = NSNotFound;
  NSString *newFilename = [document filename];

  [document retain];
  unsavedIndex = [[self openUnsaved] indexOfObject:document];
  if (unsavedIndex != NSNotFound) {
    [[self openUnsaved] removeObjectAtIndex:unsavedIndex];
  }
  if (oldFilename) {
    [[self openFiles] removeObjectForKey:oldFilename];
  }
  if (newFilename) {
    [[self openFiles] setObject:document forKey:newFilename];
  } else {
    [[self openUnsaved] addObject:document];
  }
  [XPLog debug:@"%@ fileChanged: %@", newFilename];
  [document autorelease];
}

-(void)awakeFromNib;
{
  // Initialize Properties
  _openFiles = [NSMutableDictionary new];
  _openUnsaved = [NSMutableArray new];
  
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  
  // Register for Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__windowWillCloseNotification:)
                                               name:NSWindowWillCloseNotification
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
  XPAlertReturn alertResult;
  
  return YES; // TODO: Reimplement document save checking
  
  // TODO: Make this text match the textedit default
  alertResult = [XPAlert runAppModalWithTitle:@"Quit [Not] Soulver"
                                      message:@"Do you want to save changes to your documents before quitting?"
                                defaultButton:@"Save All"
                              alternateButton:@"Cancel"
                                  otherButton:@"Don't Save"];
  switch (alertResult) {
    case XPAlertReturnDefault:
      [self __saveAll:sender];                         // Save everything
      return [self applicationShouldTerminate:sender]; // Check again if there are unsaved changes
    case XPAlertReturnAlternate: return NO;
    case XPAlertReturnOther: return YES;
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

@implementation MultiEnumerator

-(id)nextObject;
{
  // 1. Check the easy path
  id nextObject = [_currentEnumerator nextObject];
  if (nextObject) { return nextObject; }
  
  // 2. See if we can move to the next enumerator
  if (_currentIndex >= [_allCollections count]) { return nil; }
  
  // 3. Increment the enumerator
  [_currentEnumerator release];
  _currentEnumerator = [[[_allCollections objectAtIndex:_currentIndex] objectEnumerator] retain];
  _currentIndex += 1;
  
  // 4. Start over
  return [self nextObject];
}

-(id)initWithCollections:(NSArray*)collections;
{
  self = [super init];
  _allCollections = [collections retain];
  _currentIndex = 0;
  _currentEnumerator = nil;
  return self;
}

+(id)enumeratorWithCollections:(NSArray*)collections;
{
  return [[[MultiEnumerator alloc] initWithCollections:collections] autorelease];
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_allCollections release];
  [_currentEnumerator release];
  _allCollections = nil;
  _currentEnumerator = nil;
  [super dealloc];
}
@end
