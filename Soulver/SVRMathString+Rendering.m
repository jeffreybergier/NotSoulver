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
  output = [self render_encodedStringWithError:&error];
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

-(NSAttributedString*)render_encodedStringWithError:(NSNumber**)error;
{
  NSMutableAttributedString *decodedOutput;
  NSEnumerator *e;
  NSString *_encodedLine;
  NSString *encodedLine;
  NSString *lastSolution;
  
  if (![_string SVR_containsOnlyCharactersInSet:[NSSet SVRAllowedCharacters]]) {
    *error = [NSNumber errorInvalidCharacter];
    return nil;
  }
  
  decodedOutput = [[NSMutableAttributedString new] autorelease];
  e = [[_string componentsSeparatedByString:@"="] objectEnumerator];
  encodedLine = nil;
  lastSolution = nil;
  
  while (_encodedLine = [e nextObject]) {
    if ([_encodedLine length] == 0) { continue; }                                                     // If the line is empty, skip
    encodedLine = _encodedLine;                                                                       // Set the baseline for doing math operations later
    if ([_encodedLine SVR_beginsWithCharacterInSet:[NSSet SVROperators]]) {                           // If the line begins with an operator we need to prepend the last solution
      if (!lastSolution) { *error = [NSNumber errorMissingNumberBeforeOrAfterOperator]; return nil; } // If no previous solution AND the line begins with an operator we need to bail
      encodedLine = [lastSolution stringByAppendingString:_encodedLine];                              // Prepend the encoded line with the last solution
    }
    lastSolution = [self render_solveEncodedLine:encodedLine error:error];                            // Solve the problem
    if (lastSolution == nil) { return nil; }                                                          // If the solution is nil, there was an error
    [decodedOutput appendAttributedString:[self render_decodeEncodedLine:encodedLine]];               // Decode the encodedLine and append it to the output
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"="]];            // Append an equal sign
    [decodedOutput appendAttributedString:[self render_colorSolution:lastSolution]];                  // Append the solution
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"\n"]];           // Append a newline
    encodedLine = nil;                                                                                // Clean up
  }
  
  return [[decodedOutput copy] autorelease];
}

-(NSString*)render_solveEncodedLine:(NSString*)input error:(NSNumber**)error;
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
    solutionString = [self render_solveEncodedLine:[parenRange contents] error:error];
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

-(NSAttributedString*)render_decodeEncodedLine:(NSString*)line;
{
  return [NSAttributedString SVR_stringWithString:
            [line SVR_stringByMappingCharactersInDictionary:
               [SVRMathString operatorDecodeMap]
            ]
  ];
}
-(NSAttributedString*)render_colorSolution:(NSString*)solution;
{
  return [NSAttributedString SVR_stringWithString:solution color:[NSColor cyanColor]];
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
