/* XPDocument.m created by me on Sat 12-Oct-2024 */

#import "XPDocument.h"

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
  return YES;
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

-(BOOL)writeToFile:(NSString*)_fileName ofType:(NSString*)_type;
{
  NSString *fileName = [self fileName];
  NSString *fileType = [self fileType];
  NSData *forWriting = [self dataRepresentationOfType:fileType];
  if (fileName && fileType && forWriting) {
    return [forWriting writeToFile:fileName atomically:YES];
  } else {
    return -1;
  }
}

-(BOOL)readFromFile:(NSString*)_fileName ofType:(NSString*)_type;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    [self setRawData:[NSData dataWithContentsOfFile:fileName]];
    return YES;
  } else {
    return NO;
  }
}

// MARK: Menu Handling

-(IBAction)saveDocument:(id)sender;
{
}
-(IBAction)saveDocumentAs:(id)sender;
{
}
-(IBAction)saveDocumentTo:(id)sender;
{
}
-(IBAction)revertDocumentToSaved:(id)sender;
{
}

// MARK: Panels and Alerts

-(XPInteger)runModalSavePanel:(XPSavePanel*)savePanel;
{
  return -1;
}
-(XPInteger)runUnsavedChangesAlert;
{
  return -1;
}

@end
