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
#import "SVRDocumentModelController.h"
#import "XPCrossPlatform.h"

@interface SVRDocumentViewController: NSResponder
{
  mm_unretain IBOutlet NSTextView *_textView;
  mm_new SVRDocumentModelController *_modelController;
}

// MARK: Init
-(id)init;

// MARK: awakeFromNib
-(void)awakeFromNib;
-(void)themeDidChangeNotification:(NSNotification*)aNotification;

// MARK: IBActions
-(IBAction)keypadAppend:(id)sender;

// MARK: Interface Builder
-(NSTextView*)textView;
-(SVRDocumentModelController*)modelController;
-(IBAction)append:(NSButton*)sender;

// MARK: Private
-(void)__append:(XPInteger)tag;
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;
-(NSDictionary*)__typingAttributes;

@end

@interface SVRDocumentViewController (IBActions)

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(IBAction)copyUnsolved:(id)sender;
-(IBAction)copyUniversal:(id)sender;
-(IBAction)pasteUniversal:(id)sender;
-(BOOL)__copyAttributedStringToPasteBoard:(NSAttributedString*)attributedString;
-(BOOL)__copyUnsolvedStringToUnsolvedPasteboard:(NSAttributedString*)attributedString;

@end
