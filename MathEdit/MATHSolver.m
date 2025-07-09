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

#import "MATHSolver.h"
#import "NSUserDefaults+MathEdit.h"
#import "XPCrossPlatform.h"
#import "MATHSolverStyler.h"
#import "MATHSolverScanner.h"
#import "MATHSolverSolutionTagger.h"
#import "MATHSolverExpressionTagger.h"
#import "MATHSolverTextAttachment.h"

#ifndef MAC_OS_X_VERSION_10_2
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
  SVRSolverTextAttachmentCharacterSet = [
    [NSCharacterSet characterSetWithCharactersInString:
     [[NSAttributedString attributedStringWithAttachment:
       [[NSTextAttachment new] autorelease]]
      string]]
    retain];
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
  XPLogAssrt2(inputLength == outputLength, @"String changed length: %d->%d",
              (int)inputLength, (int)outputLength);
  [input autorelease];
}

+(NSAttributedString*)replacingAttachmentsWithOriginalCharacters:(NSAttributedString*)input;
{
  NSMutableAttributedString *output = [[input mutableCopy] autorelease];
  [self __step1_restoreOriginals:output];
  return output;
}

+(NSAttributedString*)replacingAttachmentsWithStringValue:(NSAttributedString*)input;
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
    
    XPLogAssrt1(range.length == 1, @"[INVALID] range(%@)", NSStringFromRange(range));
    XPLogAssrt(attachment, @"attachment was NIL");
    
    dictValues = [NSArray arrayWithObjects:[attachment backgroundColor], [attachment font], nil];
    toReplace  = [[[NSAttributedString alloc] initWithString:[attachment string]
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
  NSArray *dictKeys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil];
  NSRange range = XPNotFoundRange;
  NSValue *next = nil;
  SVRSolverTextAttachment *attachment = nil;
  NSString *originalString = nil;
  NSArray *dictValues = nil;
  NSAttributedString *toReplace = nil;
  NSEnumerator *e = [[input string] XP_enumeratorForCharactersInSet:SVRSolverTextAttachmentCharacterSet
                                                            options:NSBackwardsSearch];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    attachment = [input attribute:NSAttachmentAttributeName
                           atIndex:range.location
                    effectiveRange:NULL];
    originalString = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagOriginal)
                               atIndex:range.location
                        effectiveRange:NULL];
    
    XPLogAssrt1(range.length == 1, @"[INVALID] range(%@)", NSStringFromRange(range));
    XPLogAssrt(originalString, @"[MISSING] originalString");
    XPLogAssrt(attachment, @"[MISSING] attachment");
    
    dictValues = [NSArray arrayWithObjects:[attachment foregroundColor], [attachment font], nil];
    toReplace  = [[[NSAttributedString alloc] initWithString:originalString
                                                  attributes:[NSDictionary dictionaryWithObjects:dictValues forKeys:dictKeys]] autorelease];
    [input replaceCharactersInRange:range withAttributedString:toReplace];
    dictValues = nil;
    toReplace  = nil;
    attachment = nil;
    originalString = nil;
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
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRSolverTag(%d)", (int)tag);
      return nil;
  }
}

SVRSolverTag SVRSolverTagForKey(XPAttributedStringKey string)
{
  XPCParameterRaise(string);
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
    XPCLogAssrt1(NO, @"[UNKNOWN] XPAttributedStringKey(%@)", string);
    return -1;
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
  } else if ([string isEqualToString:[NSString MATH_rootRawString]]) {
    return SVRSolverOperatorRoot;
  } else if ([string isEqualToString:[NSString MATH_logRawString]]) {
    return SVRSolverOperatorLog;
  } else {
    XPCLogAssrt1(NO, @"[UNKNOWN] SVRSolverOperator(%@)", string);
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
    case SVRSolverOperatorRoot:     return [NSString MATH_rootRawString];
    case SVRSolverOperatorLog:      return [NSString MATH_logRawString];
    case SVRSolverOperatorUnknown:
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRSolverOperator(%d)", (int)operator);
      return nil;
  }
}

NSString *SVRSolverDescriptionForError(SVRCalculationError error)
{
  switch (error) {
    case SVRCalculationLossOfPrecision:
    case SVRCalculationUnderflow:
    case SVRCalculationOverflow:
      XPCLogAssrt1(NO, @"[ERROR] SVRCalculationOverflow(%d)", (int)error);
      return nil;
    case SVRCalculationNoError:
      return nil;
    case SVRCalculationDivideByZero:
      return [NSString stringWithFormat:[Localized phraseErrorDivideByZero], error];
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
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRCalculationError(%d)", (int)error);
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
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRCalculationError(%d)", (int)error);
      return nil;
  }
}

