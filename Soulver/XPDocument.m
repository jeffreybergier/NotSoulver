/* XPDocument.m created by me on Sat 12-Oct-2024 */

#import "XPDocument.h"
#import "NSUserDefaults+Soulver.h"

@implementation XPDocument

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
{
  self = [super init];
  _fileName = nil;
  _fileType = nil;
  _rawData = nil;
  [NSBundle loadNibNamed:[self windowNibName] owner:self];
  return self;
}

-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;
{
  self = [self init];
  _fileName = [fileName copy];
  _fileType = [fileType copy];
  _rawData = nil;
  return self;
}

// MARK: Window Management

/// Default implementation throws exception.
/// File's Owner Should be this Object
-(NSString*)windowNibName;
{
  [XPLog error:@"Unimplemented"];
  return nil;
}

/// Shows the window for this document
-(void)showWindows;
{
  [[self window] makeKeyAndOrderFront:self];
}

/// Return YES to allow the document to close
-(BOOL)windowShouldClose:(id)sender;
{
  XPAlertReturn alertResult;
  XPInteger savePanelResult;
  if (![self isDocumentEdited]) { return YES; }
  alertResult = [self runUnsavedChangesAlert];
  switch (alertResult) {
    case XPAlertReturnDefault:
      savePanelResult = [self __runModalSavePanelAndSetFileName:nil];
      return savePanelResult == NSOKButton;
    case XPAlertReturnAlternate:
      return YES;
    case XPAlertReturnOther:
      return NO;
    case XPAlertReturnError:
    default:
      [XPLog error:@"Unexpected alert panel result: %ld", alertResult];
      return NO;
  }
}

-(NSWindow*)window;
{
  return [[_window retain] autorelease];
}

/// Override to read your file and prepare
-(void)awakeFromNib;
{
  NSString *fileName = [self fileName];
  NSString *fileType = [self fileType];
  if (fileName && fileType) {
    [self readFromFile:fileName ofType:fileType];
  }
  [[self window] setDelegate:self];
  [[self window] setNextResponder:self];
  [self updateWindowState];
  [XPLog debug:@"awakeFromNib: %@", self];
}

-(void)updateWindowState;
{
  NSWindow *window = [self window];
  NSString *fileName = [self fileName];
  
  if (fileName) {
    [window setTitle:[self displayName]];
    [window setRepresentedFilename:fileName];
  } else {
    [window setTitle:@"UNTITLED"];
    [window setRepresentedFilename:@""];
  }
  [window setDocumentEdited:[self isDocumentEdited]];
}

// MARK: Document Status

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
{
  NSString *lastPathComponent = [[self fileName] lastPathComponent];
  return (lastPathComponent) ? lastPathComponent : @"UNTITLED";
}

/// Override to update window status
-(BOOL)isDocumentEdited;
{
  NSData *diskData = nil;
  NSData *rawData = nil;
  NSString *fileName = [self fileName];
  if (fileName) {
    diskData = [NSData dataWithContentsOfFile:fileName];
    rawData = [self rawData];
    return [diskData isEqualToData:rawData];
  } else {
    return YES;
  }
}

/// Filename on disk is NIL if the document is not saved
-(NSString*)fileName;
{
  return [[_fileName retain] autorelease];
}

-(void)setFileName:(NSString*)fileName;
{
  if ([fileName isEqualToString:_fileName]) { return; }
  [_fileName release];
  _fileName = [fileName copy];
}

-(NSString*)fileType;
{
  return [[_fileType retain] autorelease];
}

-(void)setFileType:(NSString*)type;
{
  if ([type isEqualToString:_fileType]) { return; }
  [_fileType release];
  _fileType = [type copy];
}

-(NSData*)rawData;
{
  return [[_rawData retain] autorelease];
}

-(void)setRawData:(NSData*)rawData;
{
  if ([rawData isEqualToData:_rawData]) { return; }
  [_rawData release];
  _rawData = [rawData copy];
}

/// Returns hash of the filename or calls super
-(XPUInteger)hash;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    return [fileName hash];
  } else {
    return [super hash];
  }
}

/// Compares fileName or calls super
-(BOOL)isEqual:(id)object;
{
  NSString *fileName = [self fileName];
  if (fileName && [object isKindOfClass:[NSString class]]) {
    return [fileName isEqualToString:object];
  } else {
    return [super isEqual:object];
  }
}

