//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "XPDocument.h"
#import "NSUserDefaults+MathEdit.h"

// Because this class is only used in OpenStep
// I will add insturctions for LLVM to ignore
// deprecation warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation NSDocumentLegacyImplementation

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
{
  self = [super init];
  XPParameterRaise(self);
  _fileName = nil;
  _fileType = nil;
  _isEdited = NO;
  [self makeWindowControllers];
  return self;
}

-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;
{
  self = [self init];
  
  XPParameterRaise(self);
  XPParameterRaise(fileName);
  XPParameterRaise(fileType);
  
  _fileName  =[fileName copy];
  _fileType = [fileType copy];
  [self makeWindowControllers];
  
  return self;
}

// MARK: Window Management

-(void)makeWindowControllers;
{
  NSWindow *myWindow = [self windowForSheet];
  
  // Update window chrome
  [self updateChangeCount:XPChangeCleared];
  
  // Set the delegate for -windowShouldClose:
  [myWindow setDelegate:self];
  
  // Announce
  XPLogDebug(@"");
}

-(void)showWindows;
{
  [[self windowForSheet] makeKeyAndOrderFront:self];
}

-(NSWindow*)windowForSheet;
{
  XPParameterRaise(_window_42);
  return [[_window_42 retain] autorelease];
}

-(void)setWindow:(NSWindow *)window;
{
  XPParameterRaise(window);
  [_window_42 release];
  _window_42 = [window retain];
}

// MARK: Document Properties

-(void)updateChangeCount:(XPDocumentChangeType)change;
{
  NSWindow *myWindow  = [self windowForSheet];
  NSString *fileName  = [self fileName];

  _isEdited = (change == XPChangeCleared) ? NO : YES;

  if ([fileName isAbsolutePath]) {
    [myWindow setRepresentedFilename:fileName];
  } else {
    [myWindow setRepresentedFilename:@""];
  }
  [myWindow setTitle:[self displayName]];
  [myWindow setDocumentEdited:[self isDocumentEdited]];
}

/// Override to update window status
-(BOOL)isDocumentEdited;
{
  return _isEdited;
}

-(NSString*)fileName;
{
  return [[_fileName retain] autorelease];
}

-(void)setFileName:(NSString*)fileName;
{
  XPLogAssrt1([fileName isAbsolutePath], @"[INVALID] fileName(%@)", fileName);
  if ([fileName isEqual:_fileName]) { return; }
  [_fileName release];
  _fileName = [fileName copy];
}

-(NSString*)fileType;
{
  return [[_fileType retain] autorelease];
}

-(void)setFileType:(NSString*)type;
{
  XPLogAssrt1([type isKindOfClass:[NSString class]], @"[INVALID] type(%@)", type);
  if ([type isEqualToString:_fileType]) { return; }
  [_fileType release];
  _fileType = [type copy];
}

-(NSString*)displayName;
{
  NSString *lastPathComponent = [[self fileName] lastPathComponent];
  return (lastPathComponent) ? lastPathComponent : [Localized titleUntitled];
}

// MARK: NSObject basics

-(XPUInteger)hash;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    return [fileName hash];
  } else {
    return [super hash];
  }
}

-(BOOL)isEqual:(id)object;
{
  NSString *fileName = [self fileName];
  if (fileName && [object isKindOfClass:[NSString class]]) {
    return [fileName isEqual:object];
  } else {
    return [super isEqual:object];
  }
}

// MARK: MUST IMPLEMENT loading methods

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

// MARK: Data reading and writing

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

-(BOOL)readFromFile:(NSString*)__fileName ofType:(NSString*)__type;
{
  NSData   *data = nil;
  NSString *fileName = (__fileName) ? __fileName : [self fileName];
  NSString *fileType = (__type)     ? __type     : [self fileType];
  if (!fileName) { return NO; }
  
  data = [NSData dataWithContentsOfFile:fileName];
  if (!data) { return NO; }

  return [self loadDataRepresentation:data ofType:fileType];
}

// MARK: Menu Handling

