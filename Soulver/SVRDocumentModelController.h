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

@interface SVRDocumentModelController: NSObject
{
  mm_new      NSTextStorage       *_model;
  mm_new      NSTimer             *_waitTimer;
  mm_new      NSMutableDictionary *_dataCache;
  mm_unretain NSTextView          *_textView;
  
  mm_unretain NSDictionary *__TESTING_stylesForSolution;
  mm_unretain NSDictionary *__TESTING_stylesForPreviousSolution;
  mm_unretain NSDictionary *__TESTING_stylesForError;
  mm_unretain NSDictionary *__TESTING_stylesForText;
}

// MARK: Properties
-(NSTextStorage*)model;
-(NSMutableDictionary*)dataCache;
-(NSTextView*)textView;
-(void)setTextView:(NSTextView*)textView;

// MARK: Init
-(id)init;

// MARK: NSDocument Support
-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// MARK: Usage
-(void)appendCharacter:(NSString*)aString;
-(void)backspaceCharacter;
-(void)backspaceLine;
-(void)backspaceAll;
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string;
-(void)deleteCharactersInRange:(NSRange)range;

@end

#ifdef MAC_OS_X_VERSION_10_6
@interface SVRDocumentModelController (TextDelegate) <NSTextViewDelegate>
#else
@interface SVRDocumentModelController (TextDelegate)
#endif

-(void)resetWaitTimer;
-(void)waitTimerFired:(NSTimer*)timer;
-(void)textDidChange:(NSNotification*)notification;

@end
