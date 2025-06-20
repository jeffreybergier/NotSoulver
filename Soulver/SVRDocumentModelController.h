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

extern NSString *const SVRDocumentModelExtension;
/// A version of the data for saving to the disk
/// This version is plain text and unsolved
/// Data format is UTF8 String
extern NSString *const SVRDocumentModelRepDisk;
/// A version of the data that is displayed in the NSTextView
/// This version is styled and has NSTextAttachments for solutions
/// Data format is RTF
extern NSString *const SVRDocumentModelRepDisplay;
/// A version that is used for the pasteboard
/// This version is styled and remove the NSTextAttachments and replaces them with normal text that shows the solutions
/// Data format is RTF
extern NSString *const SVRDocumentModelRepSolved;
/// A version that is used for the pasteboard when the user chooses a custom copy command
/// This version is styled and unsolved
/// Data format is RTF
extern NSString *const SVRDocumentModelRepUnsolved;

typedef NSString* SVRDocumentModelRep;

@interface SVRDocumentModelController: NSObject
{
  mm_new NSTextStorage       *_model;
  mm_new NSTimer             *_waitTimer;
  mm_new NSMutableDictionary *_dataCache;
  
  mm_unretain NSDictionary *__TESTING_stylesForSolution;
  mm_unretain NSDictionary *__TESTING_stylesForPreviousSolution;
  mm_unretain NSDictionary *__TESTING_stylesForError;
  mm_unretain NSDictionary *__TESTING_stylesForText;
}

// MARK: Properties
-(NSTextStorage*)model;
-(NSMutableDictionary*)dataCache;

// MARK: Init
-(id)init;

// MARK: NSTextView Wrapping
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string;

// MARK: NSDocument Support
-(NSData*)dataRepresentationOfType:(SVRDocumentModelRep)type;
-(NSData*)dataRepresentationOfType:(SVRDocumentModelRep)type withRange:(NSRange)range;
/// This method ignores of type parameter and always assumes `SVRDocumentModelRepDisk`
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(SVRDocumentModelRep)type;

// MARK: Private
-(NSData*)__dataRepresentationOfDiskTypeWithRange:(NSRange)range;
-(NSData*)__dataRepresentationOfDisplayTypeWithRange:(NSRange)range;
-(NSData*)__dataRepresentationOfSolvedTypeWithRange:(NSRange)range;
-(NSData*)__dataRepresentationOfUnsolvedTypeWithRange:(NSRange)range;
-(BOOL)__loadDataRepresentationOfDiskType:(NSData*)data;

@end

#ifdef MAC_OS_X_VERSION_10_6
@interface SVRDocumentModelController (TextDelegate) <NSTextViewDelegate>
#else
@interface SVRDocumentModelController (TextDelegate)
#endif

-(void)textDidChange:(NSNotification*)aNotification;
-(void)renderPreservingSelectionInTextView:(NSTextView*)textView;
-(void)__resetWaitTimer:(NSTextView*)sender;
-(void)__waitTimerFired:(NSTimer*)timer;

@end
