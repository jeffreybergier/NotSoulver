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

NSPoint XPDocumentPointForCascading;

// Because this class is only used in OpenStep
// I will add insturctions for LLVM to ignore
// deprecation warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation NSDocumentLegacyImplementation

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
  _isEdited = NO;
  [self makeWindowControllers];
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
  [self makeWindowControllers];
  
  return self;
}

// MARK: Window Management

-(void)showWindows;
{
  [[self windowForSheet] makeKeyAndOrderFront:self];
}

-(NSWindow*)windowForSheet;
{
  NSCParameterAssert(_window_42);
  return [[_window_42 retain] autorelease];
}

// MARK: One Time Setup

-(void)makeWindowControllers;
{
  NSWindow *myWindow = [self windowForSheet];
  
  if (![self XP_nameForFrameAutosave]) {
    XPDocumentPointForCascading = [myWindow cascadeTopLeftFromPoint:XPDocumentPointForCascading];
  }
  
  // Update window chrome
  [self updateChangeCount:2];
  
  // Set the delegate for -windowShouldClose:
  [myWindow setDelegate:self];
  
  XPLogDebug1(@"makeWindowControllers: %@", self);
}

// MARK: Document Properties

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
{
  NSString *lastPathComponent = [[self fileURL] XP_lastPathComponent];
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
  XPURL    *fileURL  = [self fileURL];

  _isEdited = (change == 2) ? NO : YES;

  if ([fileURL XP_isFileURL]) {
    [myWindow setRepresentedFilename:[fileURL XP_path]];
  } else {
    [myWindow setRepresentedFilename:@""];
  }
  [myWindow setTitle:[self displayName]];
  [myWindow setDocumentEdited:[self isDocumentEdited]];
}

-(XPURL*)fileURL;
{
  return [[_fileURL retain] autorelease];
}

-(void)setFileURL:(XPURL*)fileURL;
{
  if ([fileURL isEqual:_fileURL]) { return; }
  [_fileURL release];
  _fileURL = [fileURL copy];
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

// MARK: NSObject basics

-(XPUInteger)hash;
{
  XPURL *fileURL = [self fileURL];
  if (fileURL) {
    return [fileURL hash];
  } else {
    return [super hash];
  }
}

-(BOOL)isEqual:(id)object;
{
  XPURL *fileURL = [self fileURL];
  if (fileURL && [object isKindOfClass:[XPURL class]]) {
    return [fileURL isEqual:object];
  } else {
    return [super isEqual:object];
  }
}

// MARK: Data reading and writing
-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  XPLogRaise(@"Unimplemented");
  return nil;
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  XPLogRaise(@"Unimplemented");
  return NO;
}

-(BOOL)writeToURL:(XPURL*)__fileURL ofType:(NSString*)__fileType error:(id*)outError;
{
  XPURL    *fileURL  = (__fileURL ) ? __fileURL  : [self fileURL ];
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
  XPURL    *fileURL  = (__fileURL ) ? __fileURL  : [self fileURL ];
  NSString *fileType = (__fileType) ? __fileType : [self fileType];
  if (!fileURL) { return NO; }
  
  data = [NSData XP_dataWithContentsOfURL:fileURL];
  if (!data) { return NO; }

  return [self loadDataRepresentation:data ofType:fileType];
}

// MARK: Menu Handling

-(IBAction)saveDocument:(id)sender;
{
  XPURL *fileURL = [self fileURL];
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
  [self __runModalSavePanel:nil];
}

