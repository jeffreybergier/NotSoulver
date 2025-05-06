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

-(NSString*)windowNibName;
{
#ifdef MAC_OS_X_VERSION_10_6
  return @"SVRDocument_X6";
#elif defined(MAC_OS_X_VERSION_10_2)
  return @"SVRDocument_X2";
#else
  return @"SVRDocument_42";
#endif
}

// MARK: NSDocument subclass

-(void)awakeFromNib;
{
  XPURL *fileURL = [self XP_fileURL];

  if ([XPDocument instancesRespondToSelector:@selector(awakeFromNib)]) {
    [super awakeFromNib];
  }
  
  // Subscribe to model updates
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:[[[self viewController] modelController] model]];

  // Load the file
  if ([fileURL XP_isFileURL]) {
    [self readFromURL:fileURL ofType:[self fileType] error:NULL];
  }
}

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

-(void)windowControllerWillLoadNib:(id)windowController;
{
#ifdef XPSupportsNSDocument
  // Setting this name before the NIB loads has better results
  NSString *autosaveName = [self XP_nameForFrameAutosave];
  NSCParameterAssert(windowController);
  if (autosaveName) {
    [windowController setWindowFrameAutosaveName:autosaveName];
  }
#endif
}

-(void)windowControllerDidLoadNib:(id)windowController;
{
  NSWindow *myWindow = [self windowForSheet];
  NSString *autosaveName = [self XP_nameForFrameAutosave];
  // If using real NSDocument, this is already set, so we can check here
  BOOL needsSetAutosaveName = autosaveName && ![[myWindow frameAutosaveName] isEqualToString:autosaveName];
  id previousNextResponder = [myWindow nextResponder];

  NSCParameterAssert(myWindow);
  
  // Add view controller into the responder chain
  [myWindow setNextResponder:[self viewController]];
  if ([self isKindOfClass:[NSResponder class]]) {
    [[self viewController] setNextResponder:(NSResponder*)self];
    [(NSResponder*)self setNextResponder:previousNextResponder];
  } else {
    [[self viewController] setNextResponder:previousNextResponder];
  }
  
  if (needsSetAutosaveName) {
    [myWindow setFrameAutosaveName:autosaveName];
  }
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
#ifndef XPSupportsNSDocument
  [_viewController release];
#endif
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
