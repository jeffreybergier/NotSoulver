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

#import "SVRSolver.h"
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
  XPParameterRaise(self);
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
  NSEnumerator *matches = [[[XPRegularExpression SVR_regexForExpressions]
                            matchesInString:_string]
                            objectEnumerator];
  XPTextCheckingResult *match = nil;
  NSMutableSet *output = [NSMutableSet new];
  NSRange range = XPNotFoundRange;
  XPLogAssrt(!_expressions, @"_expressions loaded twice");
  
  while ((match = [matches nextObject])) {
    range = [match range];
    // Trim the = sign off
    range.length -= 1;
    XPLogExtra1(@"= %@", [_string SVR_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  _expressions = output; // should make immutable copy but avoiding
}

-(void)__populateNumbers;
{
  NSSet *negativeNumberPrefixSet = SVRSolverScannerNegativeNumberPrefixSet;
  NSMutableSet *output = [NSMutableSet new];
  XPRegularExpression *regex = [XPRegularExpression SVR_regexForNumbers];
  NSEnumerator *matches = nil;
  XPTextCheckingResult *match = nil;
  NSEnumerator *expressions = [[self expressionRanges] objectEnumerator];
  NSValue *expression = nil;
  NSDecimalNumber *matchedNumber = nil;
  NSRange range = XPNotFoundRange;
  XPLogAssrt(!_numbers, @"_numbers loaded twice");

  while ((expression = [expressions nextObject])) {
    matches = [[regex matchesInString:_string
                              options:0
                                range:[expression XP_rangeValue]]
               objectEnumerator];
    while ((match = [matches nextObject])) {
      range = [match range];
      matchedNumber = [NSDecimalNumber decimalNumberWithString:[_string substringWithRange:range]];
      XPLogAssrt(![matchedNumber SVR_isNotANumber], @"matchedNumber: NaN");
      if (range.location > 0
          && [matchedNumber compare:[NSDecimalNumber zero]] == NSOrderedAscending
          && [negativeNumberPrefixSet member:[_string substringWithRange:NSMakeRange(range.location-1, 1)]] != nil)
      {
        // The regex matches (5+5)-7 as 3 numbers 5,5,-7 but the -7 is actually 7
        // This check adjusts for this edge case
        range.location += 1;
        range.length -= 1;
        XPLogExtra2(@"`%@`->`%@`", matchedNumber, [_string substringWithRange:range]);
      }
      XPLogExtra1(@"%@", [_string SVR_descriptionHighlightingRange:range]);
      [output addObject:[NSValue XP_valueWithRange:range]];
    }
  }
  
  _numbers = output; // should make immutable copy but avoiding
}

 -(void)__populateOperators;
 {
   NSMutableSet *output = [NSMutableSet new];
   XPRegularExpression *regex = [XPRegularExpression SVR_regexForOperators];
   NSEnumerator *matches = nil;
   XPTextCheckingResult *match = nil;
   NSEnumerator *expressions = [[self expressionRanges] objectEnumerator];
   NSValue *expression = nil;
   NSRange range = XPNotFoundRange;
   XPLogAssrt(!_operators, @"_operators loaded twice");

   while ((expression = [expressions nextObject])) {
     matches = [[regex matchesInString:_string
                               options:0
                                 range:[expression XP_rangeValue]]
                objectEnumerator];
     while ((match = [matches nextObject])) {
       range = [match rangeAtIndex:0];
       XPLogExtra1(@"%@", [_string SVR_descriptionHighlightingRange:range]);
       [output addObject:[NSValue XP_valueWithRange:range]];
     }
   }
   _operators = output; // should make immutable copy but avoiding
 }

-(void)__populateBrackets;
{
  NSMutableSet *output = [NSMutableSet new];
  XPRegularExpression *regex = [XPRegularExpression SVR_regexForBrackets];
  NSEnumerator *matches = nil;
  XPTextCheckingResult *match = nil;
  NSEnumerator *expressions = [[self expressionRanges] objectEnumerator];
  NSValue *expression = nil;
  NSRange range = XPNotFoundRange;
  XPLogAssrt(!_brackets, @"_brackets loaded twice");

  while ((expression = [expressions nextObject])) {
    matches = [[regex matchesInString:_string
                              options:0
                                range:[expression XP_rangeValue]]
               objectEnumerator];
    while ((match = [matches nextObject])) {
      range = [match range];
      XPLogExtra1(@"%@", [_string SVR_descriptionHighlightingRange:range]);
      [output addObject:[NSValue XP_valueWithRange:range]];
    }
  }
  
  _brackets = output; // should make immutable copy but avoiding
}

// MARK: Dealloc
-(void)dealloc;
{
  XPLogExtra1(@"%p", self);
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

@implementation XPRegularExpression (Soulver)

+(id)SVR_regexForNumbers;
{
  return [self regularExpressionWithPattern:@"(-?\\d+\\.\\d+|-?\\d+)" options:0 error:NULL];
}
+(id)SVR_regexForOperators;
{
  return [self regularExpressionWithPattern:@"(L|R|\\+|-|/|\\*|\\^)[-\\(\\d]" options:0 error:NULL];
}

+(id)SVR_regexForExpressions;
{
  return [self regularExpressionWithPattern:@"[\\dLR\\.\\^\\*-\\+/\\(\\)]+=" options:0 error:NULL];
}

+(id)SVR_regexForBrackets;
{
  return [self regularExpressionWithPattern:@"[\\(\\)]" options:0 error:NULL];
}

@end