// MARK: Data reading and writing

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  [XPLog pause:@"Override this to provide the data for your document"];
  return nil;
}

-(BOOL)writeToFile:(NSString*)__fileName ofType:(NSString*)__type;
{
  BOOL writeResult = NO;
  NSString *fileName = (__fileName) ? __fileName : [self fileName];
  NSString *fileType = (__type) ? __type : [self fileType];
  NSData *forWriting = [self dataRepresentationOfType:fileType];
  if (fileName && fileType && forWriting) {
    writeResult = [forWriting writeToFile:fileName atomically:YES];
    [self setFileName:fileName];
  }
  return writeResult;
}

-(BOOL)readFromFile:(NSString*)__fileName ofType:(NSString*)__type;
{
  NSString *fileName = (__fileName) ? __fileName : [self fileName];
  if (fileName) {
    [self setRawData:[NSData dataWithContentsOfFile:fileName]];
    [self setFileName:fileName];
    return YES;
  } else {
    return NO;
  }
}

// MARK: Menu Handling

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  return YES;
}

-(IBAction)saveDocument:(id)sender;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    [self writeToFile:nil ofType:nil];
  } else {
    [self __runModalSavePanelAndSetFileName:nil];
  }
}

-(IBAction)saveDocumentAs:(id)sender;
{
  [self __runModalSavePanelAndSetFileName:nil];
}

-(IBAction)saveDocumentTo:(id)sender;
{
  [self runModalSavePanel:nil];
}

-(IBAction)revertDocumentToSaved:(id)sender;
{
  XPAlertReturn result = [self runRevertToSavedAlert];
  switch (result) {
    case XPAlertReturnDefault:
      [self readFromFile:nil ofType:nil];
      break;
    case XPAlertReturnAlternate:
      [XPLog debug:@"User cancelled revert"];
      break;
    case XPAlertReturnOther:
    case XPAlertReturnError:
    default:
      [XPLog error:@"Unexpected alert panel result: %ld", result];
  }
}

// MARK: Panels and Alerts

-(NSSavePanel*)savePanelForDocument;
{
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setRequiredFileType:[self fileType]];
  [savePanel setDirectory:[[NSUserDefaults standardUserDefaults] SVR_savePanelLastDirectory]];
  return savePanel;
}

-(XPInteger)runModalSavePanel:(NSSavePanel*)_savePanel;
{
  XPInteger okCancel;
  NSSavePanel *savePanel = (_savePanel) ? _savePanel : [self savePanelForDocument];
  okCancel = [savePanel runModal];
  switch (okCancel) {
    case NSOKButton:
      // TODO: Consider trying to return error value if this fails
      [self writeToFile:[savePanel filename] ofType:nil];
      break;
    case NSCancelButton:
      [XPLog debug:@"User cancelled save"];
      break;
    default:
      [XPLog error:@"Unexpected save panel result: %ld", okCancel];
      break;
  }
  [[NSUserDefaults standardUserDefaults] SVR_setSavePanelLastDirectory:[savePanel directory]];
  return okCancel;
}

-(XPInteger)__runModalSavePanelAndSetFileName:(NSSavePanel*)_savePanel;
{
  NSSavePanel *savePanel = (_savePanel) ? _savePanel : [self savePanelForDocument];
  XPInteger result = [self runModalSavePanel:savePanel];
  if (result == NSOKButton) {
    [self setFileName:[savePanel filename]];
  }
  return result;
}


-(XPAlertReturn)runUnsavedChangesAlert;
{
  return NSRunAlertPanel(@"Close",
                         @"Save changes to %@?",
                         @"Save",
                         @"Don't Save",
                         @"Cancel",
                         [self displayName]);
}

-(XPAlertReturn)runRevertToSavedAlert;
{
  return NSRunAlertPanel(@"Alert",
                         @"Do you want to revert changes to %@?",
                         @"Revert",
                         @"Cancel",
                         nil,
                         [self displayName]);
}

- (void)dealloc
{
  [XPLog debug:@"DEALLOC: %@", self];
  [_window setDelegate:nil];
  [_window setNextResponder:nil];
  // this autorelease (instead of release) is necessary
  // to prevent crashes when the window is closing
  [_window   autorelease];
  [_fileName release];
  [_fileType release];
  [_rawData  release];
  _window   = nil;
  _fileName = nil;
  _fileType = nil;
  _rawData  = nil;
  [super dealloc];
}


@end
