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
#import "NSUserDefaults+Soulver.h"
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
  XPUInteger inputLength = [[input string] length];
  XPUInteger outputLength;
  [input retain];
  [self __step1_restoreOriginals:input];
  [self __step2_removeAllTags:input];
  [self __step3_scanAndTag:input];
  [self __step4_solveAndTag:input];
  [self __step5_styleAndTag:input];
  outputLength = [[input string] length];
  if (inputLength != outputLength) {
    XPLogPause2(@"SVRSolver solveAttributedString: String changed length: %ld->%ld", inputLength, outputLength);
  }
  [input autorelease];
}

+(NSString*)restoreOriginalString:(NSAttributedString*)input;
{
  NSMutableAttributedString *copy = [[input mutableCopy] autorelease];
  [self __step1_restoreOriginals:copy];
  return [copy string];
}

+(void)__step1_restoreOriginals:(NSMutableAttributedString*)input;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:
                         [[NSAttributedString attributedStringWithAttachment:nil] string]];
#pragma clang diagnostic pop
  NSRange range = XPNotFoundRange;
  NSValue *next = nil;
  NSString *originalString = nil;
  NSEnumerator *e = [[input string] XP_enumeratorForCharactersInSet:set];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    originalString = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagOriginal)
                              atIndex:range.location
                       effectiveRange:NULL];
    if (!originalString) {
      XPLogPause(@"SVRSolver __step1_restoreOriginals: No attribute for text attachment character");
      originalString = @"~";
    }
    if (range.length > 1) {
      XPLogPause1(@"SVRSolver __step1_restoreOriginals: Invalid Range:%@", NSStringFromRange(range));
    }
    [input replaceCharactersInRange:range withString:originalString];
  }
}

+(void)__step2_removeAllTags:(NSMutableAttributedString*)input;
{
  NSRange range = NSMakeRange(0, [input length]);
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)     range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)    range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)   range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOriginal)   range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression) range:range];
  [input removeAttribute:NSFontAttributeName            range:range];
  [input removeAttribute:NSAttachmentAttributeName      range:range];
  [input removeAttribute:NSParagraphStyleAttributeName  range:range];
  [input removeAttribute:NSForegroundColorAttributeName range:range];
  [input removeAttribute:NSBackgroundColorAttributeName range:range];
}

+(void)__step3_scanAndTag:(NSMutableAttributedString*)input;
{
  SVRSolverScanner *scanner = [SVRSolverScanner scannerWithString:[input string]];
  [SVRSolverExpressionTagger step1_tagOperatorsAtRanges:[scanner operatorRanges]
                                     inAttributedString:input];
  [SVRSolverExpressionTagger step2_tagNumbersAtRanges:[scanner numberRanges]
                                   inAttributedString:input];
  [SVRSolverExpressionTagger step3_tagBracketsAtRanges:[scanner bracketRanges]
                                    inAttributedString:input];
  [SVRSolverExpressionTagger step4_tagExpressionsAtRanges:[scanner expressionRanges]
                                       inAttributedString:input];
  return;
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
    case SVRSolverTagNumber:     return @"kSVRSoulverTagNumberKey";
    case SVRSolverTagBracket:    return @"kSVRSoulverTagBracketKey";
    case SVRSolverTagOperator:   return @"kSVRSoulverTagOperatorKey";
    case SVRSolverTagExpression: return @"kSVRSoulverTagExpressionKey";
    case SVRSolverTagOriginal:   return @"kSVRSolverTagOriginalKey";
    default:
      XPLogRaise1(@"SVR_stringForTagUnknown: %d", tag);
      return nil;
  }
}

SVRSolverTag SVRSolverTagForKey(XPAttributedStringKey string)
{
  if        ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagNumber)])     {
    return SVRSolverTagNumber;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagBracket)])    {
    return SVRSolverTagBracket;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagOperator)])   {
    return SVRSolverTagOperator;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagExpression)]) {
    return SVRSolverTagExpression;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagOriginal)])   {
    return SVRSolverTagOriginal;
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
    return SVRSolverOperatorUnknown;
  }
}

NSString *RawStringForOperator(SVRSolverOperator operator)
{
  switch (operator) {
    case SVRSolverOperatorExponent: return @"^";
    case SVRSolverOperatorDivide:   return @"/";
    case SVRSolverOperatorMultiply: return @"*";
    case SVRSolverOperatorSubtract: return @"-";
    case SVRSolverOperatorAdd:      return @"+";
    case SVRSolverOperatorUnknown:
    default:
      XPLogRaise1(@"RawStringForOperatorUnknown: %d", operator);
      return nil;
  }
}

NSString *SVRSolverDescriptionForError(SVRSolverError error)
{
  switch (error) {
    case SVRSolverErrorNone:
      return nil;
    case SVRSolverErrorInvalidCharacter:
      return [NSString stringWithFormat:[Localized phraseErrorInvalidCharacter], error];
    case SVRSolverErrorMismatchedBrackets:
      return [NSString stringWithFormat:[Localized phraseErrorMismatchedBrackets], error];
    case SVRSolverErrorMissingOperand:
      return [NSString stringWithFormat:[Localized phraseErrorMissingOperand], error];
    case SVRSolverErrorDivideByZero:
      return [NSString stringWithFormat:[Localized phraseErrorDividByZero], error];
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
