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

#import "NSUserDefaults+MathEdit.h"
#import "MATHSolver.h"
#import "MATHDocumentModelController.h"

NSString *const SVRDocumentModelExtension   = @"mtxt";
NSString *const SVRDocumentModelRepDisk     = @"com.saturdayapps.mathedit.plain";
NSString *const SVRDocumentModelRepDisplay  = @"com.saturdayapps.mathedit.display";
NSString *const SVRDocumentModelRepSolved   = @"com.saturdayapps.mathedit.solved";
NSString *const SVRDocumentModelRepUnsolved = @"com.saturdayapps.mathedit.unsolved";

@implementation SVRDocumentModelController

// MARK: Properties
-(NSTextStorage*)model;
{
  return [[_model retain] autorelease];
}

-(NSMutableDictionary*)dataCache;
{
  return [[_dataCache retain] autorelease];
}

// MARK: Init
-(id)init;
{
  self = [super init];
  XPParameterRaise(self);
  
  _model = [NSTextStorage new];
  _dataCache = [NSMutableDictionary new];
  _waitTimer = nil;
  
  __TESTING_stylesForSolution = nil;
  __TESTING_stylesForPreviousSolution = nil;
  __TESTING_stylesForError = nil;
  __TESTING_stylesForText = nil;
  
  return self;
}

// MARK: NSTextView Wrapping
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string;
{
  NSTextStorage *model = [self model];
  [model beginEditing];
  [model replaceCharactersInRange:range withString:string];
  [model endEditing];
  [self textDidChange:nil];
}

// MARK: NSDocument Support
-(NSData*)dataRepresentationOfType:(SVRDocumentModelRep)type withRange:(NSRange)range;
{
  XPParameterRaise(type);
  if ([type isEqualToString:SVRDocumentModelRepDisk]) {
    return [self __dataRepresentationOfDiskTypeWithRange:range];
  } else if ([type isEqualToString:SVRDocumentModelRepDisplay]) {
    return [self __dataRepresentationOfDisplayTypeWithRange:range];
  } else if ([type isEqualToString:SVRDocumentModelRepSolved]) {
    return [self __dataRepresentationOfSolvedTypeWithRange:range];
  } else if ([type isEqualToString:SVRDocumentModelRepUnsolved]) {
    return [self __dataRepresentationOfUnsolvedTypeWithRange:range];
  } else {
    XPLogAssrt1(NO, @"[UNKNOWN] SVRDocumentModelRep(%@)", type);
    return nil;
  }
}

-(NSData*)dataRepresentationOfType:(SVRDocumentModelRep)type;
{
  return [self dataRepresentationOfType:type withRange:XPNotFoundRange];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(SVRDocumentModelRep)type;
{
  if ([type isEqualToString:SVRDocumentModelRepDisk]) {
    return [self __loadDataRepresentationOfDiskType:data];
  } else {
    XPLogAssrt1(NO, @"[UNKNOWN] SVRDocumentModelRep(%@)", type);
    return NO;
  }
}

// MARK: Private

-(NSData*)__dataRepresentationOfDiskTypeWithRange:(NSRange)range;
{
  NSMutableDictionary *dataCache = nil;
  NSString *key = nil;
  NSData *output = nil;
  if (XPIsNotFoundRange(range)) {
    // If no range provided, use fast path with caching
    dataCache = [self dataCache];
    key = [[self model] string];
    output = [dataCache objectForKey:key];
    if (output) {
      XPLogExtra(@"Cache Hit");
      return output;
    }
    if ([dataCache count] > 20) {
      XPLogDebug(@"Cache Clear");
      [dataCache removeAllObjects];
    }
    XPLogExtra(@"Cache Miss");
    output = [[[SVRSolver replacingAttachmentsWithOriginalCharacters:[self model]] string] dataUsingEncoding:NSUTF8StringEncoding];
    [dataCache setObject:output forKey:key];
    return output;
  } else {
    // If a range is provided, do the work slowly with no caching
    output = [[[SVRSolver replacingAttachmentsWithOriginalCharacters:[[self model] attributedSubstringFromRange:range]] string] dataUsingEncoding:NSUTF8StringEncoding];
    XPLogAssrt(output, @"output was NIL");
    return output;
  }
}

-(NSData*)__dataRepresentationOfDisplayTypeWithRange:(NSRange)_range;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSData *output = [[self model] RTFFromRange:range documentAttributes:XPRTFDocumentAttributes];
  XPLogAssrt(output, @"output was NIL");
  return output;
}

