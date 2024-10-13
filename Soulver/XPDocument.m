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
  return self;
}

-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;
{
  self = [self init];
  _fileName = [fileName copy];
  _fileType = [fileType copy];
  _rawData = nil;
  // TODO: Load the nib from the bundle
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

/// Override to read your file and prepare
-(void)awakeFromNib;
{
  [XPLog debug:@"awakeFromNib: %@", self];
}

/// Shows the window for this document
-(void)showWindows;
{
  [[self window] makeKeyAndOrderFront:self];
}

/// Return YES to allow the document to close
-(BOOL)shouldCloseDocument;
{
  XPAlertReturn result;
  if (![self isDocumentEdited]) { return YES; }
  result = [self runUnsavedChangesAlert];
  switch (result) {
    case XPAlertReturnDefault:
      [self saveDocument:self];
      return YES;
    case XPAlertReturnAlternate:
      return YES;
    case XPAlertReturnOther:
      return NO;
    case XPAlertReturnError:
    default:
      [XPLog error:@"Unexpected alert panel result: %ld", result];
      return NO;
  }
}

-(NSWindow*)window;
{
  return [[_window retain] autorelease];
}

// MARK: Document Status

/// Override to update window status
-(BOOL)isDocumentEdited;
{
  return NO;
}

/// Filename on disk is NIL if the document is not saved
-(NSString*)fileName;
{
  return [[_fileName retain] autorelease];
}

-(void)setFileName:(NSString*)fileName;
{
  [_fileName release];
  _fileName = [fileName copy];
}

-(NSString*)fileType;
{
  return [[_fileType retain] autorelease];
}

-(void)setFileType:(NSString*)type;
{
  [_fileType release];
  _fileType = [type copy];
}

-(NSData*)rawData;
{
  return [[_rawData retain] autorelease];
}

-(void)setRawData:(NSData*)newData;
{
  [_rawData release];
  _rawData = [newData copy];
}

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
{
  return [[_fileName retain] autorelease];
}

// MARK: Data reading and writing

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  [XPLog debug:@"Override this to provide the data for your document"];
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

-(IBAction)saveDocument:(id)sender;
{
  NSSavePanel *savePanel = nil;
  NSString *fileName = [self fileName];
  if (fileName) {
    [self writeToFile:nil ofType:nil];
  } else {
    savePanel = [self savePanelForDocument];
    [self runModalSavePanel:savePanel];
    [self setFileName:[savePanel filename]];
  }
}

-(IBAction)saveDocumentAs:(id)sender;
{
  NSSavePanel *savePanel = [self savePanelForDocument];
  [self runModalSavePanel:savePanel];
  [self setFileName:[savePanel filename]];
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


@end
