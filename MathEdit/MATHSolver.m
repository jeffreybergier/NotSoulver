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

NSCharacterSet *MATHSolverTextAttachmentCharacterSet = nil;

// MARK: MATHSolver

@implementation MATHSolver: NSObject

// MARK: Configure Constants
+(void)initialize;
{
  MATHSolverTextAttachmentCharacterSet = [
    [NSCharacterSet characterSetWithCharactersInString:
     [[NSAttributedString attributedStringWithAttachment:
       [[NSTextAttachment new] autorelease]]
      string]]
    retain];
}

// MARK: Business Logic

+(BOOL)solveAttributedString:(NSMutableAttributedString*)input
              solutionStyles:(MATHSolverTextAttachmentStyles)solutionStyles
      previousSolutionStyles:(MATHSolverTextAttachmentStyles)previousSolutionStyles
                 errorStyles:(MATHSolverTextAttachmentStyles)errorStyles
                  textStyles:(MATHSolverTextStyles)textStyles
                       error:(XPErrorPointer)outError;
{
  XPUInteger inputLength = [[input string] length];
  XPUInteger outputLength;
  BOOL success = NO;
  [input retain];
  [self __step1_restoreOriginals:input];
  success = [self __step2_checkForInvalidCharacters:input error:outError];
  if (!success) { return NO; }
  [self __step3_removeAllTags:input];
  [self __step4_scanAndTag:input];
  [self __step5_solveAndTag:input
             solutionStyles:solutionStyles
     previousSolutionStyles:previousSolutionStyles
                errorStyles:errorStyles];
  [self __step6_styleAndTag:input styles:textStyles];
  outputLength = [[input string] length];
  XPLogAssrt2(inputLength == outputLength, @"String changed length: %d->%d",
              (int)inputLength, (int)outputLength);
  [input autorelease];
  return YES;
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
  MATHSolverTextAttachment *attachment = nil;
  NSArray *dictValues = nil;
  NSAttributedString *toReplace = nil;
  NSEnumerator *e = [[input string] XP_enumeratorForCharactersInSet:MATHSolverTextAttachmentCharacterSet
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
  MATHSolverTextAttachment *attachment = nil;
  NSString *originalString = nil;
  NSArray *dictValues = nil;
  NSAttributedString *toReplace = nil;
  NSEnumerator *e = [[input string] XP_enumeratorForCharactersInSet:MATHSolverTextAttachmentCharacterSet
                                                            options:NSBackwardsSearch];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    attachment = [input attribute:NSAttachmentAttributeName
                           atIndex:range.location
                    effectiveRange:NULL];
    originalString = [input attribute:XPAttributedStringKeyForTag(MATHSolverTagOriginal)
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

+(BOOL)__step2_checkForInvalidCharacters:(NSMutableAttributedString*)input error:(XPErrorPointer)outError;
{
#ifdef AFF_UnicodeDocumentNone
  if ([[input string] XP_containsNonASCIICharacters]) {
    if (outError != NULL) { /* TODO: Populate Error Pointer */ }
    XPLogAlwys(@"[PRECONDITION] Model String contained non-ascii characters");
    return NO;
  }
#endif
  return YES;
}

+(void)__step3_removeAllTags:(NSMutableAttributedString*)input;
{
  NSRange range = NSMakeRange(0, [input length]);
  [input removeAttribute:XPAttributedStringKeyForTag(MATHSolverTagNumber)     range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(MATHSolverTagBracket)    range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(MATHSolverTagOperator)   range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(MATHSolverTagOriginal)   range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(MATHSolverTagExpression) range:range];
  [input removeAttribute:NSFontAttributeName            range:range];
  [input removeAttribute:NSAttachmentAttributeName      range:range];
  [input removeAttribute:NSParagraphStyleAttributeName  range:range];
  [input removeAttribute:NSForegroundColorAttributeName range:range];
  [input removeAttribute:NSBackgroundColorAttributeName range:range];
}

+(void)__step4_scanAndTag:(NSMutableAttributedString*)input;
{
  MATHSolverScanner *scanner = [MATHSolverScanner scannerWithString:[input string]];
  [MATHSolverExpressionTagger step1_tagOperatorsAtRanges:[scanner operatorRanges]
                                      inAttributedString:input];
  [MATHSolverExpressionTagger step2_tagNumbersAtRanges:[scanner numberRanges]
                                    inAttributedString:input];
  [MATHSolverExpressionTagger step3_tagBracketsAtRanges:[scanner bracketRanges]
                                     inAttributedString:input];
  [MATHSolverExpressionTagger step4_tagExpressionsAtRanges:[scanner expressionRanges]
                                        inAttributedString:input];
  return;
}

+(void)__step5_solveAndTag:(NSMutableAttributedString*)input
            solutionStyles:(MATHSolverTextAttachmentStyles)solutionStyles
    previousSolutionStyles:(MATHSolverTextAttachmentStyles)previousSolutionStyles
               errorStyles:(MATHSolverTextAttachmentStyles)errorStyles;
{
  [MATHSolverSolutionTagger tagSolutionsInAttributedString:input
                                            solutionStyles:solutionStyles
                                    previousSolutionStyles:previousSolutionStyles
                                               errorStyles:errorStyles];
}

+(void)__step6_styleAndTag:(NSMutableAttributedString*)input
                    styles:(MATHSolverTextStyles)styles;
{
  [MATHSolverStyler styleTaggedExpression:input styles:styles];
}

@end

// MARK: Enumeration Helper Functions

NSString *XPAttributedStringKeyForTag(MATHSolverTag tag)
{
  switch (tag) {
    case MATHSolverTagNumber:     return @"kMATHSolverTagNumberKey";
    case MATHSolverTagBracket:    return @"kMATHSolverTagBracketKey";
    case MATHSolverTagOperator:   return @"kMATHSolverTagOperatorKey";
    case MATHSolverTagExpression: return @"kMATHSolverTagExpressionKey";
    case MATHSolverTagOriginal:   return @"kMATHSolverTagOriginalKey";
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHSolverTag(%d)", (int)tag);
      return nil;
  }
}

MATHSolverTag MATHSolverTagForKey(XPAttributedStringKey string)
{
  XPCParameterRaise(string);
  if        ([string isEqualToString:XPAttributedStringKeyForTag(MATHSolverTagNumber)])     {
    return MATHSolverTagNumber;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(MATHSolverTagBracket)])    {
    return MATHSolverTagBracket;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(MATHSolverTagOperator)])   {
    return MATHSolverTagOperator;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(MATHSolverTagExpression)]) {
    return MATHSolverTagExpression;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(MATHSolverTagOriginal)])   {
    return MATHSolverTagOriginal;
  } else {
    XPCLogAssrt1(NO, @"[UNKNOWN] XPAttributedStringKey(%@)", string);
    return -1;
  }
}

