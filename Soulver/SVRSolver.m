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
#import "XPCrossPlatform.h"
#import "SVRSolverStyler.h"
#import "SVRSolverScanner.h"
#import "SVRSolverSolutionTagger.h"
#import "SVRSolverExpressionTagger.h"

// MARK: SVRSolver

@implementation SVRSolver: NSObject

// MARK: Business Logic

+(void)solveAttributedString:(NSMutableAttributedString*)input;
{
  [input retain];
  [self __step1_decodeExpressionTerminator:input];
  [self __step2_removeAllTags:input];
  [self __step3_scanAndTag:input];
  [self __step4_solveAndTag:input];
  [self __step5_styleAndTag:input];
  [input autorelease];
}

+(void)__step1_decodeExpressionTerminator:(NSMutableAttributedString*)input;
{
  unichar attachmentChar = NSAttachmentCharacter;
  NSString *searchString = [NSString stringWithCharacters:&attachmentChar length:1];
  NSString *replaceString = @"=";
  [[input mutableString] XP_replaceOccurrencesOfString:searchString
                                            withString:replaceString];
}

+(void)__step2_removeAllTags:(NSMutableAttributedString*)input;
{
  NSRange range = NSMakeRange(0, [input length]);
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagNumber) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution) range:range];
  [input removeAttribute:NSFontAttributeName range:range];
  [input removeAttribute:NSForegroundColorAttributeName range:range];
  [input removeAttribute:NSBackgroundColorAttributeName range:range];
  [input removeAttribute:NSParagraphStyleAttributeName range:range];
}

+(void)__step3_scanAndTag:(NSMutableAttributedString*)input;
{
  SVRSolverScanner *scanner = [SVRSolverScanner scannerWithString:[input string]];
  [SVRSolverExpressionTagger tagNumbersAtRanges:[scanner numberRanges]
                             inAttributedString:input];
  [SVRSolverExpressionTagger tagBracketsAtRanges:[scanner bracketRanges]
                              inAttributedString:input];
  [SVRSolverExpressionTagger tagOperatorsAtRanges:[scanner operatorRanges]
                               inAttributedString:input];
  [SVRSolverExpressionTagger tagExpressionsAtRanges:[scanner expressionRanges]
                                 inAttributedString:input];
}

+(void)__step4_solveAndTag:(NSMutableAttributedString*)input;
{
  [SVRSolverSolutionTagger tagSolutionsInAttributedString:input];
}

+(void)__step5_styleAndTag:(NSMutableAttributedString*)input;
{
  [SVRSolverStyler styleTaggedExpression:input];
}

@end

@implementation SVRSolver (Testing)

+(void)executeTests;
{
  NSLog(@"+[SVRSolver executeTests] Unimplemented. Implement check to read file and check known good Attributed String output");
}

@end

// MARK: Enumeration Helper Functions

NSString *XPAttributedStringKeyForTag(SVRSolverTag tag)
{
  switch (tag) {
    case SVRSolverTagNumber:           return @"kSVRSoulverTagNumberKey";
    case SVRSolverTagBracket:          return @"kSVRSoulverTagBracketKey";
    case SVRSolverTagOperator:         return @"kSVRSoulverTagOperatorKey";
    case SVRSolverTagExpression:       return @"kSVRSoulverTagExpressionKey";
    case SVRSolverTagSolution:         return @"kSVRSolverTagSolutionKey";
    case SVRSolverTagPreviousSolution: return @"kSVRSolverTagPreviousSolutionKey";
    default:
      XPLogRaise1(@"SVR_stringForTagUnknown: %d", tag);
      return nil;
  }
}

SVRSolverTag SVRSolverTagForKey(XPAttributedStringKey string)
{
  if        ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagNumber)])           {
    return SVRSolverTagNumber;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagBracket)])          {
    return SVRSolverTagBracket;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagOperator)])         {
    return SVRSolverTagOperator;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagExpression)])       {
    return SVRSolverTagExpression;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagSolution)])         {
    return SVRSolverTagSolution;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution)]) {
    return SVRSolverTagPreviousSolution;
  } else {
    XPLogRaise1(@"SVR_tagForStringUnknown: %@", string);
    return (SVRSolverTag)-1;
  }
}

NSNumber* NSNumberForOperator(SVRSolverOperator operator)
{
  return [NSNumber XP_numberWithInteger:operator];
}

SVRSolverOperator SVRSolverOperatorForNumber(NSNumber *number)
{
  return (SVRSolverOperator)[number XP_integerValue];
}

SVRSolverOperator SVRSolverOperatorForRawString(NSString *string)
{
  if        ([string isEqualToString:@"^"]) {
    return SVRSolverOperatorExponent;
  } else if ([string isEqualToString:@"/"]) {
    return SVRSolverOperatorDivide;
  } else if ([string isEqualToString:@"*"]) {
    return SVRSolverOperatorMultiply;
  } else if ([string isEqualToString:@"-"]) {
    return SVRSolverOperatorSubtract;
  } else if ([string isEqualToString:@"+"]) {
    return SVRSolverOperatorAdd;
  } else {
    XPLogRaise1(@"SVR_operatorForRawStringUnknown: %@", string);
    return (SVRSolverOperator)-1;
  }
}

NSString *SVRSolverDescriptionForError(SVRSolverError error)
{
  switch (error) {
    case SVRSolverErrorNone:
      return nil;
    case SVRSolverErrorInvalidCharacter:
      return [NSString stringWithFormat:@"<Error:%d> Incompatible character", error];
    case SVRSolverErrorMismatchedBrackets:
      return [NSString stringWithFormat:@"<Error:%d> Parentheses not balanced", error];
    case SVRSolverErrorMissingOperand:
      return [NSString stringWithFormat:@"<Error:%d> Missing operand", error];
    case SVRSolverErrorDivideByZero:
      return [NSString stringWithFormat:@"<Error:%d> Divide by zero", error];
    default:
      XPLogRaise1(@"SVRSolverDescriptionForErrorUnknown: %d", error);
      return nil;
  }
}

NSString *SVRSolverDebugDescriptionForError(SVRSolverError error)
{
  switch (error) {
    case SVRSolverErrorNone:
      return @"none";
    case SVRSolverErrorInvalidCharacter:
      return @"invalidCharacter";
    case SVRSolverErrorMismatchedBrackets:
      return @"mismatchedBrackets";
    case SVRSolverErrorMissingOperand:
      return @"missingOperand";
    case SVRSolverErrorDivideByZero:
      return @"divideByZero";
    default:
      XPLogRaise1(@"SVRSolverDescriptionForErrorUnknown: %d", error);
      return nil;
  }
}
