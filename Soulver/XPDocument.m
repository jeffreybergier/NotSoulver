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

#ifndef XPSupportsNSDocument

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
  _fileName = nil;
  _fileType = nil;
  _isNibLoaded = NO;
  _isEdited = NO;
  return self;
}

-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;
{
  self = [self init];
  
  NSCParameterAssert(self);
  NSCParameterAssert(fileName);
  NSCParameterAssert(fileType);
  
  _fileName = [fileName copy];
  _fileType = [fileType copy];
  [self readFromFile:fileName ofType:fileType];
  
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
    [self windowControllerWillLoadNib:nil];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [NSBundle loadNibNamed:[self windowNibName] owner:self];
#pragma clang diagnostic pop
  }
  [[self XP_windowForSheet] makeKeyAndOrderFront:self];
}

/// Return YES to allow the document to close
-(BOOL)windowShouldClose:(id)sender;
{
  XPAlertReturn alertResult;
  if (![self isDocumentEdited]) { return YES; }
  alertResult = [self runUnsavedChangesAlert];
  switch (alertResult) {
    case XPAlertReturnDefault:
      if ([[self fileName] isAbsolutePath]) {
        [self saveDocument:sender];
        return YES;
      } else {
        return [self __runModalSavePanelAndSetFileName] == XPModalResponseOK;
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

-(NSWindow*)XP_windowForSheet;
{
  return [[_window retain] autorelease];
}

/// Override to read your file and prepare
-(void)awakeFromNib;
{
  NSString *fileName = [self fileName];
  NSString *fileType = [self fileType];
  NSWindow *window   = [self XP_windowForSheet];
  
  // Read the data
  if ([[self fileName] isAbsolutePath]) {
    [self readFromFile:fileName ofType:fileType];
  }
  
  // Update window frame
  if ([[self fileName] isAbsolutePath]) {
    [window setFrameUsingName:fileName];
  } else {
    XPDocumentPointForCascading = [window cascadeTopLeftFromPoint:XPDocumentPointForCascading];
  }
  
  // Update window chrome
  [self updateChangeCount:2];

  // Set the delegate
  [window setDelegate:self];

  // Declare that we are loaded
  [self windowControllerDidLoadNib:nil];
  
  XPLogDebug1(@"awakeFromNib: %@", self);
}

-(void)windowControllerWillLoadNib:(NSWindowController*)windowController;
{
  
}
-(void)windowControllerDidLoadNib:(NSWindowController*)windowController;
{
  
}

// MARK: Document Status

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
{
  NSString *lastPathComponent = [[self fileName] lastPathComponent];
  return (lastPathComponent) ? lastPathComponent : [Localized titleUntitled];
}

/// Override to update window status
-(BOOL)isDocumentEdited;
{
  return _isEdited;
}

-(void)updateChangeCount:(int)change;
{
  NSWindow *window = [self XP_windowForSheet];
  NSString *fileName = [self fileName];

  _isEdited = (change == 2) ? NO : YES;

  if ([fileName isAbsolutePath]) {
    [window setRepresentedFilename:fileName];
  } else {
    [window setRepresentedFilename:@""];
  }
  [window setTitle:[self displayName]];
  [window setDocumentEdited:[self isDocumentEdited]];
}

-(NSString*)fileName;
{
  return [[_fileName retain] autorelease];
}

-(void)setFileName:(NSString*)fileName;
{
  NSCParameterAssert(fileName);
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

-(BOOL)writeToFile:(NSString*)__fileName ofType:(NSString*)__type;
{
  NSString *fileName = (__fileName) ? __fileName : [self fileName];
  NSString *fileType = (__type)     ? __type     : [self fileType];
  NSData *forWriting = [self dataRepresentationOfType:fileType];
  if (fileName && fileType && forWriting) {
    return [forWriting writeToFile:fileName atomically:YES];
  }
  return NO;
}

-(BOOL)readFromFile:(NSString *)__fileName ofType:(NSString *)__type;
{
  NSData *data = nil;
  NSString *fileName = (__fileName) ? __fileName : [self fileName];
  NSString *fileType = (__type)     ? __type     : [self fileType];
  if (!fileName) { return NO; }
  
  data = [NSData dataWithContentsOfFile:fileName];
  if (!data) { return NO; }

  return [self loadDataRepresentation:data ofType:fileType];
}

// MARK: Menu Handling

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  SEL menuAction = [menuItem action];
  if        (menuAction == @selector(saveDocument:)) {
    return [self fileName] == nil || [self isDocumentEdited];
  } else if (menuAction == @selector(saveDocumentAs:)) {
    return [self fileName] != nil;
  } else if (menuAction == @selector(saveDocumentTo:)) {
    return [self fileName] != nil;
  } else if (menuAction == @selector(revertDocumentToSaved:)) {
    return [self fileName] != nil && [self isDocumentEdited];
  }
  return NO;
}

-(IBAction)saveDocument:(id)sender;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    [self writeToFile:nil ofType:nil];
  } else {
    [self __runModalSavePanelAndSetFileName];
  }
  [self updateChangeCount:2];
}

-(IBAction)saveDocumentAs:(id)sender;
{
  [self __runModalSavePanelAndSetFileName];
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
      [self readFromFile:nil ofType:nil];
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

// MARK: NSWindowDelegate

-(void)windowDidResize:(NSNotification*)aNotification;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    [[self XP_windowForSheet] saveFrameUsingName:fileName];
  }
}

-(void)windowDidMove:(NSNotification*)aNotification;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    [[self XP_windowForSheet] saveFrameUsingName:fileName];
  }
}

// MARK: Panels and Alerts
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(BOOL)prepareSavePanel:(NSSavePanel*)savePanel;
{
  [savePanel setRequiredFileType:[self fileType]];
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
      [self writeToFile:[savePanel filename] ofType:nil];
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

-(XPInteger)__runModalSavePanelAndSetFileName;
{
  XPInteger result;
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  result = [self runModalSavePanel:savePanel];
  if (result == XPModalResponseOK) {
    [self setFileName:[savePanel filename]];
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
  [_window setDelegate:nil];
  // this autorelease (instead of release) is necessary
  // to prevent crashes when the window is closing
  [_window   autorelease];
  [_fileName release];
  [_fileType release];
  _window   = nil;
  _fileName = nil;
  _fileType = nil;
  [super dealloc];
}
#pragma clang diagnostic pop
@end

#else

@implementation NSDocument (CrossPlatform)

-(NSWindow*)XP_windowForSheet;
{
  NSWindow *window = [[[self windowControllers] lastObject] window];
  NSCParameterAssert(window);
  return window;
}

@end

#endif