-(IBAction)saveDocument:(id)sender;
{
  NSString *fileName = [self fileName];
  if (fileName) {
    [self writeToFile:nil ofType:nil];
  } else {
    [self __runModalSavePanelAndSetFileURL];
  }
  [self updateChangeCount:XPChangeCleared];
}

-(IBAction)saveDocumentAs:(id)sender;
{
  [self __runModalSavePanelAndSetFileURL];
  [self updateChangeCount:XPChangeCleared];
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
      [self readFromFile:nil ofType:nil];
      break;
    case XPAlertReturnAlternate:
      XPLogDebug(@"User Cancelled");
      break;
    case XPAlertReturnOther:
    case XPAlertReturnError:
    default:
      XPLogAssrt1(NO, @"XPAlertReturn(%d) INVALID", (int)result);
  }
  [self updateChangeCount:XPChangeCleared];
}

// MARK: Customizations

-(NSString*)__requiredFileType;
{
  XPParameterRaise(_requiredFileType);
  return [[_requiredFileType retain] autorelease];
}

-(void)__setRequiredFileType:(NSString*)type;
{
  XPParameterRaise(type);
  if ([type isEqualToString:_requiredFileType]) { return; }
  [_requiredFileType release];
  _requiredFileType = [type copy];
}

-(BOOL)windowShouldClose:(id)sender;
{
  XPAlertReturn alertResult;
  if (![self isDocumentEdited]) { return YES; }
  alertResult = [self __runUnsavedChangesAlert];
  switch (alertResult) {
    case XPAlertReturnDefault:
      if ([[self fileName] isAbsolutePath]) {
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
      XPLogAssrt1(NO, @"XPAlertReturn(%d) INVALID", (int)alertResult);
      return NO;
  }
}

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  SEL menuAction = [menuItem action];
  NSString *fileName = [self fileName];
  if        (menuAction == @selector(saveDocument:)) {
    return fileName == nil || [self isDocumentEdited];
  } else if (menuAction == @selector(saveDocumentAs:)) {
    return fileName != nil;
  } else if (menuAction == @selector(saveDocumentTo:)) {
    return fileName != nil;
  } else if (menuAction == @selector(revertDocumentToSaved:)) {
    return fileName != nil && [self isDocumentEdited];
  }
  return NO;
}

// MARK: Panels and Alerts

-(BOOL)__prepareSavePanel:(NSSavePanel*)savePanel;
{
  [savePanel setRequiredFileType:[self __requiredFileType]];
  [savePanel setDirectory:[[NSUserDefaults standardUserDefaults] MATH_savePanelLastDirectory]];
  return YES;
}

-(XPInteger)__runModalSavePanel:(NSSavePanel*)_savePanel;
{
  XPModalResponse okCancel;
  NSSavePanel *savePanel = (_savePanel) ? _savePanel : [NSSavePanel savePanel];
  [self __prepareSavePanel:savePanel];
  
  okCancel = [savePanel runModal];
  switch (okCancel) {
    case XPModalResponseOK:
      [self writeToFile:[savePanel filename] ofType:nil];
      break;
    case XPModalResponseCancel:
      XPLogDebug(@"User Cancelled");
      break;
    default:
      XPLogAssrt1(NO, @"NSModalResponse(%d) INVALID", (int)okCancel);
      break;
  }
  [[NSUserDefaults standardUserDefaults] MATH_setSavePanelLastDirectory:[savePanel directory]];
  return okCancel;
}

-(XPInteger)__runModalSavePanelAndSetFileURL;
{
  XPModalResponse result;
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  result = [self __runModalSavePanel:savePanel];
  if (result == XPModalResponseOK) {
    [self setFileName:[savePanel filename]];
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
  XPLogExtra1(@"<%@>", XPPointerString(self));
  // Skipping release for window because it releases itself when closed
  [_fileName  release];
  [_fileType  release];
  [_requiredFileType release];
  _window_42 = nil;
  _fileName  = nil;
  _fileType  = nil;
  _requiredFileType = nil;
  [super dealloc];
}

@end
#pragma clang diagnostic pop
