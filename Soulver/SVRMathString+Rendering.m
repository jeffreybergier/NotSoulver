//
//  SVRMathString+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathString+Rendering.h"
#import "NSString+Soulver.h"

@implementation SVRMathString (Rendering)

-(NSAttributedString*)render;
{
  NSAttributedString *output;
  NSNumber *error = nil;
  output = [self __renderWithError:&error];
  if (output == nil) {
    output = [self renderError:error];
  }
  return output;
}

-(NSAttributedString*)renderError:(NSNumber*)error;
{
  NSMutableAttributedString *output;
  
  output = [[NSMutableAttributedString new] autorelease];
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:_string]];
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:[NSString stringWithFormat:@"<Error:%@>\n", error]
                                                                    color:[NSColor orangeColor]]];
  return [[output copy] autorelease];
}

-(NSAttributedString*)__renderWithError:(NSNumber**)error;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorRange *next;
  NSMutableString *lineBuilder;
  NSMutableAttributedString *output;
  NSString *_decodedOperator;
  
  if (_string == nil || [_string length] == 0) {
    return [[NSAttributedString new] autorelease];
  }
  
  e = [SVRStringEnumerator enumeratorWithString:_string];
  next = [e nextObject];
  
  lineBuilder = [[NSMutableString new] autorelease];
  output = [[NSMutableAttributedString new] autorelease];
  
  while (next && *error == NULL) {
    if ([[NSSet SVRAllowedCharacters] member:[next substring]] == nil) {
      *error = [NSNumber errorInvalidCharacter];
      return nil;
    }
    _decodedOperator = [SVRMathString decodeOperator:[next substring]];
    [output appendAttributedString:[NSAttributedString SVR_stringWithString:_decodedOperator ? _decodedOperator : [next substring]]];
    _decodedOperator = nil;
    if ([[next substring] isEqualToString:@"="]) {
      NSString *_solution = [self __solveLine:[[lineBuilder copy] autorelease] error:error];
      if (_solution == nil) { return nil; }
      NSAttributedString *toAppend = [NSAttributedString SVR_stringWithString:[NSString stringWithFormat:@"%@", _solution]
                                                                        color:[NSColor cyanColor]];
      [output appendAttributedString:toAppend];
      [output appendAttributedString:[NSAttributedString SVR_stringWithString:@"\n"]];
      lineBuilder = [[NSMutableString new] autorelease];
      next = [e nextObject];
      if ([[NSSet SVROperators] member:[next substring]]) {
        // The next line starts with an operator so I need to put this line's answer first
        [lineBuilder appendString:_solution];
        [output appendAttributedString:toAppend];
      }
    } else {
      [lineBuilder appendString:[next substring]];
      next = [e nextObject];
    }
  }
  
  if (*error != NULL) {
    return nil;
  }
  
  return [[output copy] autorelease];
}

