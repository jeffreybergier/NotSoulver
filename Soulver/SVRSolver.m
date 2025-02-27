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
#import "SVRSolverTextAttachment.h"

NSCharacterSet *SVRSolverTextAttachmentCharacterSet = nil;

// MARK: SVRSolver

@implementation SVRSolver: NSObject

// MARK: Configure Constants
+(void)initialize;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  SVRSolverTextAttachmentCharacterSet = [
    [NSCharacterSet characterSetWithCharactersInString:
     [[NSAttributedString attributedStringWithAttachment:
       [[NSTextAttachment new] autorelease]]
      string]]
    retain];
#pragma clang diagnostic pop
}

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

+(NSMutableAttributedString*)replaceAttachmentsWithOriginalCharacters:(NSAttributedString*)input;
{
  NSMutableAttributedString *output = [[input mutableCopy] autorelease];
  [self __step1_restoreOriginals:output];
  return output;
}

+(NSMutableAttributedString*)replaceAttachmentsWithStringValue:(NSAttributedString*)input;
{
  NSCharacterSet *set = SVRSolverTextAttachmentCharacterSet;
  NSRange range = XPNotFoundRange;
  NSValue *next = nil;
  id<SVRSolverTextAttachment> attachment = nil;
  NSEnumerator *e = [[input string] XP_enumeratorForCharactersInSet:set
                                                            options:NSBackwardsSearch];
  NSMutableAttributedString *output = [[input mutableCopy] autorelease];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    attachment = [output attribute:NSAttachmentAttributeName
                           atIndex:range.location
                    effectiveRange:NULL];
    if (range.length > 1) {
      XPLogPause1(@"SVRSolver __step1_restoreOriginals: Invalid Range:%@",
                  NSStringFromRange(range));
    }
    [output replaceCharactersInRange:range withString:[attachment toDrawString]];
  }
  return output;
}

+(void)__step1_restoreOriginals:(NSMutableAttributedString*)input;
{
  NSCharacterSet *set = SVRSolverTextAttachmentCharacterSet;
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
  } else if ([string isEqualToString:[NSString SVR_rootRawString]]) {
    return SVRSolverOperatorRoot;
  } else if ([string isEqualToString:[NSString SVR_logRawString]]) {
    return SVRSolverOperatorLog;
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
    case SVRSolverOperatorRoot:     return [NSString SVR_rootRawString];
    case SVRSolverOperatorLog:      return [NSString SVR_logRawString];
    case SVRSolverOperatorUnknown:
    default:
      XPLogRaise1(@"RawStringForOperatorUnknown: %d", operator);
      return nil;
  }
}

NSString *SVRSolverDescriptionForError(SVRCalculationError error)
{
  // TODO: Add missing localized strings
  switch (error) {
    case SVRCalculationLossOfPrecision:
    case SVRCalculationUnderflow:
    case SVRCalculationOverflow:
      XPLogRaise1(@"Should not show error: %d", error);
      return nil;
    case SVRCalculationNoError:
      return nil;
    case SVRCalculationDivideByZero:
      return [NSString stringWithFormat:[Localized phraseErrorDividByZero], error];
    case SVRCalculationInvalidCharacter:
      return [NSString stringWithFormat:[Localized phraseErrorInvalidCharacter], error];
    case SVRCalculationMismatchedBrackets:
      return [NSString stringWithFormat:[Localized phraseErrorMismatchedBrackets], error];
    case SVRCalculationMissingOperand:
      return [NSString stringWithFormat:[Localized phraseErrorMissingOperand], error];
    case SVRCalculationResultNaN:
      return [NSString stringWithFormat:[Localized phraseErrorNaN], error];
    case SVRCalculationResultInfinite:
      return [NSString stringWithFormat:[Localized phraseErrorInfinite], error];
    case SVRCalculationResultImaginary:
      return [NSString stringWithFormat:[Localized phraseErrorImaginary], error];
    case SVRCalculationIndexZero:
      return [NSString stringWithFormat:[Localized phraseErrorIndexZero], error];
    case SVRCalculationArgumentNegative:
      return [NSString stringWithFormat:[Localized phraseErrorArgumentNegative], error];
    case SVRCalculationBaseNegative:
      return [NSString stringWithFormat:[Localized phraseErrorBaseNegative], error];
    case SVRCalculationBaseOne:
      return [NSString stringWithFormat:[Localized phraseErrorBaseOne], error];
    default:
      XPLogRaise1(@"SVRSolverDescriptionForErrorUnknown: %d", error);
      return nil;
  }
}

