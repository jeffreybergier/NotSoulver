#import "SVRAppDelegate.h"
#import "SVRDocument.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRAppDelegate

// MARK: Init
-(void)awakeFromNib;
{
  // Initialize Properties
  _openDocuments = [NSMutableSet new];
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  // Register for Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__windowWillCloseNotification:)
                                               name:NSWindowWillCloseNotification
                                             object:nil];
  // Announce
  [XPLog debug:@"AwakeFromNib:%@", self];
}

// MARK: Properties
-(NSMutableSet*)openDocuments;
{
  return _openDocuments;
}

// MARK: IBActions
-(void)newDoc:(id)sender
{
  SVRDocument *document = [SVRDocument documentWithContentsOfFile:nil];
  [document showWindows];
  [[self openDocuments] addObject:document];
}

-(IBAction)openDoc:(id)sender
{
  NSArray *filenames;
  NSEnumerator *e;
  NSString *nextF;
  SVRDocument *nextC;
  
  filenames = [XPOpenPanel filenamesByRunningAppModalOpenPanel];
  if ([filenames count] == 0) { [XPLog debug:@"%@ Open Cancelled", self]; return; }
  e = [filenames objectEnumerator];
  while ((nextF = [e nextObject])) {
    nextC = [[self openDocuments] member:nextF];
    if (!nextC) {
      nextC = [SVRDocument documentWithContentsOfFile:nextF];
      [[self openDocuments] addObject:nextC];
    }
    [[nextC window] makeKeyAndOrderFront:sender];
  }
}

-(IBAction)saveAll:(id)sender;
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
  SVRDocument *nextC;
  e = [[self openDocuments] objectEnumerator];
  while ((nextC = [e nextObject])) {
    [nextC saveDocument:self];
  }
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  XPDocument *document = [window delegate];
  [[self openDocuments] removeObject:document];
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_openDocuments release];
  _openDocuments = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end


@implementation SVRAppDelegate (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
{
  XPAlertReturn alertResult = NSNotFound;
  BOOL aDocumentNeedsSaving = NO;
  NSEnumerator *e = nil;
  XPDocument *next = nil;
  
  // Check all documents
  e = [[self openDocuments] objectEnumerator];
  while ((next = [e nextObject])) {
    aDocumentNeedsSaving = [next isDocumentEdited];
    if (aDocumentNeedsSaving) { break; }
  }
  
  // Ask the user if they want to quit
  if (!aDocumentNeedsSaving) { return YES; }
  alertResult = [XPAlert runAppModalWithTitle:@"Quit"
                                      message:@"There are edited windows."
                                defaultButton:@"Review Unsaved"
                              alternateButton:@"Quit Anyway"
                                  otherButton:@"Cancel"];
  switch (alertResult) {
    case XPAlertReturnDefault:   return NO;
    case XPAlertReturnAlternate: return YES;
    case XPAlertReturnOther:     return NO;
    default:
      [XPLog error:@"%@ Unexpected alert result: %ld", self, alertResult];
      return NO;
  }
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
{
  SVRDocument *document = [[self openDocuments] member:filename];
  if (!document) {
    document = [SVRDocument documentWithContentsOfFile:filename];
    [[self openDocuments] addObject:document];
  }
  [[document window] makeKeyAndOrderFront:sender];
  return YES;
}

-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
{
  [self newDoc:sender];
  return YES;
}
@end
