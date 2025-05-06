//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "XPDocument.h"
#import "NSUserDefaults+Soulver.h"

#ifdef XPSupportsNSDocument

@implementation NSDocument (CrossPlatform)

-(NSString*)XP_nameForFrameAutosave;
{
  XPURL *fileURL = [self XP_fileURL];
  if (![fileURL XP_isFileURL]) { return nil; }
  return [fileURL path];
}

-(XPURL*)XP_fileURL;
{
  return [self fileURL];
}

@end

#else

NSPoint XPDocumentPointForCascading;

@implementation XPDocument

// MARK: Window Placement

+(void)initialize;
{
  XPDocumentPointForCascading = NSZeroPoint;
}

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
{
  self = [super init];
  NSCParameterAssert(self);
  _fileURL = nil;
  _fileType = nil;
  _isNibLoaded = NO;
  _isEdited = NO;
  return self;
}

-(id)initWithContentsOfURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(id*)outError;
{
  self = [self init];
  
  NSCParameterAssert(self);
  NSCParameterAssert(fileURL);
  NSCParameterAssert(fileType);
  
  _fileURL  = [fileURL copy];
  _fileType = [fileType copy];
  [self readFromURL:fileURL ofType:fileType error:NULL];
  
  return self;
}

// MARK: Window Management

/// Default implementation throws exception.
/// File's Owner Should be this Object
-(NSString*)windowNibName;
{
  XPLogRaise(@"Unimplemented");
  return nil;
}

/// Loads the NIB if needed and shows the window
-(void)showWindows;
{
  if (!_isNibLoaded) {
    _isNibLoaded = YES;
    [NSBundle loadNibNamed:[self windowNibName] owner:self];
  }
  [[self windowForSheet] makeKeyAndOrderFront:self];
}

-(NSWindow*)windowForSheet;
{
  return [[window retain] autorelease];
}

// MARK: One Time Setup

-(void)awakeFromNib;
{
  XPURL    *fileURL  = [self XP_fileURL];
  NSString *fileType = [self fileType];
  NSWindow *myWindow = [self windowForSheet];
  
  // Read the data
  if ([fileURL isAbsolutePath]) {
    [self readFromURL:fileURL ofType:fileType error:NULL];
  }
  
  if (![self XP_nameForFrameAutosave]) {
    XPDocumentPointForCascading = [myWindow cascadeTopLeftFromPoint:XPDocumentPointForCascading];
  }
  
  // Update window chrome
  [self updateChangeCount:2];
  
  // Set the delegate for -windowShouldClose:
  [myWindow setDelegate:self];

  // Declare that we are loaded
  [self windowControllerDidLoadNib:nil];
  
  XPLogDebug1(@"awakeFromNib: %@", self);
}

-(void)windowControllerDidLoadNib:(id)windowController; {}

// MARK: Document Properties

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
{
  NSString *lastPathComponent = [[self XP_fileURL] lastPathComponent];
  return (lastPathComponent) ? lastPathComponent : [Localized titleUntitled];
}

/// Override to update window status
-(BOOL)isDocumentEdited;
{
  return _isEdited;
}

-(void)updateChangeCount:(int)change;
{
  NSWindow *myWindow = [self windowForSheet];
  XPURL *fileURL = [self XP_fileURL];

  _isEdited = (change == 2) ? NO : YES;

  if ([fileURL isAbsolutePath]) {
    [myWindow setRepresentedFilename:[fileURL XP_path]];
  } else {
    [myWindow setRepresentedFilename:@""];
  }
  [myWindow setTitle:[self displayName]];
  [myWindow setDocumentEdited:[self isDocumentEdited]];
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

// MARK: Customizations

-(XPURL*)XP_fileURL;
{
  return [[_fileURL retain] autorelease];
}

-(void)XP_setFileURL:(XPURL*)fileURL;
{
  NSCParameterAssert(fileURL);
  if ([fileURL isEqualToString:_fileURL]) { return; }
  [_fileURL release];
  _fileURL = [fileURL copy];
}

-(NSString*)XP_fileExtension;
{
  NSCParameterAssert(_fileExtension);
  return [[_fileExtension retain] autorelease];
}

-(void)XP_setFileExtension:(NSString*)type;
{
  NSCParameterAssert(type);
  if ([type isEqualToString:_fileExtension]) { return; }
  [_fileExtension release];
  _fileExtension = [type copy];
}

-(NSString*)XP_nameForFrameAutosave;
{
  XPURL *fileURL = [self XP_fileURL];
  if (![fileURL isAbsolutePath]) { return nil; }
  return [fileURL XP_path];
}

/// Return YES to allow the document to close
-(BOOL)windowShouldClose:(id)sender;
{
  XPAlertReturn alertResult;
  if (![self isDocumentEdited]) { return YES; }
  alertResult = [self runUnsavedChangesAlert];
  switch (alertResult) {
    case XPAlertReturnDefault:
      if ([[self XP_fileURL] isAbsolutePath]) {
        [self saveDocument:sender];
        return YES;
      } else {
        return [self __runModalSavePanelAndSetFileURL] == XPModalResponseOK;
      }
    case XPAlertReturnAlternate:
      return YES;
    case XPAlertReturnOther:
      return NO;
    case XPAlertReturnError:
    default:
      XPLogRaise1(@"Unexpected alert panel result: %ld", alertResult);
      return NO;
  }
}

// MARK: NSObject basics

-(XPUInteger)hash;
{
  XPURL *fileURL = [self XP_fileURL];
  if (fileURL) {
    return [fileURL hash];
  } else {
    return [super hash];
  }
}

/// Compares fileName or calls super
-(BOOL)isEqual:(id)object;
{
  XPURL *fileURL = [self XP_fileURL];
  if (fileURL && [object isKindOfClass:[NSString class]]) {
    return [fileURL isEqualToString:object];
  } else {
    return [super isEqual:object];
  }
}

// MARK: Data reading and writing
// Override to provide data for saving
-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  XPLogRaise(@"Unimplemented");
  return nil;
}

