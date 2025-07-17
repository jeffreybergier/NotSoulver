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

// MARK: Private Categories

@interface NSObject (MATHDocument)
-(NSString*)MATH_URLPath;
@end

@interface NSData (MATHDocument)
+(NSData*)MATH_dataWithContentsFileObject:(id)fileObject error:(XPErrorPointer)errorPtr;
-(BOOL)MATH_writeToFileObject:(id)fileObject error:(XPErrorPointer)errorPtr;
@end

@implementation NSObject (MATHDocument)
-(NSString*)MATH_URLPath;
{
  Class URLClass = NSClassFromString(@"NSURL");
  if (URLClass && [self isKindOfClass:URLClass]) {
    return [self performSelector:@selector(path)];
  } else if ([self isKindOfClass:[NSString class]]) {
    return (NSString*)self;
  } else {
    XPLogRaise1(@"[UNKNOWN] object(%@)", self);
    return nil;
  }
}
@end

@implementation NSData (MATHDocument)

+(NSData*)MATH_dataWithContentsFileObject:(id)fileObject error:(XPErrorPointer)errorPtr;
{
#ifdef AFF_NSDocumentNoURL
  XPLogAssrt1([fileObject isKindOfClass:[NSString class]], @"[Not a String] fileObject(%@)", fileObject);
  return [self dataWithContentsOfFile:fileObject];
#else
  XPLogAssrt1([fileObject isKindOfClass:[NSURL class]], @"[Not a URL] fileObject(%@)", fileObject);
  return [self dataWithContentsOfURL:fileObject options:0 error:errorPtr];
#endif
}

-(BOOL)MATH_writeToFileObject:(id)fileObject error:(XPErrorPointer)errorPtr;
{
#ifdef AFF_NSDocumentNoURL
  XPLogAssrt1([fileObject isKindOfClass:[NSString class]], @"[Not a String] fileObject(%@)", fileObject);
  return [self writeToFile:fileObject atomically:YES];
#else
  XPLogAssrt1([fileObject isKindOfClass:[NSURL class]], @"[Not a URL] fileObject(%@)", fileObject);
  return [self writeToURL:fileObject options:XPDataWritingAtomic error:errorPtr];
#endif
}

@end

// MARK: MathDocument Implementation

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
  [self MATH_addWindowController:windowController];
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
#ifdef AFF_NSDocumentNone
  [viewController setNextResponder:self];
  [super makeWindowControllers];
  [self readFromFile:[self MATH_fileObject] ofType:[self fileType]];
#endif
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
  id fileObject = [self MATH_fileObject];
  if (fileObject) {
    // TODO: Consider adding error handling here
    diskData = [NSData MATH_dataWithContentsFileObject:fileObject error:NULL];
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

-(BOOL)canAsynchronouslyWriteToURL:(id)url
                            ofType:(NSString*)typeName
                  forSaveOperation:(XPSaveOperationType)saveOperation;
{
  // Writing to disk uses just pure NSAttributedString API.
  // Nothing in the document is modified, just copied and then discarded
  // at the end. So returning YES here should be fine.
  return YES;
}

@end

// MARK: XPDocument Compatibility Category

@implementation MATHDocument (DarkMode)
-(void)overrideWindowAppearance;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud MATH_userInterfaceStyle];
  // TODO: Implement window for sheet for older versions of mac os x
  NSWindow *myWindow = [self MATH_windowForSheet];
  XPParameterRaise(myWindow);
  [myWindow XP_setAppearanceWithUserInterfaceStyle:style];
}
@end

#ifdef AFF_NSDocumentNone
@interface NSDocumentLegacyImplementation (OpenStepSilenceWarning)
-(id)windowControllers;
@end
#endif

#ifdef AFF_NSDocumentNone
@implementation NSDocumentLegacyImplementation (MATHDocument)
#else
@implementation NSDocument (MATHDocument)
#endif

-(id)MATH_initWithContentsOfFileObject:(id)fileObject
                                ofType:(NSString*)typeName
                                 error:(XPErrorPointer)outError;
{
#ifdef AFF_NSDocumentNoURL
  return [self initWithContentsOfFile:fileObject ofType:typeName];
#else
  return [self initWithContentsOfURL:fileObject ofType:typeName error:outError];
#endif
}

-(id)MATH_fileObject;
{
#ifdef AFF_NSDocumentNoURL
  NSString *output = [self fileName];
  if (!output) { return nil; }
  XPLogAssrt1([output isAbsolutePath], @"[INVALID] fileName(%@)", output);
  return [self fileName];
#else
  NSURL *output = [self fileURL];
  if (!output) { return nil; }
  XPLogAssrt1([output isFileURL], @"[INVALID] fileURL(%@)", output);
  return [self fileURL];
#endif
}

-(NSString*)MATH_nameForFrameAutosave;
{
  id fileName = [self MATH_fileObject];
  if (!fileName) { return nil; }
  return [fileName MATH_URLPath];
}

-(NSString*)MATH_requiredFileType;
{
#ifdef AFF_NSDocumentNone
  return [self __requiredFileType];
#else
  return nil;
#endif
}

-(NSWindow*)MATH_windowForSheet;
{
  // In Jaguar this method did not exist
  SEL windowForSheet = @selector(windowForSheet);
  NSWindow *output = nil;
  if ([self respondsToSelector:windowForSheet]) {
    output = [self performSelector:windowForSheet];
  } else {
    output = [[[self windowControllers] lastObject] window];
  }
  XPParameterRaise(output);
  return output;
}

-(void)MATH_addWindowController:(XPWindowController*)aWindowController;
{
#ifndef AFF_NSDocumentNone
  [self addWindowController:aWindowController];
#endif
}

-(void)MATH_setRequiredFileType:(NSString*)type;
{
#ifdef AFF_NSDocumentNone
  [self __setRequiredFileType:type];
#endif
}

@end
