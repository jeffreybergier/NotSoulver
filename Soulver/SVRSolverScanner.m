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

#import "SVRSolverScanner.h"

NSSet *SVRSolverScannerNegativeNumberPrefixSet = nil;

@implementation SVRSolverScanner

// MARK: Load
+(void)initialize;
{
  SVRSolverScannerNegativeNumberPrefixSet = [[NSSet alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @")", nil];
}

// MARK: Initialization
-(id)initWithString:(NSString*)string;
{
  self = [super init];
  _string = [string copy];
  _numbers = nil;
  _operators = nil;
  _operators = nil;
  _expressions = nil;
  _brackets = nil;
  return self;
}

+(id)scannerWithString:(NSString*)string;
{
  return [[[SVRSolverScanner alloc] initWithString:string] autorelease];
}

-(NSSet*)expressionRanges;
{
  if (!_expressions) {
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
}

-(NSSet*)numberRanges;
{
  if (!_numbers) {
    [self __populateNumbers];
  }
  return [[_numbers retain] autorelease];
}

-(NSSet*)operatorRanges;
{
  if (!_operators) {
    [self __populateOperators];
  }
  return [[_operators retain] autorelease];
}

-(NSSet*)bracketRanges;
{
  if (!_brackets) {
    [self __populateBrackets];
  }
  return [[_brackets retain] autorelease];
}

// MARK: Convenience Properties
-(NSString*)string;
{
  return [[_string retain] autorelease];
}
-(NSString*)description;
{
  return [super description];
}

// MARK: Private

-(void)__populateExpressions;
{
  NSMutableSet *output = [NSMutableSet new];
  NSRange range = XPNotFoundRange;
  SLRERegex *regex = [SLRERegex SVR_regexForExpressionsInString:_string];
  SLRERegexMatch *match = nil;
  NSAssert(!_expressions, @"This is a lazy init method, it assumes _expressions is NIL");
  while ((match = [regex nextObject])) {
    range = [match range];
    // Trim the = sign off
    range.length -= 1;
    XPLogExtra1(@"<=> %@", [_string SVR_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  _expressions = output; // should make immutable copy but avoiding
}

-(void)__populateNumbers;
{
  NSSet *negativeNumberPrefixSet = SVRSolverScannerNegativeNumberPrefixSet;
  NSMutableSet *output = [NSMutableSet new];
  NSSet *expressions = [self expressionRanges];
  NSEnumerator *e = [expressions objectEnumerator];
  NSValue *nextExpression = nil;
  NSRange expressionRange = XPNotFoundRange;
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;
  NSDecimalNumber *matchedNumber = nil;
  NSRange range = XPNotFoundRange;
  NSAssert(!_numbers, @"This is a lazy init method, it assumes _numbers is NIL");
  
  while ((nextExpression = [e nextObject])) {
    expressionRange = [nextExpression XP_rangeValue];
    regex = [SLRERegex SVR_regexForNumbersInString:[_string substringWithRange:expressionRange]];
    while ((match = [regex nextObject])) {
      range = [match range];
      range.location += expressionRange.location; // Adjust range to be in space of whole string
      matchedNumber = [NSDecimalNumber decimalNumberWithString:[_string substringWithRange:range]];
      if ([matchedNumber SVR_isNotANumber]) { XPLogRaise(@"SVRSolverScanner __populateNumbers: Matched NaN"); }
      if (range.location > 0
          && [matchedNumber compare:[NSDecimalNumber zero]] == NSOrderedAscending
          && [negativeNumberPrefixSet member:[_string substringWithRange:NSMakeRange(range.location-1, 1)]] != nil)
      {
        // The regex matches (5+5)-7 as 3 numbers 5,5,-7 but the -7 is actually 7
        // This check adjusts for this edge case
        range.location += 1;
        range.length -= 1;
        XPLogDebug2(@"SVRSolverScanner __populateNumbers: `%@`->`%@`",
                    matchedNumber, [_string substringWithRange:range]);
      }
      XPLogExtra1(@"<#> %@", [_string SVR_descriptionHighlightingRange:range]);
      [output addObject:[NSValue XP_valueWithRange:range]];
    }
  }
  
  _numbers = output; // should make immutable copy but avoiding
}

 -(void)__populateOperators;
 {
   NSMutableSet *output = [NSMutableSet new];
   NSSet *expressions = [self expressionRanges];
   NSEnumerator *e = [expressions objectEnumerator];
   NSValue *nextExpression = nil;
   NSRange expressionRange = XPNotFoundRange;
   SLRERegex *regex = nil;
   SLRERegexMatch *match = nil;
   NSRange range = XPNotFoundRange;
   NSAssert(!_operators, @"This is a lazy init method, it assumes _operators is NIL");
   
   while ((nextExpression = [e nextObject])) {
     expressionRange = [nextExpression XP_rangeValue];
     regex = [SLRERegex SVR_regexForOperatorsInString:[_string substringWithRange:expressionRange]];
     while ((match = [regex nextObject])) {
       range = [match groupRangeAtIndex:0];
       // Adjust range to be in space of whole string
       range.location += expressionRange.location;
       XPLogExtra1(@"<+*> %@", [_string SVR_descriptionHighlightingRange:range]);
       [output addObject:[NSValue XP_valueWithRange:range]];
     }
   }
   _operators = output; // should make immutable copy but avoiding
 }

-(void)__populateBrackets;
{
  NSMutableSet *output = [NSMutableSet new];
  NSSet *expressions = [self expressionRanges];
  NSEnumerator *e = [expressions objectEnumerator];
  NSValue *nextExpression = nil;
  NSRange expressionRange = XPNotFoundRange;
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;
  NSRange range = XPNotFoundRange;
  NSAssert(!_brackets, @"This is a lazy init method, it assumes _brackets is NIL");
  
  while ((nextExpression = [e nextObject])) {
    expressionRange = [nextExpression XP_rangeValue];
    regex = [SLRERegex SVR_regexForBracketsInString:[_string substringWithRange:expressionRange]];
    while ((match = [regex nextObject])) {
      range = [match range];
      // Adjust range to be in space of whole string
      range.location += expressionRange.location;
      XPLogExtra1(@"<(> %@", [_string SVR_descriptionHighlightingRange:range]);
      [output addObject:[NSValue XP_valueWithRange:range]];
    }
  }
  
  _brackets = output; // should make immutable copy but avoiding
}

// MARK: Dealloc
-(void)dealloc;
{
  XPLogExtra1(@"DEALLOC: %@", self);
  [_string release];
  [_numbers release];
  [_operators release];
  [_expressions release];
  [_brackets release];
  _string = nil;
  _numbers = nil;
  _operators = nil;
  _expressions = nil;
  _brackets = nil;
  [super dealloc];
}

@end

@implementation SLRERegex (Soulver)

+(id)SVR_regexForNumbersInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"\\-?\\d+(\\.\\d+)*"
                          mode:SLRERegexAdvanceAfterMatch];
}
+(id)SVR_regexForOperatorsInString:(NSString*)string;
{
  // For some reason \d is not working in place of digits
  return [self regexWithString:string
                       pattern:@"(\\+|\\-|\\/|\\*|\\^)[\\-\\(0123456789]"
                          mode:SLRERegexAdvanceAfterGroup];
}

+(id)SVR_regexForExpressionsInString:(NSString*)string;
{
  // For some reason \d is not working in place of digits
  return [self regexWithString:string
                       pattern:@"[0123456789\\.\\^\\*\\-\\+\\/\\(\\)]+\\="
                          mode:SLRERegexAdvanceAfterMatch];
}

+(id)SVR_regexForBracketsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"[\\(\\)]"
                          mode:SLRERegexAdvanceAfterMatch];
}

@end