// Override to convert your model when reading from disk
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  XPLogRaise(@"Unimplemented");
  return NO;
}

-(BOOL)writeToURL:(XPURL*)__fileURL ofType:(NSString*)__fileType error:(id*)outError;
{
  XPURL    *fileURL  = (__fileURL ) ? __fileURL  : [self XP_fileURL];
  NSString *fileType = (__fileType) ? __fileType : [self fileType];
  NSData *forWriting = [self dataRepresentationOfType:fileType];
  if (fileURL && fileType && forWriting) {
    return [forWriting XP_writeToURL:fileURL atomically:YES];
  }
  return NO;
}

-(BOOL)readFromURL:(XPURL*)__fileURL ofType:(NSString*)__fileType error:(id*)outError;
{
  NSData   *data = nil;
  XPURL    *fileURL  = (__fileURL ) ? __fileURL  : [self XP_fileURL];
  NSString *fileType = (__fileType) ? __fileType : [self fileType];
  if (!fileURL) { return NO; }
  
  data = [NSData XP_dataWithContentsOfURL:fileURL];
  if (!data) { return NO; }

  return [self loadDataRepresentation:data ofType:fileType];
}

// MARK: Menu Handling

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  SEL menuAction = [menuItem action];
  XPURL *fileURL = [self XP_fileURL];
  if        (menuAction == @selector(saveDocument:)) {
    return fileURL == nil || [self isDocumentEdited];
  } else if (menuAction == @selector(saveDocumentAs:)) {
    return fileURL != nil;
  } else if (menuAction == @selector(saveDocumentTo:)) {
    return fileURL != nil;
  } else if (menuAction == @selector(revertDocumentToSaved:)) {
    return fileURL != nil && [self isDocumentEdited];
  }
  return NO;
}

-(IBAction)saveDocument:(id)sender;
{
  XPURL *fileURL = [self XP_fileURL];
  if (fileURL) {
    [self writeToURL:nil ofType:nil error:NULL];
  } else {
    [self __runModalSavePanelAndSetFileURL];
  }
  [self updateChangeCount:2];
}

-(IBAction)saveDocumentAs:(id)sender;
{
  [self __runModalSavePanelAndSetFileURL];
  [self updateChangeCount:2];
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
      [self readFromURL:nil ofType:nil error:NULL];
      break;
    case XPAlertReturnAlternate:
      XPLogDebug(@"User cancelled revert");
      break;
    case XPAlertReturnOther:
    case XPAlertReturnError:
    default:
      XPLogRaise1(@"Unexpected alert panel result: %ld", result);
  }
  [self updateChangeCount:2];
}

// MARK: Panels and Alerts
-(BOOL)prepareSavePanel:(NSSavePanel*)savePanel;
{
  [savePanel setRequiredFileType:[self XP_fileExtension]];
  [savePanel setDirectory:[[NSUserDefaults standardUserDefaults] SVR_savePanelLastDirectory]];
  return YES;
}

-(XPInteger)runModalSavePanel:(NSSavePanel*)_savePanel;
{
  XPInteger okCancel;
  NSSavePanel *savePanel = (_savePanel) ? _savePanel : [NSSavePanel savePanel];
  [self prepareSavePanel:savePanel];
  
  okCancel = [savePanel runModal];
  switch (okCancel) {
    case XPModalResponseOK:
      [self writeToURL:[savePanel filename] ofType:nil error:NULL];
      break;
    case XPModalResponseCancel:
      XPLogDebug(@"User cancelled save");
      break;
    default:
      XPLogRaise1(@"Unexpected save panel result: %ld", okCancel);
      break;
  }
  [[NSUserDefaults standardUserDefaults] SVR_setSavePanelLastDirectory:[savePanel directory]];
  return okCancel;
}

-(XPInteger)__runModalSavePanelAndSetFileURL;
{
  XPInteger result;
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  result = [self runModalSavePanel:savePanel];
  if (result == XPModalResponseOK) {
    [self XP_setFileURL:[savePanel filename]];
  }
  return result;
}


-(XPAlertReturn)runUnsavedChangesAlert;
{
  return NSRunAlertPanel([Localized titleClose],
                         [Localized phraseSaveChangesTo],
                         [Localized verbSave],
                         [Localized verbDontSave],
                         [Localized verbCancel],
                         [self displayName]);
}

-(XPAlertReturn)runRevertToSavedAlert;
{
  return NSRunAlertPanel([Localized titleAlert],
                         [Localized phraseRevertChangesTo],
                         [Localized verbRevert],
                         [Localized verbCancel],
                         nil,
                         [self displayName]);
}

- (void)dealloc
{
  XPLogDebug1(@"DEALLOC: %@", self);
  [window setDelegate:nil];
  // this autorelease (instead of release) is necessary
  // to prevent crashes when the window is closing
  [window autorelease];
  [_fileURL release];
  [_fileType release];
  [_fileExtension release];
  window = nil;
  _fileURL = nil;
  _fileType = nil;
  _fileExtension = nil;
  [super dealloc];
}

@end

#endif
