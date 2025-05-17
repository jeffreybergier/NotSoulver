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
  NSString *autosaveName = [self XP_nameForFrameAutosave];
  SVRDocumentModelController *modelController = [self modelController];
  SVRDocumentViewController  *viewController  = [self viewController];
  NSWindow *aWindow = [[[NSWindow alloc] initWithContentRect:[self __newDocumentWindowRect]
                                                   styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask)
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO] autorelease];
  id windowController = nil;
  
  // Set frameAutosaveName
  if (autosaveName) {
    [aWindow setFrameAutosaveName:autosaveName];
  } else {
    [aWindow setFrameAutosaveName:@"NewSVRDocument"];
  }
  
  // Make Window Controllers
#if XPSupportsNSDocument >= 1
  windowController = [[[NSWindowController alloc] initWithWindow:aWindow] autorelease];
#endif
  [aWindow setContentView:[viewController view]];
  
  // Configure self
  [self XP_setWindow:aWindow];
  [self XP_addWindowController:windowController];
  
  // Subscribe to model updates
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:[modelController model]];
  
  // Configure responder chain
  [aWindow setNextResponder:viewController];
  [viewController setNextResponder:windowController];
  
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
  NSCParameterAssert(modelController);
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
    diskData = [NSData XP_dataWithContentsOfURL:fileURL];
    isEdited = ![diskData isEqualToData:documentData];
  } else if (documentData == nil || [documentData length] == 0) {
    isEdited = NO;
  } else {
    isEdited = YES;
  }
  [self updateChangeCount:isEdited ? 0 : 2];
}

-(NSRect)__newDocumentWindowRect;
{
  NSRect output = NSZeroRect;
  NSSize screenSize = [[NSScreen mainScreen] frame].size;
  NSSize targetSize = NSMakeSize(500, 500);
  output.origin.y = ceil(screenSize.height / 2) - ceil(targetSize.height / 2);
  output.origin.x = ceil(screenSize.width  / 2) - ceil(targetSize.width  / 2);
  output.size = targetSize;
  return output;
}

-(void)dealloc;
{
  XPLogDebug1(@"DEALLOC: %@", self);
  [_viewController  release];
  [_modelController release];
  _viewController  = nil;
  _modelController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

#if XPSupportsNSDocument >= 2
@implementation SVRDocument (StateRestoration)

+(BOOL)autosavesInPlace;
{
  return YES;
}
-(BOOL)canAsynchronouslyWriteToURL:(NSURL*)url
                            ofType:(NSString*)typeName
                  forSaveOperation:(NSSaveOperationType)saveOperation;
{
  return YES;
}

@end
#endif
