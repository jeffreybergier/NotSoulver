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

#import "SVRDocumentModelController.h"
#import "NSUserDefaults+Soulver.h"
#import "SVRSolver.h"

NSString *const SVRDocumentModelRepDisk     = @"nsv";
NSString *const SVRDocumentModelRepDisplay  = @"SVRDocumentModelRepDisplay";
NSString *const SVRDocumentModelRepSolved   = @"SVRDocumentModelRepSolved";
NSString *const SVRDocumentModelRepUnsolved = @"SVRDocumentModelRepUnsolved";

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

-(NSTextView*)textView;
{
  return [[_textView retain] autorelease];
}

-(void)setTextView:(NSTextView*)textView;
{
  _textView = textView;
}

// MARK: Init
-(id)init;
{
  self = [super init];
  NSCParameterAssert(self);
  
  _model = [NSTextStorage new];
  _dataCache = [NSMutableDictionary new];
  _textView = nil;
  _waitTimer = nil;
  
  __TESTING_stylesForSolution = nil;
  __TESTING_stylesForPreviousSolution = nil;
  __TESTING_stylesForError = nil;
  __TESTING_stylesForText = nil;
  
  return self;
}

// MARK: NSDocument Support
-(NSData*)dataRepresentationOfType:(SVRDocumentModelRep)type withRange:(NSRange)range;
{
  if ([type isEqualToString:SVRDocumentModelRepDisk]) {
    return [self __dataRepresentationOfDiskTypeWithRange:range];
  } else if ([type isEqualToString:SVRDocumentModelRepDisplay]) {
    return [self __dataRepresentationOfDisplayTypeWithRange:range];
  } else if ([type isEqualToString:SVRDocumentModelRepSolved]) {
    return [self __dataRepresentationOfSolvedTypeWithRange:range];
  } else if ([type isEqualToString:SVRDocumentModelRepUnsolved]) {
    return [self __dataRepresentationOfUnsolvedTypeWithRange:range];
  } else {
    XPLogRaise1(@"Unknown Type: %@", type);
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
    XPLogRaise1(@"Unknown Type: %@", type);
    return NO;
  }
}

// MARK: Usage
-(void)appendCharacter:(NSString*)aString;
{
  NSTextStorage *model = [self model];
  [ model beginEditing];
  [[model mutableString] appendString:aString];
  [ model endEditing];
  [self textDidChange:nil];
}

-(void)backspaceCharacter;
{
  NSRange lastCharacter = XPNotFoundRange;
  NSTextStorage *model = [self model];
  XPUInteger length = [[model mutableString] length];
  if (length == 0) { return; }
  
  lastCharacter = NSMakeRange(length-1, 1);
  [ model beginEditing];
  [[model mutableString] deleteCharactersInRange:lastCharacter];
  [ model endEditing];
  [self textDidChange:nil];
}

-(void)backspaceLine;
{
  XPLogPause(@"Unimplemented");
}

-(void)backspaceAll;
{
  NSTextStorage *model = [self model];
  [ model beginEditing];
  [[model mutableString] setString:@""];
  [ model endEditing];
  [self textDidChange:nil];
}

-(void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string;
{
  NSTextStorage *model = [self model];
  [model beginEditing];
  [model replaceCharactersInRange:range withString:string];
  [model endEditing];
  [self textDidChange:nil];
}

-(void)deleteCharactersInRange:(NSRange)range;
{
  NSTextStorage *model = [self model];
  [model beginEditing];
  [model deleteCharactersInRange:range];
  [model endEditing];
  [self textDidChange:nil];
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
      XPLogExtra1(@"%@ __dataRepresentationOfDiskTypeWithRange: Cache Hit", self);
      return output;
    }
    if ([dataCache count] > 20) {
      XPLogDebug1(@"%@ dataRepresentationOfType: Cache Clear", self);
      [dataCache removeAllObjects];
    }
    XPLogExtra1(@"%@ dataRepresentationOfType: Cache Miss", self);
    output = [[[SVRSolver replacingAttachmentsWithOriginalCharacters:[self model]] string] dataUsingEncoding:NSUTF8StringEncoding];
    [dataCache setObject:output forKey:key];
    return output;
  } else {
    // If a range is provided, do the work slowly with no caching
    output = [[[SVRSolver replacingAttachmentsWithOriginalCharacters:[[self model] attributedSubstringFromRange:range]] string] dataUsingEncoding:NSUTF8StringEncoding];
    NSAssert(output, @"__dataRepresentationOfDiskTypeWithRange: NIL");
    return output;
  }
}

