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

NSString *const MATHDocumentModelExtension   = @"mtxt";
NSString *const MATHDocumentModelRepDisk     = @"com.saturdayapps.mathedit.plain";
NSString *const MATHDocumentModelRepDisplay  = @"com.saturdayapps.mathedit.display";
NSString *const MATHDocumentModelRepSolved   = @"com.saturdayapps.mathedit.solved";
NSString *const MATHDocumentModelRepUnsolved = @"com.saturdayapps.mathedit.unsolved";

@implementation MATHDocumentModelController

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
-(void)replaceCharactersInRange:(NSRange)range
                     withString:(NSString*)string
  preservingSelectionInTextView:(NSTextView*)textView;
{
  NSTextStorage *model = [self model];
  
  XPParameterRaise(string);
  XPParameterRaise(textView);
  
  [model beginEditing];
  [model replaceCharactersInRange:range withString:string];
  [model endEditing];
  [self textDidChange:[NSNotification notificationWithName:NSTextDidChangeNotification object:textView]];
}

// MARK: NSDocument Support

-(NSData*)dataOfType:(NSString*)typeName error:(XPErrorPointer)outError;
{
  return [self dataOfType:typeName range:XPNotFoundRange error:outError];
}

-(NSData*)dataOfType:(NSString*)typeName range:(NSRange)range error:(XPErrorPointer)outError;
{
  XPParameterRaise(typeName);
  if        ([typeName isEqualToString:MATHDocumentModelRepDisk])       {
    return [self __dataOfDiskRepWithRange:range error:outError];
  } else if ([typeName isEqualToString:MATHDocumentModelRepDisplay])    {
    return [self __dataOfDisplayRepWithRange:range error:outError];
  } else if ([typeName isEqualToString:MATHDocumentModelRepSolved])     {
    return [self __dataOfModelRepSolvedWithRange:range error:outError];
  } else if ([typeName isEqualToString:MATHDocumentModelRepUnsolved])   {
    return [self __dataOfModelRepUnsolvedWithRange:range error:outError];
  } else                                                                {
    XPLogAssrt1(NO, @"[UNKNOWN] MATHDocumentModelRep(%@)", typeName);
    return nil;
  }
}

-(BOOL)readFromData:(NSData*)data ofType:(NSString*)typeName error:(XPErrorPointer)outError;
{
  if ([typeName isEqualToString:MATHDocumentModelRepDisk]) {
    return [self __readFromData:data ofType:typeName error:outError];
  } else {
    XPLogAssrt1(NO, @"[UNKNOWN] MATHDocumentModelRep(%@)", typeName);
    return NO;
  }
}

// MARK: Private

-(NSData*)__dataOfDiskRepWithRange:(NSRange)range error:(XPErrorPointer)outError;
{
  NSMutableDictionary *dataCache = nil;
  NSString *key = nil;
  NSData *output = nil;
  
  XPLogExtra1(@"[XPUNIMPLEMENTED] ErrorPointer(%@)", XPStringFromErrorPointer(outError));

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
    output = [[[MATHSolver replacingAttachmentsWithOriginalCharacters:[self model]] string] dataUsingEncoding:NSUTF8StringEncoding];
    [dataCache setObject:output forKey:key];
    return output;
  } else {
    // If a range is provided, do the work slowly with no caching
    output = [[[MATHSolver replacingAttachmentsWithOriginalCharacters:[[self model] attributedSubstringFromRange:range]] string] dataUsingEncoding:NSUTF8StringEncoding];
    XPParameterRaise(output);
    return output;
  }
}

-(NSData*)__dataOfDisplayRepWithRange:(NSRange)_range error:(XPErrorPointer)outError;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSData *output = [[self model] RTFFromRange:range documentAttributes:XPRTFDocumentAttributes];
  XPParameterRaise(output);
  XPLogExtra1(@"[XPUNIMPLEMENTED] ErrorPointer(%@)", XPStringFromErrorPointer(outError));
  return output;
}

