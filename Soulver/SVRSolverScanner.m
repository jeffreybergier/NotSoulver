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

@implementation SVRSolverScanner

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

// MARK: Enumerator Access (mostly for testing)
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

-(NSSet*)expressionRanges;
{
  if (!_expressions) {
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
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
-(void)__populateNumbers;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSRange range = XPNotFoundRange;
  SLRERegex *regex = [SLRERegex SVR_regexForNumbersInString:_string];
  SLRERegexMatch *match = nil;
  NSAssert(!_numbers, @"This is a lazy init method, it assumes _numbers is NIL");
  while ((match = [regex nextObject])) {
    range = [match range];
    if (range.location > 0
       && [[_string substringWithRange:NSMakeRange(range.location-1, 1)] isEqualToString:@")"])
    {
      // The regex matches (5+5)-7 as 3 numbers 5,5,-7 but the -7 is actually 7
      // This check adjusts for this edge case
      range.location += 1;
      range.length -= 1;
    }
    XPLogExtra1(@"<#> %@", [_string SVR_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  _numbers = [output copy];
}

-(void)__populateOperators;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSRange range = XPNotFoundRange;
  SLRERegex *regex = [SLRERegex SVR_regexForOperatorsInString:_string];
  SLRERegexMatch *match = nil;
  NSAssert(!_operators, @"This is a lazy init method, it assumes _operators is NIL");
  while ((match = [regex nextObject])) {
    range = [match groupRangeAtIndex:0];
    XPLogExtra1(@"<+*> %@", [_string SVR_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  _operators = [output copy];
}

-(void)__populateExpressions;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
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
  _expressions = [output copy];
}

-(void)__populateBrackets;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSRange range = XPNotFoundRange;
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;
  NSAssert(!_brackets, @"This is a lazy init method, it assumes _brackets is NIL");

  // Check for opening brackets
  regex = [SLRERegex SVR_regexForLeftBracketsInString:_string];
  while ((match = [regex nextObject])) {
    range = [match groupRangeAtIndex:0];
    XPLogExtra1(@"<(> %@", [_string SVR_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  // Check for closing brackets
  regex = [SLRERegex SVR_regexForRightBracketsInString:_string];
  while ((match = [regex nextObject])) {
    range = [match groupRangeAtIndex:0];
    XPLogExtra1(@"<)> %@", [_string SVR_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  _brackets = [output copy];
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
  return [self regexWithString:string
                       pattern:@"[\\)0123456789](\\+|\\-|\\/|\\*|\\^)[\\(0123456789]"
                          mode:SLRERegexAdvanceAfterGroup];
}

+(id)SVR_regexForExpressionsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"[0123456789\\.\\^\\*\\-\\+\\/\\(\\)]+\\="
                          mode:SLRERegexAdvanceAfterMatch];
}

+(id)SVR_regexForLeftBracketsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"(\\()[\\-0123456789]"
                          mode:SLRERegexAdvanceAfterGroup];
}

+(id)SVR_regexForRightBracketsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"\\d(\\))"
                          mode:SLRERegexAdvanceAfterGroup];
}

@end
