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
  NSString *fileName = [self fileName];

  if ([XPDocument instancesRespondToSelector:@selector(awakeFromNib)]) {
    [super awakeFromNib];
  }
  
  // Subscribe to model updates
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:[[[self viewController] modelController] model]];

  // Load the file
  if ([fileName isAbsolutePath]) {
    [self readFromFile:fileName ofType:[self fileType]];
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

-(void)windowControllerDidLoadNib:(id)windowController;
{
  NSWindow *window = [self XP_windowForSheet];
  NSString *fileName = [self fileName];
  
  // Add view controller into the responder chain
  id previousNextResponder = [window nextResponder];
  [window setNextResponder:[self viewController]];
  if ([self isKindOfClass:[NSResponder class]]) {
    [[self viewController] setNextResponder:(NSResponder*)self];
    [(NSResponder*)self setNextResponder:previousNextResponder];
  } else {
    [[self viewController] setNextResponder:previousNextResponder];
  }
  
  // Set the autosave name.
  // This will probably need to be wrapped in a XPSupportsNSDocument check
  if (fileName) {
    [[self XP_windowForSheet] setFrameAutosaveName:fileName];
  }
}

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;
{
  BOOL isEdited = YES;
  NSData *diskData = nil;
  NSData *documentData = [self dataRepresentationOfType:[self fileType]];
  NSString *fileName = [self fileName];
  if ([fileName isAbsolutePath]) {
    diskData = [NSData dataWithContentsOfFile:fileName];
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