NSNumber* NSNumberForOperator(MATHSolverOperator operator)
{
  return [NSNumber XP_numberWithInteger:operator];
}

MATHSolverOperator MATHSolverOperatorForNumber(NSNumber *number)
{
  return (MATHSolverOperator)[number XP_integerValue];
}

MATHSolverOperator MATHSolverOperatorForRawString(NSString *string)
{
  if        ([string isEqualToString:@"^"]) {
    return MATHSolverOperatorExponent;
  } else if ([string isEqualToString:@"/"]) {
    return MATHSolverOperatorDivide;
  } else if ([string isEqualToString:@"*"]) {
    return MATHSolverOperatorMultiply;
  } else if ([string isEqualToString:@"-"]) {
    return MATHSolverOperatorSubtract;
  } else if ([string isEqualToString:@"+"]) {
    return MATHSolverOperatorAdd;
  } else if ([string isEqualToString:[NSString MATH_rootRawString]]) {
    return MATHSolverOperatorRoot;
  } else if ([string isEqualToString:[NSString MATH_logRawString]]) {
    return MATHSolverOperatorLog;
  } else {
    XPCLogAssrt1(NO, @"[UNKNOWN] MATHSolverOperator(%@)", string);
    return MATHSolverOperatorUnknown;
  }
}

NSString *RawStringForOperator(MATHSolverOperator operator)
{
  switch (operator) {
    case MATHSolverOperatorExponent: return @"^";
    case MATHSolverOperatorDivide:   return @"/";
    case MATHSolverOperatorMultiply: return @"*";
    case MATHSolverOperatorSubtract: return @"-";
    case MATHSolverOperatorAdd:      return @"+";
    case MATHSolverOperatorRoot:     return [NSString MATH_rootRawString];
    case MATHSolverOperatorLog:      return [NSString MATH_logRawString];
    case MATHSolverOperatorUnknown:
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHSolverOperator(%d)", (int)operator);
      return nil;
  }
}

