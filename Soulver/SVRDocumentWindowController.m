#import "SVRDocumentWindowController.h"

@implementation SVRDocumentWindowController

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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [NSBundle loadNibNamed:@"NEXTSTEP_SVRDocument.nib" owner:self];
#pragma clang diagnostic pop

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

// MARK: Private

-(void)__updateWindowState;
{
  // Update Title
  if ([self filename]) {
    [[self window] setTitle:[self filename]];
    [[self window] setRepresentedFilename:[self filename]];
  } else {
    [[self window] setTitle:@"UNTITLED.solv"];
    [[self window] setRepresentedFilename:@""];
  }
  [[self window] setDocumentEdited:[self __needsSaving]];
}

-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [self __updateWindowState];
}

-(XPUInteger)__onDiskHash;
{
  SVRMathString *read;
  // TODO: Consider making this has smarter/lazier
  unsigned blankHash = 0;
  if (![self filename]) { return blankHash; }
  read = [SVRMathString mathStringWithFilename:[self filename]];
  if (!read) { return blankHash; }
  return [read hash];
}
-(BOOL)__needsSaving;
{
  XPUInteger lhs = [[[self model] mathString] hash];
  XPUInteger rhs = [self __onDiskHash];
  return lhs != rhs;
}

-(NSString*)__runSavePanel;
{
  NSString *output = nil;
  NSSavePanel *panel = [NSSavePanel savePanel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [panel setRequiredFileType:@"solv"];
  [panel runModal];
  output = [panel filename];
#pragma clang diagnostic pop
  return output;
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
  XPInteger alertResult;
  if (![self __needsSaving]) { return YES; }
  alertResult = [XPAlert runSheetModalForWindow:[self window]
                                      withTitle:@"Close Document"
                                        message:@"Save changes before closing?"
                                  defaultButton:@"Save"
                                alternateButton:@"Cancel"
                                    otherButton:@"Don't Save"];
  switch (alertResult) {
    case 1:
      return [self __save];
    case -1:
      return YES;
    default:
      return NO;
  }
}
@end

// MARK: NSMenuActionResponder
@implementation SVRDocumentWindowController (NSMenuActionResponder)

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  // TODO: Add Cut (3001), Copy (3002), Paste (3003), Select All (3004)
  switch ([menuItem tag]) {
      // Save
    case 2003: return [self __needsSaving];
      // Save As
    case 2004: return [self filename] != nil;
      // Save To
    case 2005: return ([self filename] != nil) && [self __needsSaving];
      // Revert to Saved
      // TODO: Set KeyEquivalent to CMD+U
    case 2007: return ([self filename] != nil) && [self __needsSaving];
    default:
      [XPLog pause:@"%@ validateMenuItem: Unexpected: (%ld)%@", self, [menuItem tag], [menuItem title]];
      return NO;
  }
}

-(void)cut:(id)sender;
{
  [XPLog pause:@"%@ cut: %@", self, sender];
}

-(void)copy:(id)sender;
{
  [XPLog pause:@"%@ copy: %@", self, sender];
}

-(void)paste:(id)sender;
{
  [XPLog pause:@"%@ paste: %@", self, sender];
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
  XPInteger alertResult = [XPAlert runSheetModalForWindow:[self window]
                                                withTitle:@"Revert to Saved"
                                                  message:@"Any changes will be lost"
                                            defaultButton:@"Revert"
                                          alternateButton:@"Cancel"
                                              otherButton:nil];
  switch (alertResult) {
    case 1: [self __revertToSaved]; break;
    default: break;
  }
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
  NSString *newFilename = [self __runSavePanel];
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
  NSString *newFilename = [self __runSavePanel];
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
