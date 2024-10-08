#import "SVRDocumentWindowController.h"

@implementation SVRDocumentWindowController

// MARK: Nib Name
+(NSString*)nibName;
{
#if OS_OPENSTEP
  return @"NEXTSTEP_SVRDocument.nib";
#else
  return @"MACOSX_SVRDocument.nib";
#endif
}

// MARK: Notifications
+(NSString*)documentDidChangeFilenameNotification;
{
  return @"SVRDocumentControllerDocumentDidChangeFilenameNotification";
}
-(NSDictionary*)__documentDidChangeFilenameNotificationInfo:(NSString*)oldFilename;
{
  NSArray *keys;
  NSArray *vals;
  if (!oldFilename) { return nil; }
  keys = [NSArray arrayWithObjects:@"oldFilename", nil];
  vals = [NSArray arrayWithObjects:  oldFilename,  nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Properties
-(NSString*)filename;
{
  return _filename;
}

-(void)setFilename:(NSString*)filename;
{
  NSString *oldFileName = [_filename autorelease];
  NSString *newFileName = [filename copy];
  _filename = newFileName;
  [self __updateWindowState];
  [[NSNotificationCenter defaultCenter]
    postNotificationName:[[self class] documentDidChangeFilenameNotification]
    object:self
    userInfo:[self __documentDidChangeFilenameNotificationInfo:oldFileName]];
}

-(NSWindow*)window;
{
  return _window;
}

-(SVRDocumentModelController*)model;
{
  return _model;
}

-(NSObject*)viewController;
{
  return _viewController;
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ <Window: %ld> <File: %@>",
         [super description], [[self window] windowNumber], [self filename]];
}

// MARK: INIT
-(id)initWithFilename:(NSString*)filename;
{
  self = [super init];
  _filename = [filename retain];
  _nibTopLevelObjects = nil;
  [[NSBundle mainBundle] SVR_loadNibNamed:[[self class] nibName]
                                    owner:self
                          topLevelObjects:&_nibTopLevelObjects];

  return self;
}

+(id)controllerWithFilename:(NSString*)filename;
{
  return [[[SVRDocumentWindowController alloc] initWithFilename:filename] autorelease];
}

-(void)awakeFromNib;
{
  SVRMathString *document;
  NSString *filename;

  // Read the file if there is a filepath
  filename = [self filename];
  if (filename) {
    document = [SVRMathString mathStringWithFilename:filename];
    if (!document) {
      // TODO: Present Error
      [XPLog pause:@"Open File Failed: %@", filename];
      return;
    }
    [[self model] setMathString:document];
  }
  [self __updateWindowState];

  // Register for notifications from the model
  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(__modelRenderDidChangeNotification:)
           name:[SVRDocumentModelController renderDidChangeNotificationName]
         object:[self model]];
  
  // Check to make sure we are delegate
  if ((SVRDocumentWindowController*)[[self window] delegate] != self) {
    [XPLog error:@"Incorrect Window Delegate: %@", [[self window] delegate]];
  }

  // Set up Last Responder
  [[self window] setNextResponder:self];
  
  // Announce
  [XPLog debug:@"%@ awakeFromNib", self];
}

// MARK: Basic Logic

-(BOOL)hasUnsavedChanges;
{
  XPUInteger lhs = [[[self model] mathString] hash];
  XPUInteger rhs = [self __onDiskHash];
  return lhs != rhs;
}

// MARK: Private

-(void)__updateWindowState;
{
  if ([self filename]) {
    [[self window] setTitle:[[self filename] lastPathComponent]];
    [[self window] setRepresentedFilename:[self filename]];
  } else {
    [[self window] setTitle:@"UNTITLED"];
    [[self window] setRepresentedFilename:@""];
  }
  [[self window] setDocumentEdited:[self hasUnsavedChanges]];
}

-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [self __updateWindowState];
}

-(XPUInteger)__onDiskHash;
{
  SVRMathString *read;
  XPUInteger blankHash = [[[[SVRMathString alloc] init] autorelease] hash];
  if (![self filename]) { return blankHash; }
  read = [SVRMathString mathStringWithFilename:[self filename]];
  if (!read) { return blankHash; }
  return [read hash];
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_viewController release];
  [_window setDelegate:nil];
  [_window setNextResponder:nil];
  // this autorelease (instead of release) is necessary
  // to prevent crashes when the window is closing
  [_window autorelease];
  [_filename release];
  [_model release];
  [_nibTopLevelObjects release];
  _nibTopLevelObjects = nil;
  _window = nil;
  _filename = nil;
  _model = nil;
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

// MARK: SVRDocumentWindowController
@implementation SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
{
  // TODO: Make this text match the textedit default
  XPAlertReturn alertResult;
  if (![self hasUnsavedChanges]) { return YES; }
  alertResult = [XPAlert runSheetModalForWindow:[self window]
                                      withTitle:@"Close Document"
                                        message:@"Save changes before closing?"
                                  defaultButton:@"Save"
                                alternateButton:@"Cancel"
                                    otherButton:@"Don't Save"];
  switch (alertResult) {
    case XPAlertReturnDefault:   return [self __save];
    case XPAlertReturnAlternate: return NO;
    case XPAlertReturnOther:     return YES;
    default: [XPLog error:@"%@ Unexpected alert result: %lu", self, alertResult]; return NO;
  }
}
@end

