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

#import "SVRDocument.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRDocument

// MARK: Properties

-(SVRDocumentViewController*)viewController;
{
  if (!_viewController) {
    _viewController = [[SVRDocumentViewController alloc] initWithModelController:[self modelController]];
  }
  return [[_viewController retain] autorelease];
}

-(SVRDocumentModelController*)modelController;
{
  if (!_modelController) {
    _modelController = [[SVRDocumentModelController alloc] init];
  }
  return [[_modelController retain] autorelease];
}

// Create everything without Nibs

-(void)makeWindowControllers;
{
  static NSPoint SVRDocumentPointForCascading = { 0.0, 0.0 };
  SEL XP_setContentViewController = @selector(setContentViewController:);
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  XPWindowStyleMask windowStyle = (XPWindowStyleMaskTitled
                                 | XPWindowStyleMaskClosable
                                 | XPWindowStyleMaskMiniaturizable
                                 | XPWindowStyleMaskResizable);
  NSRect rect = NSMakeRect(0, 0, 500, 500);
  NSString *autosaveName = [self XP_nameForFrameAutosave];
  SVRDocumentModelController *modelController = [self modelController];
  SVRDocumentViewController  *viewController  = [self viewController];
  NSWindow *aWindow = [[[NSWindow alloc] initWithContentRect:rect
                                                   styleMask:windowStyle
                                                     backing:NSBackingStoreBuffered
                                                       defer:YES] autorelease];
  XPWindowController *windowController = [XPNewWindowController(aWindow) autorelease];
  
  // Configure Window Size and Location
  [aWindow setMinSize:NSMakeSize(200, 200)];
  
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
    SVRDocumentPointForCascading = [aWindow cascadeTopLeftFromPoint:SVRDocumentPointForCascading];
  }
  
  // Set dark mode or light mode
  [self overrideWindowAppearance];
  
  // Subscribe to model updates
  [nc addObserver:self
         selector:@selector(modelDidProcessEditingNotification:)
             name:NSTextStorageDidProcessEditingNotification
           object:[modelController model]];
  [nc addObserver:self
         selector:@selector(overrideWindowAppearance)
             name:SVRThemeDidChangeNotificationName
           object:nil];
  
  // Configure Views/Responder Chains
  [self XP_setWindow:aWindow];
  [self XP_addWindowController:windowController];
  if ([windowController respondsToSelector:XP_setContentViewController]) {
    // Newer systems manage this for you
    [windowController performSelector:XP_setContentViewController
                           withObject:viewController];
  } else {
    // Older systems, this needs to be configured manually
    [aWindow setContentView:[viewController view]];
    [aWindow setNextResponder:viewController];
    [viewController setNextResponder:windowController];
  }
  
  // Configure legacy XPDocument support
  if ([self isKindOfClass:[NSResponder class]]) {
    [viewController setNextResponder:(NSResponder*)self];
    [super makeWindowControllers];
    [self XP_readFromURL:[self XP_fileURL] ofType:[self fileType] error:NULL];
  }
}

// MARK: NSDocument subclass

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[self modelController] dataRepresentationOfType:type];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  SVRDocumentModelController *modelController = [self modelController];
  XPParameterRaise(modelController);
  return [modelController loadDataRepresentation:data ofType:type];
}

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;
{
  BOOL isEdited = YES;
  NSData *diskData = nil;
  NSData *documentData = [self dataRepresentationOfType:[self fileType]];
  XPURL *fileURL = [self XP_fileURL];
  if ([fileURL XP_isFileURL]) {
    // TODO: Consider adding error handling here
    diskData = [NSData XP_dataWithContentsOfURL:fileURL error:NULL];
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
  [_viewController  release];
  [_modelController release];
  _viewController  = nil;
  _modelController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

@implementation SVRDocument (StateRestoration)

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

@implementation SVRDocument (DarkMode)
-(void)overrideWindowAppearance;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud SVR_userInterfaceStyle];
  NSWindow *myWindow = [self XP_windowForSheet];
  XPParameterRaise(myWindow);
  [myWindow XP_setAppearanceWithUserInterfaceStyle:style];
}
@end
