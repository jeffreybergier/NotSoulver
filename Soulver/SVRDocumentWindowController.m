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

// MARK: Properties

-(void)setFilename:(NSString*)filename;
{
  [_filename autorelease];
  _filename = [filename copy];
  [self __updateWindowState];

}

-(NSString*)filename;
{
  return _filename;
}

-(NSWindow*)window;
{
  return _window;
}

-(NSObject*)viewController;
{
  return _viewController;
}

-(SVRDocumentModelController*)model;
{
  return _model;
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
  // TODO: Reimplement file loading
  
  // Check to make sure we are delegate
  if ((SVRDocumentWindowController*)[[self window] delegate] != self) {
    [XPLog error:@"Incorrect Window Delegate: %@", [[self window] delegate]];
  }
  
  [self __updateWindowState];

  // Set up Last Responder
  [[self window] setNextResponder:self];
  
  // Announce
  [XPLog debug:@"%@ awakeFromNib", self];
}

// MARK: Basic Logic

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
  [[self window] setDocumentEdited:YES];
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
  [super dealloc];
}

@end

// MARK: SVRDocumentWindowController
@implementation SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
{
  // TODO: Make this text match the textedit default
  XPAlertReturn alertResult;
  if (NO /*![self hasUnsavedChanges]*/) { return YES; }
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
    // TODO: Update Menus to be stock again
      // Save, logic allows saving if needed or if its a new document
    case 2003: return YES;
      // Save As
    case 2004: return YES;
      // Save To
    case 2005: return YES;
      // Revert to Saved
    case 2007: return YES;
      // Copy Render
    case 3001: return YES;
      // Copy
    case 3002: return YES;
      // Paste
    case 3003: return YES;
    default:
      [XPLog debug:@"%@ validateMenuItem: Unexpected: (%ld)%@", self, [menuItem tag], [menuItem title]];
      return NO;
  }
}

-(IBAction)save:(id)sender;
{
  [self __save];
}

-(IBAction)saveAs:(id)sender;
{
  [self __saveAs];
}

-(BOOL)__save;
{
  if (![self filename]) { return [self __saveAs]; }
  [XPLog error:@"Unimplemented"];
  return NO;
}

-(BOOL)__saveAs;
{
  NSString *newFilename = [XPSavePanel filenameByRunningSheetModalSavePanelForWindow:[self window]
                                                                withExistingFilename:[self filename]];
  if (!newFilename) { [XPLog debug:@"%@ __saveAs: Cancelled", self]; return NO; }
  [XPLog error:@"Unimplemented"];
  return NO;
}

@end