-(NSData*)__dataOfModelRepSolvedWithRange:(NSRange)_range error:(XPErrorPointer)outError;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSAttributedString *original = [[self model] attributedSubstringFromRange:range];
  NSAttributedString *solved = [MATHSolver replacingAttachmentsWithStringValue:original];
  NSData *output = [solved RTFFromRange:NSMakeRange(0, [solved length])
                     documentAttributes:XPRTFDocumentAttributes];
  XPParameterRaise(output);
  XPLogExtra1(@"[XPUNIMPLEMENTED] ErrorPointer(%@)", XPStringFromErrorPointer(outError));
  return output;
}

-(NSData*)__dataOfModelRepUnsolvedWithRange:(NSRange)_range error:(XPErrorPointer)outError;
{
  NSRange range = XPIsNotFoundRange(_range)
                ? NSMakeRange(0, [[self model] length])
                : _range;
  NSAttributedString *original = [[self model] attributedSubstringFromRange:range];
  NSAttributedString *unsolved = [MATHSolver replacingAttachmentsWithOriginalCharacters:original];
  NSData *output = [unsolved RTFFromRange:NSMakeRange(0, [unsolved length])
                       documentAttributes:XPRTFDocumentAttributes];
  XPParameterRaise(output);
  XPLogExtra1(@"[XPUNIMPLEMENTED] ErrorPointer(%@)", XPStringFromErrorPointer(outError));
  return output;
}

-(BOOL)__readFromData:(NSData*)data ofType:(NSString*)typeName error:(XPErrorPointer)outError;
{
  BOOL success = NO;
  NSTextStorage *model = [self model];
  NSString *string = [[[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding] autorelease];
  
  if (string) {
    // TODO: Figure out how I can combine this with waitTimerFired:
    [model beginEditing];
    [[model mutableString] setString:string];
    [self __solveEditingModelInPlace:model error:outError];
    [model endEditing];
    success = YES;
  }
  XPLogExtra1(@"[XPUNIMPLEMENTED] ErrorPointer(%@)", XPStringFromErrorPointer(outError));
  return success;
}

-(BOOL)__solveEditingModelInPlace:(NSTextStorage*)model error:(XPErrorPointer)outError;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPLogDebug(@"Rendering");
  XPLogDebug1(@"[XPUNIMPLEMENTED] ErrorPointer(%@)", XPStringFromErrorPointer(outError));
  
  [MATHSolver solveAttributedString:model
                     solutionStyles:__TESTING_stylesForSolution         ? __TESTING_stylesForSolution         : [ud MATH_stylesForSolution        ]
             previousSolutionStyles:__TESTING_stylesForPreviousSolution ? __TESTING_stylesForPreviousSolution : [ud MATH_stylesForPreviousSolution]
                        errorStyles:__TESTING_stylesForError            ? __TESTING_stylesForError            : [ud MATH_stylesForError           ]
                         textStyles:__TESTING_stylesForText             ? __TESTING_stylesForText             : [ud MATH_stylesForText            ]
                              error:outError];
  return YES;
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

@implementation MATHDocumentModelController (TextDelegate)

-(void)textDidChange:(NSNotification*)aNotification;
{
  NSTextView *textView = [aNotification object];
  XPLogAssrt1([textView isKindOfClass:[NSTextView class]], @"%@ not a text view", textView);
  [self __resetWaitTimer:textView];
}

-(BOOL)renderPreservingSelectionInTextView:(NSTextView*)textView
                                     error:(XPErrorPointer)outError;
{
  NSTextStorage *model = [self model];
  NSRange selection = XPNotFoundRange;
  
  XPParameterRaise(textView);
  
  if ([textView hasMarkedText]) {
    if (outError != NULL) { /* TODO: Populate Error Pointer */ }
    XPLogAlwys(@"[PRECONDITION] NSTextView hasMarkedText: Abandoning render");
    return NO;
  }
  
  // Get current selection
  selection = [textView selectedRange];
  
  // Solve the string
  [model beginEditing];
  [self __solveEditingModelInPlace:model error:outError];
  [model endEditing];
  
  // Restore selection
  [textView setSelectedRange:selection];
  return YES;
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
  [self renderPreservingSelectionInTextView:textView error:NULL];
  [timer invalidate];
}

@end
