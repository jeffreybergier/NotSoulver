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

#ifndef MAC_OS_X_VERSION_10_0
// Silences warning for these functions on OpenStep
extern int isnan(double x);
extern int isinf(double x);
#endif

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

+(void)solveAttributedString:(NSMutableAttributedString*)input
              solutionStyles:(SVRSolverTextAttachmentStyles)solutionStyles
      previousSolutionStyles:(SVRSolverTextAttachmentStyles)previousSolutionStyles
                 errorStyles:(SVRSolverTextAttachmentStyles)errorStyles
                  textStyles:(SVRSolverTextStyles)textStyles;
{
  XPUInteger inputLength = [[input string] length];
  XPUInteger outputLength;
  [input retain];
  [self __step1_restoreOriginals:input];
  [self __step2_removeAllTags:input];
  [self __step3_scanAndTag:input];
  [self __step4_solveAndTag:input
             solutionStyles:solutionStyles
     previousSolutionStyles:previousSolutionStyles
                errorStyles:errorStyles];
  [self __step5_styleAndTag:input styles:textStyles];
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
  NSArray *dictKeys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil];
  NSRange range = XPNotFoundRange;
  NSValue *next = nil;
  SVRSolverTextAttachment *attachment = nil;
  NSArray *dictValues = nil;
  NSAttributedString *toReplace = nil;
  NSEnumerator *e = [[input string] XP_enumeratorForCharactersInSet:SVRSolverTextAttachmentCharacterSet
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
    dictValues = [NSArray arrayWithObjects:[attachment toDrawColor], [attachment toDrawFont], nil];
    toReplace  = [[[NSAttributedString alloc] initWithString:[attachment toDrawString]
                                                  attributes:[NSDictionary dictionaryWithObjects:dictValues forKeys:dictKeys]] autorelease];
    [output replaceCharactersInRange:range withAttributedString:toReplace];
    dictValues = nil;
    toReplace  = nil;
    attachment = nil;
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

+(void)__step4_solveAndTag:(NSMutableAttributedString*)input
            solutionStyles:(SVRSolverTextAttachmentStyles)solutionStyles
    previousSolutionStyles:(SVRSolverTextAttachmentStyles)previousSolutionStyles
               errorStyles:(SVRSolverTextAttachmentStyles)errorStyles;
{
  [SVRSolverSolutionTagger tagSolutionsInAttributedString:input
                                           solutionStyles:solutionStyles
                                   previousSolutionStyles:previousSolutionStyles
                                              errorStyles:errorStyles];
}

+(void)__step5_styleAndTag:(NSMutableAttributedString*)input
                    styles:(SVRSolverTextStyles)styles;
{
  [SVRSolverStyler styleTaggedExpression:input styles:styles];
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
    case SVRCalculationRootByZero:
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
    case SVRCalculationRootByZero:
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
  NSCParameterAssert(self);
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

-(NSDecimalNumber*)SVR_decimalNumberByRaisingWithExponent:(NSDecimalNumber*)exponent
                                             withBehavior:(SVRSolverDecimalBehavior*)behavior;
{
  double baseRaw     = [self doubleValue];
  double exponentRaw = [exponent doubleValue];
  double baseMult    = (baseRaw < 0 && fmod(exponentRaw, 2) != 0) ? -1.0 : 1.0;
  double resultRaw   = 0;
  SVRCalculationError error = SVRCalculationNoError;
  
  if (exponentRaw == 0) {
    return [NSDecimalNumber one];
  }
  
  if (exponentRaw == 1) {
    return self;
  }

  if (exponentRaw > -1 && exponentRaw < 1) {
    // This is actually a root calculation not a power calculation
    return [self SVR_decimalNumberByRootingWithExponent:[[NSDecimalNumber one] decimalNumberByDividingBy:exponent]
                                           withBehavior:behavior];
  }
  
  if (error == SVRCalculationNoError) {
    resultRaw = pow(baseMult*baseRaw, exponentRaw) * baseMult;
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
      [behavior exceptionDuringOperation:@selector(SVR_decimalNumberByRaisingWithExponent:withBehavior:)
                                   error:error
                             leftOperand:self
                            rightOperand:exponent];
    } else {
      XPLogRaise1(@"NSCalculationError: %u", error);
    }
    return [NSDecimalNumber notANumber];
  }
}

-(NSDecimalNumber*)SVR_decimalNumberByRootingWithExponent:(NSDecimalNumber*)exponent
                                             withBehavior:(SVRSolverDecimalBehavior*)behavior;
{
  double baseRaw     = [self doubleValue];
  double exponentRaw = [exponent doubleValue];
  double baseMult    = 1; // Used to counteract odd root of negative number
  double resultRaw   = 0;
  SVRCalculationError error = SVRCalculationNoError;
  
  if (exponentRaw == 0) {
    error = SVRCalculationRootByZero;
  }
  
  if (baseRaw < 0) {
    if (fmod(exponentRaw, 2) != 1) {
      error = SVRCalculationResultImaginary;
    } else {
      baseMult = -1;
    }
  }
  
  if (error == SVRCalculationNoError) {
    resultRaw = pow(baseMult * baseRaw, 1.0 / exponentRaw) * baseMult;
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
      [behavior exceptionDuringOperation:@selector(SVR_decimalNumberByRootingWithExponent:withBehavior:)
                                   error:error
                             leftOperand:exponent
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
      [behavior exceptionDuringOperation:@selector(SVR_decimalNumberByRootingWithExponent:withBehavior:)
                                   error:error
                             leftOperand:base
                            rightOperand:self];
    } else {
      XPLogRaise1(@"NSCalculationError: %u", error);
    }
    return [NSDecimalNumber notANumber];
  }
}

@end

// MARK: SVRSolverTextAttachment Input

NSString *const SVRSolverTextAttachmentStyleToDrawFont    = @"SVRSolverTextAttachmentStyleToDrawFont";
NSString *const SVRSolverTextAttachmentStyleToDrawColor   = @"SVRSolverTextAttachmentStyleToDrawColor";
NSString *const SVRSolverTextAttachmentStyleNeighborFont  = @"SVRSolverTextAttachmentStyleNeighborFont";
NSString *const SVRSolverTextAttachmentStyleBorder        = @"SVRSolverTextAttachmentStyleBorder";

NSString *const SVRSolverTextStyleMathFont      = @"SVRSolverTextStyleMathFont";
NSString *const SVRSolverTextStyleOtherFont     = @"SVRSolverTextStyleOtherFont";
NSString *const SVRSolverTextStyleOtherColor    = @"SVRSolverTextStyleOtherColor";
NSString *const SVRSolverTextStyleOperandColor  = @"SVRSolverTextStyleOperandColor";
NSString *const SVRSolverTextStyleOperatorColor = @"SVRSolverTextStyleOperatorColor";
NSString *const SVRSolverTextStyleBracketColor  = @"SVRSolverTextStyleBracketColor";

// MARK: NSUserDefaults Helper Methods

@implementation NSUserDefaults (SVRSolverTextAttachmentStyles)

-(SVRSolverTextAttachmentStyles)SVR_stylesForSolution;
{
  NSFont  *toDrawFont   = [self SVR_fontForTheme:SVRThemeFontMath];
  NSColor *toDrawColor  = [self SVR_colorForTheme:SVRThemeColorSolution];
  NSFont  *neighborFont = toDrawFont;
  XPUserInterfaceStyle userInterfaceStyle = [self SVR_userInterfaceStyle];
  SVRSolverTextAttachmentBorderStyle borderStyle;
  
  switch (userInterfaceStyle) {
    case XPUserInterfaceStyleDark:
      borderStyle = SVRSolverTextAttachmentBorderStyleRecessedGray;
      break;
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleUnspecified:
    default:
      borderStyle = SVRSolverTextAttachmentBorderStyleRecessedWhite;
      break;
  }
  
  return [NSDictionary __SVR_stylesWithToDrawFont:toDrawFont
                                     neighborFont:neighborFont
                                      toDrawColor:toDrawColor
                                      borderStyle:borderStyle];
}

-(SVRSolverTextAttachmentStyles)SVR_stylesForPreviousSolution;
{
  NSFont  *toDrawFont   = [self SVR_fontForTheme:SVRThemeFontMath];
  NSColor *toDrawColor  = [self SVR_colorForTheme:SVRThemeColorOperator];
  NSFont  *neighborFont = toDrawFont;
  SVRSolverTextAttachmentBorderStyle borderStyle = SVRSolverTextAttachmentBorderStyleColored;
  
  return [NSDictionary __SVR_stylesWithToDrawFont:toDrawFont
                                     neighborFont:neighborFont
                                      toDrawColor:toDrawColor
                                      borderStyle:borderStyle];
}

-(SVRSolverTextAttachmentStyles)SVR_stylesForError;
{
  NSFont  *toDrawFont   = [self SVR_fontForTheme:SVRThemeFontError];
  NSColor *toDrawColor  = [self SVR_colorForTheme:SVRThemeColorErrorText];
  NSFont  *neighborFont = [self SVR_fontForTheme:SVRThemeFontMath];
  SVRSolverTextAttachmentBorderStyle borderStyle = SVRSolverTextAttachmentBorderStyleRecessedGray;
  
  return [NSDictionary __SVR_stylesWithToDrawFont:toDrawFont
                                     neighborFont:neighborFont
                                      toDrawColor:toDrawColor
                                      borderStyle:borderStyle];
}

-(SVRSolverTextStyles)SVR_stylesForText;
{
  NSFont  *mathFont       = [self SVR_fontForTheme:SVRThemeFontMath];
  NSFont  *otherTextFont  = [self SVR_fontForTheme:SVRThemeFontOther];
  NSColor *otherTextColor = [self SVR_colorForTheme:SVRThemeColorOtherText];
  NSColor *operandColor   = [self SVR_colorForTheme:SVRThemeColorOperand];
  NSColor *operatorColor  = [self SVR_colorForTheme:SVRThemeColorOperator];
  NSColor *bracketColor   = [self SVR_colorForTheme:SVRThemeColorBracket];
  
  return [NSDictionary __SVR_stylesWithMathFont:mathFont
                                   neighborFont:otherTextFont
                                 otherTextColor:otherTextColor
                                   operandColor:operandColor
                                  operatorColor:operatorColor
                                   bracketColor:bracketColor];
}

@end

@implementation NSDictionary (SVRSolverTextAttachmentStyles)

+(SVRSolverTextAttachmentStyles)__SVR_stylesWithToDrawFont:(NSFont*)toDrawFont
                                              neighborFont:(NSFont*)neighborFont
                                               toDrawColor:(NSColor*)toDrawColor
                                               borderStyle:(SVRSolverTextAttachmentBorderStyle)borderStyle;
{
  NSArray *values;
  NSArray *keys;
  
  NSCParameterAssert(toDrawFont);
  NSCParameterAssert(neighborFont);
  NSCParameterAssert(toDrawColor);
  
  values = [NSArray arrayWithObjects:
            toDrawFont,
            toDrawColor,
            neighborFont,
            [NSNumber XP_numberWithInteger:borderStyle],
            nil];
  
  keys = [NSArray arrayWithObjects:
          SVRSolverTextAttachmentStyleToDrawFont,
          SVRSolverTextAttachmentStyleToDrawColor,
          SVRSolverTextAttachmentStyleNeighborFont,
          SVRSolverTextAttachmentStyleBorder,
          nil];
  
  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

+(SVRSolverTextAttachmentStyles)__SVR_stylesWithMathFont:(NSFont*)mathFont
                                            neighborFont:(NSFont*)otherTextFont
                                          otherTextColor:(NSColor*)otherTextColor
                                            operandColor:(NSColor*)operandColor
                                           operatorColor:(NSColor*)operatorColor
                                            bracketColor:(NSColor*)bracketColor;
{
  NSArray *keys;
  NSArray *values;
  
  NSCParameterAssert(mathFont);
  NSCParameterAssert(otherTextFont);
  NSCParameterAssert(otherTextColor);
  NSCParameterAssert(operandColor);
  NSCParameterAssert(operatorColor);
  NSCParameterAssert(bracketColor);
  
  values = [NSArray arrayWithObjects:
            mathFont,
            otherTextFont,
            otherTextColor,
            operandColor,
            operatorColor,
            bracketColor,
            nil];
  
  keys = [NSArray arrayWithObjects:
          SVRSolverTextStyleMathFont,
          SVRSolverTextStyleOtherFont,
          SVRSolverTextStyleOtherColor,
          SVRSolverTextStyleOperandColor,
          SVRSolverTextStyleOperatorColor,
          SVRSolverTextStyleBracketColor,
          nil];
  
  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

@end