-(NSData*)__dataRepresentationOfDisplayTypeWithRange:(NSRange)_range;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSData *output = [[self model] RTFFromRange:range documentAttributes:XPRTFDocumentAttributes];
  NSAssert(output, @"__dataRepresentationOfDisplayTypeWithRange: NIL");
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
  NSAssert(output, @"__dataRepresentationOfSolvedTypeWithRange: NIL");
  return output;
}

-(NSData*)__dataRepresentationOfUnsolvedTypeWithRange:(NSRange)_range;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSAttributedString *original = [[self model] attributedSubstringFromRange:range];
  NSAttributedString *unsolved = [SVRSolver replacingAttachmentsWithOriginalCharacters:original];
  NSData *output = [unsolved RTFFromRange:range
                       documentAttributes:XPRTFDocumentAttributes];
  NSAssert(output, @"__dataRepresentationOfUnsolvedTypeWithRange: NIL");
  return output;
}

-(BOOL)__loadDataRepresentationOfDiskType:(NSData*)data;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  BOOL success = NO;
  NSTextStorage *model = [self model];
  NSString *string = [
    [[NSString alloc] initWithData:data
                          encoding:NSUTF8StringEncoding]
    autorelease];
  if (string) {
    // TODO: Figure out how I can combine this with waitTimerFired:
    XPLogDebug1(@"%@ loadDataRepresentation: Rendering", self);
    [model beginEditing];
    [[model mutableString] setString:string];
    [SVRSolver solveAttributedString:model
                      solutionStyles:__TESTING_stylesForSolution         ? __TESTING_stylesForSolution         : [ud SVR_stylesForSolution]
              previousSolutionStyles:__TESTING_stylesForPreviousSolution ? __TESTING_stylesForPreviousSolution : [ud SVR_stylesForPreviousSolution]
                         errorStyles:__TESTING_stylesForError            ? __TESTING_stylesForError            : [ud SVR_stylesForError]
                          textStyles:__TESTING_stylesForText             ? __TESTING_stylesForText             : [ud SVR_stylesForText]];
    [model endEditing];
    success = YES;
  }
  return success;
}

-(void)dealloc;
{
  // TODO: Restore this log. It crashes on jaguar
  //XPLogDebug1(@"DEALLOC: %@", self);
  [_waitTimer invalidate];
  [_waitTimer release];
  [_model release];
  [_dataCache release];
  _textView = nil;
  _dataCache = nil;
  _waitTimer = nil;
  _model = nil;
  [super dealloc];
}

@end


@implementation SVRDocumentModelController (TextDelegate)

-(void)resetWaitTimer;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [_waitTimer invalidate];
  [_waitTimer release];
  _waitTimer = [NSTimer scheduledTimerWithTimeInterval:[ud SVR_waitTimeForRendering]
                                                target:self
                                              selector:@selector(waitTimerFired:)
                                              userInfo:nil
                                               repeats:NO];
  [_waitTimer retain];
}

-(void)waitTimerFired:(NSTimer*)timer;
{
  NSUserDefaults *ud   = [NSUserDefaults standardUserDefaults];
  NSTextStorage *model = [self model];
  NSTextView *textView = [self textView];
  
  // Get current selection
  NSRange selection = [textView selectedRange];
  
  // Solve the string
  [model beginEditing];
  [SVRSolver solveAttributedString:model
                    solutionStyles:__TESTING_stylesForSolution         ? __TESTING_stylesForSolution         : [ud SVR_stylesForSolution]
            previousSolutionStyles:__TESTING_stylesForPreviousSolution ? __TESTING_stylesForPreviousSolution : [ud SVR_stylesForPreviousSolution]
                       errorStyles:__TESTING_stylesForError            ? __TESTING_stylesForError            : [ud SVR_stylesForError]
                        textStyles:__TESTING_stylesForText             ? __TESTING_stylesForText             : [ud SVR_stylesForText]];
  [model endEditing];
  
  // Restore the selection
  [textView setSelectedRange:selection];

  // Invalidating at the end is important.
  // Otherwise, self could get deallocated mid-method 
  [timer invalidate];
}

-(void)textDidChange:(NSNotification*)notification;
{
  XPLogExtra1(@"%@ textDidChange:", self);
  [self resetWaitTimer];
}

@end