NSString *SVRSolverDebugDescriptionForError(SVRCalculationError error) {
  switch (error) {
    case SVRCalculationNoError:
      return @"SVRCalculationNoError";
    case SVRCalculationLossOfPrecision:
      return @"SVRCalculationLossOfPrecision";
    case SVRCalculationUnderflow:
      return @"SVRCalculationUnderflow";
    case SVRCalculationOverflow:
      return @"SVRCalculationOverflow";
    case SVRCalculationDivideByZero:
      return @"SVRCalculationDivideByZero";
    case SVRCalculationInvalidCharacter:
      return @"SVRCalculationInvalidCharacter";
    case SVRCalculationMismatchedBrackets:
      return @"SVRCalculationMismatchedBrackets";
    case SVRCalculationMissingOperand:
      return @"SVRCalculationMissingOperand";
    case SVRCalculationResultNaN:
      return @"SVRCalculationResultNaN";
    case SVRCalculationResultInfinite:
      return @"SVRCalculationResultInfinite";
    case SVRCalculationResultImaginary:
      return @"SVRCalculationResultImaginary";
    case SVRCalculationIndexZero:
      return @"SVRCalculationIndexZero";
    case SVRCalculationArgumentNegative:
      return @"SVRCalculationArgumentNegative";
    case SVRCalculationBaseNegative:
      return @"SVRCalculationBaseNegative";
    case SVRCalculationBaseOne:
      return @"SVRCalculationBaseOne";
    default:
      XPLogRaise1(@"SVRSolverDebugDescriptionForError: %d", error);
      return nil;
  }
}

// MARK: NSDecimalNumber Helper Methods

@implementation SVRSolverDecimalBehavior

-(id)initWithErrorPtr:(SVRCalculationErrorPointer)errorPtr;
{
  self = [super init];
  _errorPtr = errorPtr;
  return self;
}

+(id)behaviorWithErrorPtr:(SVRCalculationErrorPointer)errorPtr;
{
  return [[[SVRSolverDecimalBehavior alloc] initWithErrorPtr:errorPtr] autorelease];
}

-(NSRoundingMode)roundingMode;
{
  return NSRoundPlain;
}

-(short)scale;
{
  return 5;
}

-(NSDecimalNumber*)exceptionDuringOperation:(SEL)operation
                                      error:(SVRCalculationError)error
                                leftOperand:(NSDecimalNumber*)leftOperand
                               rightOperand:(NSDecimalNumber*)rightOperand;
{
  // Log the error if needed
  switch (error) {
    case SVRCalculationNoError:
      break;
    default:
      XPLogDebug3(@"%@: lhs: %@ rhs: %@", SVRSolverDebugDescriptionForError(error), leftOperand, rightOperand);
      break;
  }
  
  // Configure the error pointer if needed
  switch (error) {
    case SVRCalculationNoError:
    case SVRCalculationLossOfPrecision:
    case SVRCalculationOverflow:
    case SVRCalculationUnderflow:
      *_errorPtr = SVRCalculationNoError;
      break;
    default:
      *_errorPtr = error;
      break;
  }
  
  // Decide what to do with the error.
  // Only divide by zero needs special action (according to docs)
  switch (error) {
    case SVRCalculationDivideByZero: return [NSDecimalNumber notANumber];
    default: return nil;
  }
}

-(void)dealloc;
{
  XPLogExtra1(@"DEALLOC: %@", self);
  _errorPtr = NULL;
  [super dealloc];
}

@end

@implementation NSDecimalNumber (Soulver)

-(BOOL)SVR_isNotANumber;
{
  NSString *lhsDescription = [self description];
  NSString *rhsDescription = [[NSDecimalNumber notANumber] description];
  return [lhsDescription isEqualToString:rhsDescription];
}