-(NSString*)__solveLine:(NSString*)input error:(NSNumber**)error;
{
  SVRBoundingRange *parenRange;
  SVRMathRange *mathRange;
  NSString *solutionString;
  double solutionNumber;
  NSMutableString *output = [[input mutableCopy] autorelease];
  
  if (*error != NULL) {
    return nil;
  }
  
  if (input == nil || [input length] == 0) {
    return @"";
  }
  
  // PEMDAS
  // Parantheses
  parenRange = [output SVR_searchRangeBoundedByLHS:@"(" rhs:@")" error:error];
  while (parenRange && *error == NULL) {
    solutionString = [self __solveLine:[parenRange contents] error:error];
    [output SVR_replaceCharactersInRange:[parenRange range]
                              withString:solutionString
                                   error:error];
    parenRange = [output SVR_searchRangeBoundedByLHS:@"(" rhs:@")" error:error];
  }
  
  // Exponents
  mathRange = [output SVR_searchMathRangeForOperators:[NSSet SVRExponent]
                                 allPossibleOperators:[NSSet SVROperators]
                                  allPossibleNumerals:[NSSet SVRNumerals]];
  while (mathRange && *error == NULL) {
    solutionNumber = [mathRange evaluate];
    solutionString = [NSString stringWithFormat:@"%g", solutionNumber];
    [output SVR_replaceCharactersInRange:[mathRange range]
                              withString:solutionString
                                   error:error];
    mathRange = [output SVR_searchMathRangeForOperators:[NSSet SVRExponent]
                                   allPossibleOperators:[NSSet SVROperators]
                                    allPossibleNumerals:[NSSet SVRNumerals]];
  }
  
  // Multiply and Divide
  mathRange = [output SVR_searchMathRangeForOperators:[NSSet SVRMultDiv]
                                 allPossibleOperators:[NSSet SVROperators]
                                  allPossibleNumerals:[NSSet SVRNumerals]];
  while (mathRange && *error == NULL) {
    solutionNumber = [mathRange evaluate];
    solutionString = [NSString stringWithFormat:@"%g", solutionNumber];
    [output SVR_replaceCharactersInRange:[mathRange range]
                              withString:solutionString
                                   error:error];
    mathRange = [output SVR_searchMathRangeForOperators:[NSSet SVRMultDiv]
                                   allPossibleOperators:[NSSet SVROperators]
                                    allPossibleNumerals:[NSSet SVRNumerals]];
  }
  
  // Add and Subtract
  mathRange = [output SVR_searchMathRangeForOperators:[NSSet SVRPlusMinus]
                                 allPossibleOperators:[NSSet SVROperators]
                                  allPossibleNumerals:[NSSet SVRNumerals]];
  while (mathRange && *error == NULL) {
    solutionNumber = [mathRange evaluate];
    solutionString = [NSString stringWithFormat:@"%g", solutionNumber];
    [output SVR_replaceCharactersInRange:[mathRange range]
                              withString:solutionString
                                   error:error];
    mathRange = [output SVR_searchMathRangeForOperators:[NSSet SVRPlusMinus]
                                   allPossibleOperators:[NSSet SVROperators]
                                    allPossibleNumerals:[NSSet SVRNumerals]];
  }
  
  if (*error != NULL) {
    return nil;
  }
  
  // If we get to the end here, and the result is not just a simple number,
  // then we have a mismatch between numbers and operators
  if (![output isValidDouble]) {
    *error = [NSNumber errorMissingNumberBeforeOrAfterOperator];
    return nil;
  }
  return [[output copy] autorelease];
}

@end

@implementation NSMutableString (SVRMathStringRendering)
-(void)SVR_replaceCharactersInRange:(NSRange)range
                         withString:(NSString*)patch
                              error:(NSNumber**)error;
{
  BOOL issueFound = NO;
  BOOL canCheckLeft = NO;
  BOOL canCheckRight = NO;
  NSRange checkRange = NSMakeRange(0,0);
  
  if (*error != NULL) {
    return;
  }
  
  canCheckLeft = range.location > 0;
  canCheckRight = range.location + range.length < [self length];
  
  // Perform Checks to the left and right to make sure
  // there are operators outside of where we are patching.
  if (canCheckLeft) {
    checkRange.location = range.location - 1;
    checkRange.length = 1;
    issueFound = [[NSSet SVRPatchCheck] member:[self substringWithRange:checkRange]] == nil;
  }
  
  if (issueFound) {
    *error = [NSNumber errorPatching];
    return;
  }
  
  if (canCheckRight) {
    checkRange.location = range.location + range.length;
    checkRange.length = 1;
    issueFound = [[NSSet SVRPatchCheck] member:[self substringWithRange:checkRange]] == nil;
  }
  
  if (issueFound) {
    *error = [NSNumber errorPatching];
    return;
  }
  
  [self replaceCharactersInRange:range withString:patch];
  return;
}
@end