NSString *MATHSolverDescriptionForError(MATHCalculationError error)
{
  switch (error) {
    case MATHCalculationLossOfPrecision:
    case MATHCalculationUnderflow:
    case MATHCalculationOverflow:
      XPCLogAssrt1(NO, @"[ERROR] MATHCalculationOverflow(%d)", (int)error);
      return nil;
    case MATHCalculationNoError:
      return nil;
    case MATHCalculationDivideByZero:
      return [NSString stringWithFormat:[Localized phraseErrorDivideByZero], error];
    case MATHCalculationInvalidCharacter:
      return [NSString stringWithFormat:[Localized phraseErrorInvalidCharacter], error];
    case MATHCalculationMismatchedBrackets:
      return [NSString stringWithFormat:[Localized phraseErrorMismatchedBrackets], error];
    case MATHCalculationMissingOperand:
      return [NSString stringWithFormat:[Localized phraseErrorMissingOperand], error];
    case MATHCalculationResultNaN:
      return [NSString stringWithFormat:[Localized phraseErrorNaN], error];
    case MATHCalculationResultInfinite:
      return [NSString stringWithFormat:[Localized phraseErrorInfinite], error];
    case MATHCalculationResultImaginary:
      return [NSString stringWithFormat:[Localized phraseErrorImaginary], error];
    case MATHCalculationRootByZero:
      return [NSString stringWithFormat:[Localized phraseErrorIndexZero], error];
    case MATHCalculationArgumentNegative:
      return [NSString stringWithFormat:[Localized phraseErrorArgumentNegative], error];
    case MATHCalculationBaseNegative:
      return [NSString stringWithFormat:[Localized phraseErrorBaseNegative], error];
    case MATHCalculationBaseOne:
      return [NSString stringWithFormat:[Localized phraseErrorBaseOne], error];
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHCalculationError(%d)", (int)error);
      return nil;
  }
}

NSString *MATHSolverDebugDescriptionForError(MATHCalculationError error) {
  switch (error) {
    case MATHCalculationNoError:
      return @"MATHCalculationNoError";
    case MATHCalculationLossOfPrecision:
      return @"MATHCalculationLossOfPrecision";
    case MATHCalculationUnderflow:
      return @"MATHCalculationUnderflow";
    case MATHCalculationOverflow:
      return @"MATHCalculationOverflow";
    case MATHCalculationDivideByZero:
      return @"MATHCalculationDivideByZero";
    case MATHCalculationInvalidCharacter:
      return @"MATHCalculationInvalidCharacter";
    case MATHCalculationMismatchedBrackets:
      return @"MATHCalculationMismatchedBrackets";
    case MATHCalculationMissingOperand:
      return @"MATHCalculationMissingOperand";
    case MATHCalculationResultNaN:
      return @"MATHCalculationResultNaN";
    case MATHCalculationResultInfinite:
      return @"MATHCalculationResultInfinite";
    case MATHCalculationResultImaginary:
      return @"MATHCalculationResultImaginary";
    case MATHCalculationRootByZero:
      return @"MATHCalculationIndexZero";
    case MATHCalculationArgumentNegative:
      return @"MATHCalculationArgumentNegative";
    case MATHCalculationBaseNegative:
      return @"MATHCalculationBaseNegative";
    case MATHCalculationBaseOne:
      return @"MATHCalculationBaseOne";
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHCalculationError(%d)", (int)error);
      return nil;
  }
}

// MARK: NSDecimalNumber Helper Methods

@implementation MATHSolverDecimalBehavior

-(id)initWithErrorPtr:(MATHCalculationErrorPointer)errorPtr;
{
  self = [super init];
  XPParameterRaise(self);
  _errorPtr = errorPtr;
  return self;
}