-(IBAction)revertDocumentToSaved:(id)sender;
{
  XPAlertReturn result = [self __runRevertToSavedAlert];
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

// MARK: Customizations

-(NSString*)__fileExtension;
{
  NSCParameterAssert(_fileExtension);
  return [[_fileExtension retain] autorelease];
}

-(void)__setFileExtension:(NSString*)type;
{
  NSCParameterAssert(type);
  if ([type isEqualToString:_fileExtension]) { return; }
  [_fileExtension release];
  _fileExtension = [type copy];
}

-(BOOL)windowShouldClose:(id)sender;
{
  XPAlertReturn alertResult;
  if (![self isDocumentEdited]) { return YES; }
  alertResult = [self __runUnsavedChangesAlert];
  switch (alertResult) {
    case XPAlertReturnDefault:
      if ([[self fileURL] XP_isFileURL]) {
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

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  SEL menuAction = [menuItem action];
  XPURL *fileURL = [self fileURL];
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

// MARK: Panels and Alerts

-(BOOL)__prepareSavePanel:(NSSavePanel*)savePanel;
{
  [savePanel setRequiredFileType:[self __fileExtension]];
  [savePanel setDirectory:[[NSUserDefaults standardUserDefaults] SVR_savePanelLastDirectory]];
  return YES;
}

-(XPInteger)__runModalSavePanel:(NSSavePanel*)_savePanel;
{
  XPInteger okCancel;
  NSSavePanel *savePanel = (_savePanel) ? _savePanel : [NSSavePanel savePanel];
  [self __prepareSavePanel:savePanel];
  
  okCancel = [savePanel runModal];
  switch (okCancel) {
    case XPModalResponseOK:
      [self writeToURL:(XPURL*)[savePanel filename] ofType:nil error:NULL];
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
  result = [self __runModalSavePanel:savePanel];
  if (result == XPModalResponseOK) {
    [self setFileURL:(XPURL*)[savePanel filename]];
  }
  return result;
}


-(XPAlertReturn)__runUnsavedChangesAlert;
{
  return NSRunAlertPanel([Localized titleClose],
                         [Localized phraseSaveChangesTo],
                         [Localized verbSave],
                         [Localized verbDontSave],
                         [Localized verbCancel],
                         [self displayName]);
}

-(XPAlertReturn)__runRevertToSavedAlert;
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
  // Skipping release for window because it releases itself when closed
  [_window_42 setDelegate:nil];
  [_fileURL   release];
  [_fileType  release];
  [_fileExtension release];
  _window_42 = nil;
  _fileURL   = nil;
  _fileType  = nil;
  _fileExtension = nil;
  [super dealloc];
}

@end
#pragma clang diagnostic pop

#if XPSupportsNSDocument >= 1
@implementation NSDocument (CrossPlatform)
#else
@implementation NSDocumentLegacyImplementation (CrossPlatform)
#endif
-(BOOL)XP_isDocumentEdited;
{
  return [self isDocumentEdited];
}

-(XPURL*)XP_fileURL;
{
#if XPSupportsNSDocument == 1
  return [self fileName];
#else
  return [self fileURL];
#endif
}

-(NSString*)XP_nameForFrameAutosave;
{
  XPURL *fileURL = [self XP_fileURL];
  if (![fileURL XP_isFileURL]) { return nil; }
  return [fileURL XP_path];
}

-(NSWindow*)XP_windowForSheet;
{
#if XPSupportsNSDocument == 1
  NSWindow *window = [[[self windowControllers] lastObject] window];
  NSCParameterAssert(window);
  return window;
#else
  return [self windowForSheet];
#endif
}

-(void)XP_showWindows;
{
  [self showWindows];
}

-(void)XP_setWindow:(NSWindow*)aWindow;
{
#if XPSupportsNSDocument == 0
  NSCParameterAssert(aWindow);
  [_window_42 release];
  _window_42 = [aWindow retain];
#else
  XPLogDebug2(@"%@ ignoring call to XP_setWindow:%@", self, aWindow);
#endif
}

-(void)XP_setFileType:(NSString*)type;
{
  [self setFileType:type];
}

-(void)XP_setFileExtension:(NSString*)type;
{
#if XPSupportsNSDocument == 0
  [self __setFileExtension:type];
#else
  XPLogDebug2(@"%@ ignoring call to XP_setFileExtension:%@", self, type);
#endif
}

-(BOOL)XP_readFromURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(id*)outError;
{
#if XPSupportsNSDocument == 1
  return [self readFromFile:fileURL ofType:fileType];
#else
  return [self readFromURL:fileURL ofType:fileType error:outError];
#endif
}

-(void)XP_addWindowController:(id)windowController;
{
#if XPSupportsNSDocument >= 1
  NSCParameterAssert(windowController);
  [self addWindowController:windowController];
#else
  XPLogDebug(@"%@ XP_addWindowController: Ignoring");
#endif
}
@end

