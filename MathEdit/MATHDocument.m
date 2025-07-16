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

#import "MATHDocument.h"
#import "NSUserDefaults+MathEdit.h"

#ifdef AFF_NSDocumentNone
@implementation NSDocumentLegacyImplementation (MATHDocument)
#else
@implementation NSDocument (MATHDocument)
#endif
-(NSString*)MATH_nameForFrameAutosave;
{
  NSString *fileName = [self fileName];
  if (!fileName) { return nil; }
  XPLogAssrt1([fileName isAbsolutePath], @"[INVALID] fileName(%@)", fileName);
  return fileName;
}
@end

@implementation MATHDocument

// MARK: Properties

-(MATHDocumentViewController*)viewController;
{
  if (!_viewController) {
    _viewController = [[MATHDocumentViewController alloc] initWithModelController:[self modelController]];
  }
  return [[_viewController retain] autorelease];
}

-(MATHDocumentModelController*)modelController;
{
  if (!_modelController) {
    _modelController = [[MATHDocumentModelController alloc] init];
  }
  return [[_modelController retain] autorelease];
}

// Create everything without Nibs

-(void)makeWindowControllers;
{
  static NSPoint MATHDocumentPointForCascading = { 0.0, 0.0 };
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  XPWindowStyleMask windowStyle = (XPWindowStyleMaskTitled
                                 | XPWindowStyleMaskClosable
                                 | XPWindowStyleMaskMiniaturizable
                                 | XPWindowStyleMaskResizable);
  NSRect rect = NSMakeRect(0, 0, 500, 500);
  NSString *autosaveName = [self MATH_nameForFrameAutosave];
  MATHDocumentModelController *modelController = [self modelController];
  MATHDocumentViewController  *viewController  = [self viewController];
  NSWindow *aWindow = [[[NSWindow alloc] initWithContentRect:rect
                                                   styleMask:windowStyle
                                                     backing:NSBackingStoreBuffered
                                                       defer:YES] autorelease];
  XPWindowController *windowController = [XPNewWindowController(aWindow) autorelease];
  
  // Configure basic properties
  [self setWindow:aWindow];
  [self addWindowController:windowController];
  [self overrideWindowAppearance];
  [aWindow setMinSize:NSMakeSize(200, 200)];
  [aWindow setContentView:[viewController view]];
  [aWindow setInitialFirstResponder:[viewController textView]];
  
  // Subscribe to theme and model updates
  [nc addObserver:self
         selector:@selector(modelDidProcessEditingNotification:)
             name:NSTextStorageDidProcessEditingNotification
           object:[modelController model]];
  [nc addObserver:self
         selector:@selector(overrideWindowAppearance)
             name:MATHThemeDidChangeNotificationName
           object:nil];
  
  // This is a bit fiddly, so let me explain.
  // If there is an autosavename we will use and not try to do any cascading.
  // However, if this is the first time the document has been open,
  // it will open in the bottom left of the screen as the autosave name has
  // never saved anything. So here we check if the frame is different before
  // and after setting the autosaveName. If its the same, then we ask the
  // window to center itself. If its different then we just let it be.
  rect = [aWindow frame];
  if (autosaveName) {
    [aWindow setFrameAutosaveName:autosaveName];
  }
  if (NSEqualRects(rect, [aWindow frame])) {
    [aWindow center];
    MATHDocumentPointForCascading = [aWindow cascadeTopLeftFromPoint:MATHDocumentPointForCascading];
  }
  
  // Configure Views/Responder Chains
  // In older systems the view controller is not automatically
  // added to the responder chain. This checks for that and adds it
  if (![windowController respondsToSelector:@selector(setContentViewController:)]) {
    [aWindow setNextResponder:viewController];
    [viewController setNextResponder:windowController];
  }
  
  // Configure legacy XPDocument support
  if ([self isKindOfClass:[NSResponder class]]) {
    [viewController setNextResponder:(NSResponder*)self];
    [super makeWindowControllers];
    [self readFromFile:[self fileName] ofType:[self fileType]];
  }
}

// MARK: NSDocument subclass

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[self modelController] dataRepresentationOfType:type];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  MATHDocumentModelController *modelController = [self modelController];
  XPParameterRaise(modelController);
  return [modelController loadDataRepresentation:data ofType:type];
}

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;
{
  BOOL isEdited = YES;
  NSData *diskData = nil;
  NSData *documentData = [self dataRepresentationOfType:[self fileType]];
  NSString *fileName = [self fileName];
  if (fileName) {
    // TODO: Consider adding error handling here
    diskData = [NSData dataWithContentsOfFile:fileName];
    isEdited = ![diskData isEqualToData:documentData];
  } else if (documentData == nil || [documentData length] == 0) {
    isEdited = NO;
  } else {
    isEdited = YES;
  }
  [self updateChangeCount:isEdited ? XPChangeDone
                                   : XPChangeCleared];
}

-(void)dealloc;
{
  XPLogDebug1(@"<%@>", XPPointerString(self));
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_viewController  release];
  [_modelController release];
  _viewController  = nil;
  _modelController = nil;
  [super dealloc];
}

@end

@implementation MATHDocument (StateRestoration)

+(BOOL)autosavesInPlace;
{
  return YES;
}

+(BOOL)canConcurrentlyReadDocumentsOfType:(NSString*)typeName;
{
  // The hard part of opening a file is rendering the NSAttributedString.
  // This involves reading whether we are in dark mode.
  // It also involves creating NSTextAttachmentCells.
  // Both are main thread only and it shows warnings.
  // Best to just leave this set to NO
  return NO;
}

-(BOOL)canAsynchronouslyWriteToURL:(XPURL*)url
                            ofType:(NSString*)typeName
                  forSaveOperation:(XPSaveOperationType)saveOperation;
{
  // Writing to disk uses just pure NSAttributedString API.
  // Nothing in the document is modified, just copied and then discarded
  // at the end. So returning YES here should be fine.
  return YES;
}

@end

@implementation MATHDocument (DarkMode)
-(void)overrideWindowAppearance;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud MATH_userInterfaceStyle];
  NSWindow *myWindow = [self windowForSheet];
  XPParameterRaise(myWindow);
  [myWindow XP_setAppearanceWithUserInterfaceStyle:style];
}
@end
