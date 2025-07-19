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

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

extern NSString *const MATHDocumentModelExtension;
/// A version of the data for saving to the disk
/// This version is plain text and unsolved
/// Data format is UTF8 String
extern NSString *const MATHDocumentModelRepDisk;
/// A version of the data that is displayed in the NSTextView
/// This version is styled and has NSTextAttachments for solutions
/// Data format is RTF
extern NSString *const MATHDocumentModelRepDisplay;
/// A version that is used for the pasteboard
/// This version is styled and remove the NSTextAttachments and replaces them with normal text that shows the solutions
/// Data format is RTF
extern NSString *const MATHDocumentModelRepSolved;
/// A version that is used for the pasteboard when the user chooses a custom copy command
/// This version is styled and unsolved
/// Data format is RTF
extern NSString *const MATHDocumentModelRepUnsolved;

typedef NSString* MATHDocumentModelRep;

@interface MATHDocumentModelController: NSObject
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
-(void)replaceCharactersInRange:(NSRange)range
                     withString:(NSString *)string
  preservingSelectionInTextView:(NSTextView*)textView;

// MARK: NSDocument Support
-(NSData*)dataOfType:(NSString*)typeName error:(XPErrorPointer)outError;
-(NSData*)dataOfType:(NSString*)typeName range:(NSRange)range error:(XPErrorPointer)outError;
-(BOOL)readFromData:(NSData*)data ofType:(MATHDocumentModelRep)typeName error:(XPErrorPointer)outError;

// MARK: Private
-(NSData*)__dataOfDiskRepWithRange:(NSRange)range error:(XPErrorPointer)outError;
-(NSData*)__dataOfDisplayRepWithRange:(NSRange)range error:(XPErrorPointer)outError;
-(NSData*)__dataOfModelRepSolvedWithRange:(NSRange)range error:(XPErrorPointer)outError;
-(NSData*)__dataOfModelRepUnsolvedWithRange:(NSRange)range error:(XPErrorPointer)outError;
-(BOOL)__readFromData:(NSData*)data ofType:(NSString*)typeName error:(XPErrorPointer)outError;
-(BOOL)__solveEditingModelInPlace:(NSTextStorage*)model error:(XPErrorPointer)outError;

@end

#ifdef MAC_OS_X_VERSION_10_6
@interface MATHDocumentModelController (TextDelegate) <NSTextViewDelegate>
#else
@interface MATHDocumentModelController (TextDelegate)
#endif

-(void)textDidChange:(NSNotification*)aNotification;
-(BOOL)renderPreservingSelectionInTextView:(NSTextView*)textView
                                     error:(XPErrorPointer)outError;
-(void)__resetWaitTimer:(NSTextView*)sender;
-(void)__waitTimerFired:(NSTimer*)timer;

@end