+(id)behaviorWithErrorPtr:(MATHCalculationErrorPointer)errorPtr;
{
  return [[[MATHSolverDecimalBehavior alloc] initWithErrorPtr:errorPtr] autorelease];
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
                                      error:(MATHCalculationError)error
                                leftOperand:(NSDecimalNumber*)leftOperand
                               rightOperand:(NSDecimalNumber*)rightOperand;
{
  // Log the error if needed
  switch (error) {
    case MATHCalculationNoError:
      break;
    default:
      XPLogDebug3(@"%@: lhs: %@ rhs: %@", MATHSolverDebugDescriptionForError(error), leftOperand, rightOperand);
      break;
  }
  
  // Configure the error pointer if needed
  switch (error) {
    case MATHCalculationNoError:
    case MATHCalculationLossOfPrecision:
    case MATHCalculationOverflow:
    case MATHCalculationUnderflow:
      *_errorPtr = MATHCalculationNoError;
      break;
    default:
      *_errorPtr = error;
      break;
  }
  
  // Decide what to do with the error.
  // Only divide by zero needs special action (according to docs)
  switch (error) {
    case MATHCalculationDivideByZero: return [NSDecimalNumber notANumber];
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

@implementation NSDecimalNumber (MathEdit)

-(BOOL)MATH_isNotANumber;
{
  NSString *lhsDescription = [self description];
  NSString *rhsDescription = [[NSDecimalNumber notANumber] description];
  return [lhsDescription isEqualToString:rhsDescription];
}

-(NSDecimalNumber*)MATH_decimalNumberByRaisingWithExponent:(NSDecimalNumber*)exponent
                                              withBehavior:(MATHSolverDecimalBehavior*)behavior;
{
  double baseRaw     = [self doubleValue];
  double exponentRaw = [exponent doubleValue];
  double baseMult    = (baseRaw < 0 && fmod(exponentRaw, 2) != 0) ? -1.0 : 1.0;
  double resultRaw   = 0;
  MATHCalculationError error = MATHCalculationNoError;
  
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
  
  if (error == MATHCalculationNoError) {
    resultRaw = pow(baseMult*baseRaw, exponentRaw) * baseMult;
    if (isnan(resultRaw)) {
      error = MATHCalculationResultNaN;
    }
    if (isinf(resultRaw)) {
      error = MATHCalculationResultInfinite;
    }
  }
  
  switch (error) {
    case MATHCalculationNoError:
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
                                             withBehavior:(MATHSolverDecimalBehavior*)behavior;
{
  double baseRaw     = [self doubleValue];
  double exponentRaw = [exponent doubleValue];
  double baseMult    = 1; // Used to counteract odd root of negative number
  double resultRaw   = 0;
  MATHCalculationError error = MATHCalculationNoError;
  
  if (exponentRaw == 0) {
    error = MATHCalculationRootByZero;
  }
  
  if (baseRaw < 0) {
    if (fmod(exponentRaw, 2) != 1) {
      error = MATHCalculationResultImaginary;
    } else {
      baseMult = -1;
    }
  }
  
  if (error == MATHCalculationNoError) {
    resultRaw = pow(baseMult * baseRaw, 1.0 / exponentRaw) * baseMult;
    if (isnan(resultRaw)) {
      error = MATHCalculationResultNaN;
    }
    if (isinf(resultRaw)) {
      error = MATHCalculationResultInfinite;
    }
  }
  
  switch (error) {
    case MATHCalculationNoError:
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
                                            withBehavior:(MATHSolverDecimalBehavior*)behavior;
{
  double argumentRaw = [self doubleValue];
  double baseRaw     = [base doubleValue];
  double resultRaw   = 0;
  MATHCalculationError error = MATHCalculationNoError;
  
  if (argumentRaw <= 0) {
    error = MATHCalculationArgumentNegative;
  }
  
  if (baseRaw <= 0) {
    error = MATHCalculationBaseNegative;
  }
  
  if (baseRaw == 1) {
    error = MATHCalculationBaseOne;
  }
  
  if (error == MATHCalculationNoError) {
    resultRaw = log(argumentRaw) / log(baseRaw);
    if (isnan(resultRaw)) {
      error = MATHCalculationResultNaN;
    }
    if (isinf(resultRaw)) {
      error = MATHCalculationResultInfinite;
    }
  }
  
  switch (error) {
    case MATHCalculationNoError:
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

// MARK: MATHSolverTextAttachment Input

NSString *const MATHSolverTextAttachmentBackgroundKey   = @"MATHSolverTextAttachmentBackground";
NSString *const MATHSolverTextAttachmentMixColorKey     = @"MATHSolverTextAttachmentMixColor";

NSString *const MATHSolverTextStyleMathFont      = @"MATHSolverTextStyleMathFont";
NSString *const MATHSolverTextStyleOtherFont     = @"MATHSolverTextStyleOtherFont";
NSString *const MATHSolverTextStyleOtherColor    = @"MATHSolverTextStyleOtherColor";
NSString *const MATHSolverTextStyleOperandColor  = @"MATHSolverTextStyleOperandColor";
NSString *const MATHSolverTextStyleOperatorColor = @"MATHSolverTextStyleOperatorColor";
NSString *const MATHSolverTextStylePreviousColor = @"MATHSolverTextStylePreviousColor";

// MARK: NSUserDefaults Helper Methods

@implementation NSUserDefaults (MATHSolverTextAttachmentStyles)

-(MATHSolverTextAttachmentStyles)MATH_stylesForSolution;
{
#ifdef AFF_NSBezierPathNone
  MATHSolverTextAttachmentBackground background = MATHSolverTextAttachmentBackgroundLegacyBoxStroke;
#else
  MATHSolverTextAttachmentBackground background = MATHSolverTextAttachmentBackgroundCapsuleFill;
#endif
  NSColor *mixColor = [self MATH_userInterfaceStyle] == XPUserInterfaceStyleDark
                      ? [NSColor whiteColor]
                      : [NSColor blackColor];
  return [NSDictionary __MATH_stylesWithFont:[self MATH_fontForTheme:MATHThemeFontMath]
                             foregroundColor:[self MATH_colorForTheme:MATHThemeColorOperandText]
                             backgroundColor:[self MATH_colorForTheme:MATHThemeColorSolution]
                                    mixColor:mixColor
                                  background:background];
}

-(MATHSolverTextAttachmentStyles)MATH_stylesForPreviousSolution;
{
#ifdef AFF_NSBezierPathNone
  MATHSolverTextAttachmentBackground background = MATHSolverTextAttachmentBackgroundLegacyBoxStroke;
#else
  MATHSolverTextAttachmentBackground background = MATHSolverTextAttachmentBackgroundCapsuleStroke;
#endif
  NSColor *mixColor = [self MATH_userInterfaceStyle] == XPUserInterfaceStyleDark
                      ? [NSColor whiteColor]
                      : [NSColor blackColor];
  return [NSDictionary __MATH_stylesWithFont:[self MATH_fontForTheme:MATHThemeFontMath]
                             foregroundColor:[self MATH_colorForTheme:MATHThemeColorOperandText]
                             backgroundColor:[self MATH_colorForTheme:MATHThemeColorSolutionSecondary]
                                    mixColor:mixColor
                                  background:background];
}

-(MATHSolverTextAttachmentStyles)MATH_stylesForError;
{
#ifdef AFF_NSBezierPathNone
  MATHSolverTextAttachmentBackground background = MATHSolverTextAttachmentBackgroundLegacyBoxStroke;
#else
  MATHSolverTextAttachmentBackground background = MATHSolverTextAttachmentBackgroundCapsuleStroke;
#endif
  NSColor *mixColor = [self MATH_userInterfaceStyle] == XPUserInterfaceStyleDark
                      ? [NSColor whiteColor]
                      : [NSColor blackColor];
  return [NSDictionary __MATH_stylesWithFont:[self MATH_fontForTheme:MATHThemeFontError]
                             foregroundColor:[self MATH_colorForTheme:MATHThemeColorOperandText]
                             backgroundColor:[self MATH_colorForTheme:MATHThemeColorErrorText]
                                    mixColor:mixColor
                                  background:background];
}

-(MATHSolverTextStyles)MATH_stylesForText;
{
  NSFont  *mathFont       = [self MATH_fontForTheme:MATHThemeFontMath];
  NSFont  *otherTextFont  = [self MATH_fontForTheme:MATHThemeFontOther];
  NSColor *otherTextColor = [self MATH_colorForTheme:MATHThemeColorOtherText];
  NSColor *operandColor   = [self MATH_colorForTheme:MATHThemeColorOperandText];
  NSColor *operatorColor  = [self MATH_colorForTheme:MATHThemeColorOperatorText];
  NSColor *previousColor  = [self MATH_colorForTheme:MATHThemeColorSolutionSecondary];
  
  return [NSDictionary __MATH_stylesWithMathFont:mathFont
                                    neighborFont:otherTextFont
                                  otherTextColor:otherTextColor
                                    operandColor:operandColor
                                   operatorColor:operatorColor
                                   previousColor:previousColor];
}

@end

@implementation NSDictionary (MATHSolverTextAttachmentStyles)

+(MATHSolverTextAttachmentStyles)__MATH_stylesWithFont:(NSFont*)font
                                       foregroundColor:(NSColor*)foregroundColor
                                       backgroundColor:(NSColor*)backgroundColor
                                              mixColor:(NSColor*)mixColor
                                            background:(MATHSolverTextAttachmentBackground)purpose;
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
          MATHSolverTextAttachmentMixColorKey,
          MATHSolverTextAttachmentBackgroundKey,
          nil];
  
  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

+(MATHSolverTextAttachmentStyles)__MATH_stylesWithMathFont:(NSFont*)mathFont
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
          MATHSolverTextStyleMathFont,
          MATHSolverTextStyleOtherFont,
          MATHSolverTextStyleOtherColor,
          MATHSolverTextStyleOperandColor,
          MATHSolverTextStyleOperatorColor,
          MATHSolverTextStylePreviousColor,
          nil];
  
  return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

@end
