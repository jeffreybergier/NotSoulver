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
  return [[_viewController retain] autorelease];
}

// Create everything without Nibs

-(void)makeWindowControllers;
{
  NSWindow *aWindow = [[[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 600, 400)
                                                   styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask)
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO] autorelease];
  NSWindowController      *windowController = [[[NSWindowController        alloc] initWithWindow:aWindow] autorelease];
  SVRDocumentViewController *viewController = [[[SVRDocumentViewController alloc] init]                  autorelease];
  XPURL *fileURL = [self XP_fileURL];
  NSString *autosaveName = [self XP_nameForFrameAutosave];
  
  // Configure IVARS
  _viewController = [viewController retain];
  
  // Subscribe to model updates
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:[[viewController modelController] model]];
  
  // Make Window Controllers
  [aWindow setContentView:[viewController view]];
  
  // Set frameAutosaveName
  if (autosaveName) {
    [aWindow setFrameAutosaveName:autosaveName];
  }
  
  // Load Data
  if ([fileURL XP_isFileURL]) {
    [self XP_readFromURL:fileURL ofType:[self fileType] error:NULL];
  }
  
  // Configure responder chain
  [aWindow setNextResponder:[self viewController]];
  if ([self isKindOfClass:[NSResponder class]]) {
    [viewController setNextResponder:(NSResponder*)self];
    [(NSResponder*)self setNextResponder:windowController];
  } else {
    [viewController setNextResponder:windowController];
  }
  
  // Configure self
  [self addWindowController:windowController];
}

// MARK: NSDocument subclass

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[[self viewController] modelController] dataRepresentationOfType:type];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  SVRDocumentModelController *modelController = [[self viewController] modelController];
  if (!modelController) {
    // NSDocument loads the data before loading the NIB
    return YES;
  }
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

-(void)dealloc;
{
  XPLogDebug1(@"DEALLOC: %@", self);
#if XPSupportsNSDocument == 0
  // Nib Lifecycle differs when using NSDocument
  [_viewController release];
#endif
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

@implementation SVRDocument (StateRestoration)

-(BOOL)autosavesInPlace;
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