// MARK: NSDecimalNumber Helper Methods

@implementation SVRSolverDecimalBehavior

-(id)initWithErrorPtr:(SVRCalculationErrorPointer)errorPtr;
{
  self = [super init];
  XPParameterRaise(self);
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
  XPLogExtra1(@"<%@>", XPPointerString(self));
  _errorPtr = NULL;
  [super dealloc];
}

@end

@implementation NSDecimalNumber (Soulver)

-(BOOL)MATH_isNotANumber;
{
  NSString *lhsDescription = [self description];
  NSString *rhsDescription = [[NSDecimalNumber notANumber] description];
  return [lhsDescription isEqualToString:rhsDescription];
}

-(NSDecimalNumber*)MATH_decimalNumberByRaisingWithExponent:(NSDecimalNumber*)exponent
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
    return [self MATH_decimalNumberByRootingWithExponent:[[NSDecimalNumber one] decimalNumberByDividingBy:exponent]
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
  
  switch (error) {
    case SVRCalculationNoError:
      return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", resultRaw]];
    default:
      NSParameterAssert(behavior);
      return [behavior exceptionDuringOperation:@selector(MATH_decimalNumberByRaisingWithExponent:withBehavior:)
                                          error:error
                                    leftOperand:self
                                   rightOperand:exponent];
  }
}

-(NSDecimalNumber*)MATH_decimalNumberByRootingWithExponent:(NSDecimalNumber*)exponent
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
  
  switch (error) {
    case SVRCalculationNoError:
      return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", resultRaw]];
    default:
      NSParameterAssert(behavior);
      return [behavior exceptionDuringOperation:@selector(MATH_decimalNumberByRaisingWithExponent:withBehavior:)
                                          error:error
                                    leftOperand:exponent
                                   rightOperand:self];
  }
}

-(NSDecimalNumber*)MATH_decimalNumberByLogarithmWithBase:(NSDecimalNumber*)base
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
  
  switch (error) {
    case SVRCalculationNoError:
      return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", resultRaw]];
    default:
      NSParameterAssert(behavior);
      return [behavior exceptionDuringOperation:@selector(MATH_decimalNumberByRaisingWithExponent:withBehavior:)
                                          error:error
                                    leftOperand:base
                                   rightOperand:self];
  }
}

@end

// MARK: SVRSolverTextAttachment Input

NSString *const SVRSolverTextAttachmentBackgroundKey   = @"SVRSolverTextAttachmentBackground";
NSString *const SVRSolverTextAttachmentMixColorKey     = @"SVRSolverTextAttachmentMixColor";

NSString *const SVRSolverTextStyleMathFont      = @"SVRSolverTextStyleMathFont";
NSString *const SVRSolverTextStyleOtherFont     = @"SVRSolverTextStyleOtherFont";
NSString *const SVRSolverTextStyleOtherColor    = @"SVRSolverTextStyleOtherColor";
NSString *const SVRSolverTextStyleOperandColor  = @"SVRSolverTextStyleOperandColor";
NSString *const SVRSolverTextStyleOperatorColor = @"SVRSolverTextStyleOperatorColor";
NSString *const SVRSolverTextStylePreviousColor = @"SVRSolverTextStylePreviousColor";

// MARK: NSUserDefaults Helper Methods

@implementation NSUserDefaults (SVRSolverTextAttachmentStyles)

-(SVRSolverTextAttachmentStyles)MATH_stylesForSolution;
{
#ifdef XPSupportsNSBezierPath
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundCapsuleFill;
#else
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundLegacyBoxStroke;
#endif
  NSColor *mixColor = [self MATH_userInterfaceStyle] == XPUserInterfaceStyleDark
                      ? [NSColor whiteColor]
                      : [NSColor blackColor];
  return [NSDictionary __MATH_stylesWithFont:[self MATH_fontForTheme:SVRThemeFontMath]
                             foregroundColor:[self MATH_colorForTheme:SVRThemeColorOperandText]
                             backgroundColor:[self MATH_colorForTheme:SVRThemeColorSolution]
                                    mixColor:mixColor
                                  background:background];
}