-(NSDecimalNumber*)SVR_decimalNumberByRootingWithIndex:(NSDecimalNumber*)index
                                          withBehavior:(SVRSolverDecimalBehavior*)behavior;
{
  double radicandRaw = [self doubleValue];
  double indexRaw    = [index doubleValue];
  double resultRaw   = 0;
  double radMult     = 1; // Used to counteract odd root of negative number
  SVRCalculationError error = SVRCalculationNoError;
  
  if (indexRaw == 0) {
    error = SVRCalculationIndexZero;
  }
  
  if (radicandRaw < 0) {
    if (fmod(indexRaw, 2) != 1) {
      error = SVRCalculationResultImaginary;
    } else {
      radMult = -1;
    }
  }
  
  if (error == SVRCalculationNoError) {
    resultRaw = pow(radMult*radicandRaw, 1.0 / indexRaw) * radMult;
    if (isnan(resultRaw)) {
      error = SVRCalculationResultNaN;
    }
    if (isinf(resultRaw)) {
      error = SVRCalculationResultInfinite;
    }
  }
  
  if (error == NSCalculationNoError) {
    NSString *resultString = [NSString stringWithFormat:@"%f", resultRaw];
    NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithString:resultString];
    return result;
  } else {
    if (behavior) {
      [behavior exceptionDuringOperation:@selector(SVR_decimalNumberByRootingWithIndex:withBehavior:)
                                   error:error
                             leftOperand:index
                            rightOperand:self];
    } else {
      XPLogRaise1(@"NSCalculationError: %u", error);
    }
    return [NSDecimalNumber notANumber];
  }
}

-(NSDecimalNumber*)SVR_decimalNumberByLogarithmWithBase:(NSDecimalNumber*)base
                                           withBehavior:(SVRSolverDecimalBehavior*)behavior;
{
  double argumentRaw = [self doubleValue];
  double baseRaw     = [base doubleValue];
  double resultRaw   = 0;
  SVRCalculationError error = SVRCalculationNoError;
  
  if (argumentRaw <= 0) {
    error = SVRCalculationArgumentNegative;
  }
  
  if (baseRaw <= 0) {
    error = SVRCalculationBaseNegative;
  }
  
  if (baseRaw == 1) {
    error = SVRCalculationBaseOne;
  }
  
  if (error == SVRCalculationNoError) {
    resultRaw = log(argumentRaw) / log(baseRaw);
    if (isnan(resultRaw)) {
      error = SVRCalculationResultNaN;
    }
    if (isinf(resultRaw)) {
      error = SVRCalculationResultInfinite;
    }
  }
  
  if (error == SVRCalculationNoError) {
    NSString *resultString = [NSString stringWithFormat:@"%f", resultRaw];
    NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithString:resultString];
    return result;
  } else {
    if (behavior) {
      [behavior exceptionDuringOperation:@selector(SVR_decimalNumberByRootingWithIndex:withBehavior:)
                                   error:error
                             leftOperand:base
                            rightOperand:self];
    } else {
      XPLogRaise1(@"NSCalculationError: %u", error);
    }
    return [NSDecimalNumber notANumber];
  }
}

// TODO: Update this to match SVR_decimalNumberByRootingWithIndex
// Make this the primary method and the other method just uses root 1/exponent
-(NSDecimalNumber*)SVR_decimalNumberByRaisingToPower:(NSDecimalNumber*)power
                                        withBehavior:(id<NSDecimalNumberBehaviors>)behavior;
{
  NSDecimalNumber *output = nil;
  BOOL powerIsNegative = ([power compare:[NSDecimalNumber zero]] == NSOrderedAscending);
  BOOL selfIsNegative = ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending);
  
  if (powerIsNegative) {
    output = [[NSDecimalNumber one] decimalNumberByDividingBy:
                          [self decimalNumberByRaisingToPower:(XPUInteger)abs([power intValue])
                                                 withBehavior:behavior]
                                                 withBehavior:behavior];
  } else {
    output = [self decimalNumberByRaisingToPower:(XPUInteger)[power unsignedIntValue]
                                    withBehavior:behavior];
  }
  
  if (selfIsNegative) {
    output = [output decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]
                                     withBehavior:behavior];
  }
  
  return output;
}

@end