-(NSData*)__dataRepresentationOfSolvedTypeWithRange:(NSRange)_range;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSAttributedString *original = [[self model] attributedSubstringFromRange:range];
  NSAttributedString *solved = [SVRSolver replacingAttachmentsWithStringValue:original];
  NSData *output = [solved RTFFromRange:NSMakeRange(0, [solved length])
                     documentAttributes:XPRTFDocumentAttributes];
  XPLogAssrt(output, @"output was NIL");
  return output;
}

-(NSData*)__dataRepresentationOfUnsolvedTypeWithRange:(NSRange)_range;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSAttributedString *original = [[self model] attributedSubstringFromRange:range];
  NSAttributedString *unsolved = [SVRSolver replacingAttachmentsWithOriginalCharacters:original];
  NSData *output = [unsolved RTFFromRange:NSMakeRange(0, [unsolved length])
                       documentAttributes:XPRTFDocumentAttributes];
  XPLogAssrt(output, @"output was NIL");
  return output;
}

-(BOOL)__loadDataRepresentationOfDiskType:(NSData*)data;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  BOOL success = NO;
  NSTextStorage *model = [self model];
  NSString *string = [[[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding] autorelease];
  if (string) {
    // TODO: Figure out how I can combine this with waitTimerFired:
    XPLogDebug(@"Rendering");
    [model beginEditing];
    [[model mutableString] setString:string];
    [SVRSolver solveAttributedString:model
                      solutionStyles:__TESTING_stylesForSolution         ? __TESTING_stylesForSolution         : [ud MATH_stylesForSolution        ]
              previousSolutionStyles:__TESTING_stylesForPreviousSolution ? __TESTING_stylesForPreviousSolution : [ud MATH_stylesForPreviousSolution]
                         errorStyles:__TESTING_stylesForError            ? __TESTING_stylesForError            : [ud MATH_stylesForError           ]
                          textStyles:__TESTING_stylesForText             ? __TESTING_stylesForText             : [ud MATH_stylesForText            ]];
    [model endEditing];
    success = YES;
  }
  return success;
}

-(void)dealloc;
{
  XPLogDebug1(@"<%@>", XPPointerString(self));
  [_waitTimer invalidate];
  [_waitTimer release];
  [_model release];
  [_dataCache release];
  _dataCache = nil;
  _waitTimer = nil;
  _model = nil;
  [super dealloc];
}

@end


@implementation SVRDocumentModelController (TextDelegate)

-(void)textDidChange:(NSNotification*)aNotification;
{
  NSTextView *textView = [aNotification object];
  XPLogAssrt1([textView isKindOfClass:[NSTextView class]], @"%@ not a text view", textView);
  [self __resetWaitTimer:textView];
}

-(void)renderPreservingSelectionInTextView:(NSTextView*)textView;
{
  NSUserDefaults *ud   = [NSUserDefaults standardUserDefaults];
  NSTextStorage *model = [self model];
  NSRange selection = XPNotFoundRange;
  
  XPParameterRaise(textView);
  
  // Get current selection
  selection = [textView selectedRange];
  
  // Solve the string
  [model beginEditing];
  [SVRSolver solveAttributedString:model
                    solutionStyles:__TESTING_stylesForSolution         ? __TESTING_stylesForSolution         : [ud MATH_stylesForSolution        ]
            previousSolutionStyles:__TESTING_stylesForPreviousSolution ? __TESTING_stylesForPreviousSolution : [ud MATH_stylesForPreviousSolution]
                       errorStyles:__TESTING_stylesForError            ? __TESTING_stylesForError            : [ud MATH_stylesForError           ]
                        textStyles:__TESTING_stylesForText             ? __TESTING_stylesForText             : [ud MATH_stylesForText            ]];
  [model endEditing];
  
  // Restore selection
  [textView setSelectedRange:selection];
}

-(void)__resetWaitTimer:(NSTextView*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [_waitTimer invalidate];
  [_waitTimer release];
  _waitTimer = [NSTimer scheduledTimerWithTimeInterval:[ud MATH_waitTimeForRendering]
                                                target:self
                                              selector:@selector(__waitTimerFired:)
                                              userInfo:[NSDictionary dictionaryWithObject:sender forKey:@"TextView"]
                                               repeats:NO];
  [_waitTimer retain];
}

-(void)__waitTimerFired:(NSTimer*)timer;
{

  NSTextView *textView = [[timer userInfo] objectForKey:@"TextView"];
  XPLogAssrt1([textView isKindOfClass:[NSTextView class]], @"%@ not a text view", textView);
  [self renderPreservingSelectionInTextView:textView];
  [timer invalidate];
}

@end