-(SVRSolverTextAttachmentStyles)MATH_stylesForPreviousSolution;
{
#ifdef XPSupportsNSBezierPath
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundCapsuleStroke;
#else
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundLegacyBoxStroke;
#endif
  NSColor *mixColor = [self MATH_userInterfaceStyle] == XPUserInterfaceStyleDark
                      ? [NSColor whiteColor]
                      : [NSColor blackColor];
  return [NSDictionary __MATH_stylesWithFont:[self MATH_fontForTheme:SVRThemeFontMath]
                             foregroundColor:[self MATH_colorForTheme:SVRThemeColorOperandText]
                             backgroundColor:[self MATH_colorForTheme:SVRThemeColorSolutionSecondary]
                                    mixColor:mixColor
                                  background:background];
}

-(SVRSolverTextAttachmentStyles)MATH_stylesForError;
{
#ifdef XPSupportsNSBezierPath
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundCapsuleStroke;
#else
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundLegacyBoxStroke;
#endif
  NSColor *mixColor = [self MATH_userInterfaceStyle] == XPUserInterfaceStyleDark
                      ? [NSColor whiteColor]
                      : [NSColor blackColor];
  return [NSDictionary __MATH_stylesWithFont:[self MATH_fontForTheme:SVRThemeFontError]
                             foregroundColor:[self MATH_colorForTheme:SVRThemeColorOperandText]
                             backgroundColor:[self MATH_colorForTheme:SVRThemeColorErrorText]
                                    mixColor:mixColor
                                  background:background];
}

-(SVRSolverTextStyles)MATH_stylesForText;
{
  NSFont  *mathFont       = [self MATH_fontForTheme:SVRThemeFontMath];
  NSFont  *otherTextFont  = [self MATH_fontForTheme:SVRThemeFontOther];
  NSColor *otherTextColor = [self MATH_colorForTheme:SVRThemeColorOtherText];
  NSColor *operandColor   = [self MATH_colorForTheme:SVRThemeColorOperandText];
  NSColor *operatorColor  = [self MATH_colorForTheme:SVRThemeColorOperatorText];
  NSColor *previousColor  = [self MATH_colorForTheme:SVRThemeColorSolutionSecondary];
  
  return [NSDictionary __MATH_stylesWithMathFont:mathFont
                                    neighborFont:otherTextFont
                                  otherTextColor:otherTextColor
                                    operandColor:operandColor
                                   operatorColor:operatorColor
                                   previousColor:previousColor];
}

@end

@implementation NSDictionary (SVRSolverTextAttachmentStyles)

+(SVRSolverTextAttachmentStyles)__MATH_stylesWithFont:(NSFont*)font
                                      foregroundColor:(NSColor*)foregroundColor
                                      backgroundColor:(NSColor*)backgroundColor
                                             mixColor:(NSColor*)mixColor
                                           background:(SVRSolverTextAttachmentBackground)purpose;
{
  NSArray *values;
  NSArray *keys;
  
  XPParameterRaise(font);
  XPParameterRaise(foregroundColor);
  XPParameterRaise(backgroundColor);
  XPParameterRaise(mixColor);
  
  values = [NSArray arrayWithObjects:
            font,
            foregroundColor,
            backgroundColor,
            mixColor,
            [NSNumber XP_numberWithInteger:purpose],
            nil];
  
  keys = [NSArray arrayWithObjects:
          NSFontAttributeName,
          NSForegroundColorAttributeName,
          NSBackgroundColorAttributeName,
          SVRSolverTextAttachmentMixColorKey,
          SVRSolverTextAttachmentBackgroundKey,
          nil];
  
  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

+(SVRSolverTextAttachmentStyles)__MATH_stylesWithMathFont:(NSFont*)mathFont
                                             neighborFont:(NSFont*)otherTextFont
                                           otherTextColor:(NSColor*)otherTextColor
                                             operandColor:(NSColor*)operandColor
                                            operatorColor:(NSColor*)operatorColor
                                            previousColor:(NSColor*)previousColor;
{
  NSArray *keys;
  NSArray *values;
  
  XPParameterRaise(mathFont);
  XPParameterRaise(otherTextFont);
  XPParameterRaise(otherTextColor);
  XPParameterRaise(operandColor);
  XPParameterRaise(operatorColor);
  XPParameterRaise(previousColor);
  
  values = [NSArray arrayWithObjects:
            mathFont,
            otherTextFont,
            otherTextColor,
            operandColor,
            operatorColor,
            previousColor,
            nil];
  
  keys = [NSArray arrayWithObjects:
          SVRSolverTextStyleMathFont,
          SVRSolverTextStyleOtherFont,
          SVRSolverTextStyleOtherColor,
          SVRSolverTextStyleOperandColor,
          SVRSolverTextStyleOperatorColor,
          SVRSolverTextStylePreviousColor,
          nil];
  
  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

@end
