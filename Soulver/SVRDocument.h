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

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "XPDocument.h"
#import "SVRDocumentViewController.h"

#if XPSupportsNSDocument >= 1
@interface SVRDocument: NSDocument
#else
@interface SVRDocument: NSDocumentLegacyImplementation
#endif
{
  mm_new   SVRDocumentModelController *_modelController;
  mm_retain SVRDocumentViewController *_viewController;
}

// MARK: Properties
-(SVRDocumentViewController*)viewController;
-(SVRDocumentModelController*)modelController;

// Create everything without Nibs
-(void)makeWindowControllers;

// MARK: NSDocument subclass
-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// MARK: Model Changed Notification
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;

-(NSRect)__newDocumentWindowRect;

@end

#if XPSupportsNSDocument >= 2
@interface SVRDocument (StateRestoration)
+(BOOL)autosavesInPlace;
-(BOOL)canAsynchronouslyWriteToURL:(NSURL*)url
                            ofType:(NSString*)typeName
                  forSaveOperation:(NSSaveOperationType)saveOperation;
@end
#endif