// MARK: NSMenuActionResponder
@implementation SVRDocumentWindowController (NSMenuActionResponder)

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  switch ([menuItem tag]) {
      // Save, logic allows saving if needed or if its a new document
    case 2003: return [self hasUnsavedChanges] || [[[self model] mathString] isEmpty];
      // Save As
    case 2004: return [self filename] != nil;
      // Save To
    case 2005: return [self filename] != nil;
      // Revert to Saved
    case 2007: return ([self filename] != nil) && [self hasUnsavedChanges];
      // Copy Render
    case 3001: return ![[[self model] mathString] isEmpty];
      // Copy
    case 3002: return ![[[self model] mathString] isEmpty];
      // Paste
    case 3003: return [[XPPasteboard generalPasteboard] SVR_mathString] != nil;
    default:
      [XPLog debug:@"%@ validateMenuItem: Unexpected: (%ld)%@", self, [menuItem tag], [menuItem title]];
      return NO;
  }
}

-(void)copy:(id)sender;
{
  [[XPPasteboard generalPasteboard] SVR_setMathString:[[self model] mathString]];
}

-(void)copyRender:(id)sender;
{
  [[XPPasteboard generalPasteboard] SVR_setAttributedString:[[self model] latestRender]];
}

-(void)paste:(id)sender;
{
  XPAlertReturn alertResult = [XPAlert runSheetModalForWindow:[self window]
                                                    withTitle:@"Paste"
                                                      message:@"Replace document contents with clipboard contents?"
                                                defaultButton:@"Paste"
                                              alternateButton:@"Cancel"
                                                  otherButton:nil];
  switch (alertResult) {
    case XPAlertReturnDefault:   [self __paste]; return;
    case XPAlertReturnAlternate: [XPLog debug:@"%@ Cancelled: Paste", self]; return;
    default: [XPLog error:@"%@ Unexpected alert result: %lu", self, alertResult]; return;
  }
}

-(void)save:(id)sender;
{
  [self __save];
}

-(void)saveAs:(id)sender;
{
  [self __saveAs];
}

-(void)saveTo:(id)sender;
{
  [self __saveTo];
}

-(void)revertToSaved:(id)sender;
{
  // TODO: Make this text match the project builder default
  XPAlertReturn alertResult = [XPAlert runSheetModalForWindow:[self window]
                                                    withTitle:@"Revert to Saved"
                                                      message:@"Any changes will be lost"
                                                defaultButton:@"Revert"
                                              alternateButton:@"Cancel"
                                                  otherButton:nil];
  switch (alertResult) {
    case XPAlertReturnDefault:   [self __revertToSaved]; return;
    case XPAlertReturnAlternate: [XPLog debug:@"%@ Cancelled: Revert to Saved", self]; return;
    default: [XPLog error:@"%@ Unexpected alert result: %lu", self, alertResult]; return;
  }
}

-(void)__paste;
{
  SVRMathString *fromPboard;
  fromPboard = [[XPPasteboard generalPasteboard] SVR_mathString];
  if (!fromPboard) { [XPLog debug:@"%@ paste: empty", self]; return; }
  [[self model] setMathString:fromPboard];
}

-(BOOL)__save;
{
  if (![self filename]) { return [self __saveAs]; }
  
  if ([[[self model] mathString] writeToFilename:[self filename]]) {
    [XPLog alwys:@"%@ __save: Success: %@", self, [self filename]];
    [self __updateWindowState];
    return YES;
  } else {
    // TODO: Present Error
    [XPLog pause:@"%@ __save: Failed: %@", self, [self filename]];
    return NO;
  }
}

-(BOOL)__saveAs;
{
  NSString *newFilename = [XPSavePanel filenameByRunningSheetModalSavePanelForWindow:[self window]
                                                                withExistingFilename:[self filename]];
  if (!newFilename) { [XPLog debug:@"%@ __saveAs: Cancelled", self]; return NO; }
  
  if ([[[self model] mathString] writeToFilename:newFilename]) {
    [self setFilename:newFilename];
    [XPLog alwys:@"%@ __saveAs: Success: %@", self, newFilename];
    return YES;
  } else {
    // TODO: Present Error
    [XPLog pause:@"%@ __saveAs: Failed: %@", self, newFilename];
    return NO;
  }
}

-(BOOL)__saveTo;
{
  NSString *newFilename = [XPSavePanel filenameByRunningSheetModalSavePanelForWindow:[self window]
                                                                withExistingFilename:[self filename]];
  if (!newFilename) { [XPLog debug:@"%@ __saveAs: Cancelled", self]; return NO; }

  if ([[[self model] mathString] writeToFilename:newFilename]) {
    [XPLog alwys:@"%@ __saveTo: Success: %@", self, newFilename];
    return YES;
  } else {
    // TODO: Present Error
    [XPLog pause:@"%@ __saveTo: Failed: %@", self, newFilename];
    return NO;
  }

}

-(BOOL)__revertToSaved;
{
  SVRMathString *replacement = nil;
  if (![self filename]) { [XPLog error:@"%@ revertToSaved: Failed: No Filename", self]; return NO; }
  
  replacement = [SVRMathString mathStringWithFilename:[self filename]];
  if (!replacement) {
    // TODO: Present Error
    [XPLog pause:@"%@ revertToSaved: FAILED: %@", self, [self filename]];
    return NO;
  }
  [[self model] setMathString:replacement];
  [self __updateWindowState];
  
  [XPLog debug:@"%@ revertToSaved: SUCCESS: %@", self, [self filename]];
  return YES;
}

@end
