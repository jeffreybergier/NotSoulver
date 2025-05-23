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

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"

typedef NSDictionary* SVRSolverTextAttachmentStyles;
typedef NSDictionary* SVRSolverTextStyles;

// MARK: SVRSolver

@interface SVRSolver: NSObject

// MARK: Configure Constants
+(void)initialize;

// MARK: Business Logic
+(void)solveAttributedString:(NSMutableAttributedString*)input
              solutionStyles:(SVRSolverTextAttachmentStyles)solutionStyles
      previousSolutionStyles:(SVRSolverTextAttachmentStyles)previousSolutionStyles
                 errorStyles:(SVRSolverTextAttachmentStyles)errorStyles
                  textStyles:(SVRSolverTextStyles)textStyles;

// Returns mutable string to avoid making an immutable copy, but it is still a copy of the original string
+(NSAttributedString*)replacingAttachmentsWithOriginalCharacters:(NSAttributedString*)input;
// Returns mutable string to avoid making an immutable copy, but it is still a copy of the original string
+(NSAttributedString*)replacingAttachmentsWithStringValue:(NSAttributedString*)input;

// MARK: Private
+(void)__step1_restoreOriginals:(NSMutableAttributedString*)input;
+(void)__step2_removeAllTags:(NSMutableAttributedString*)input;
+(void)__step3_scanAndTag:(NSMutableAttributedString*)input;
+(void)__step4_solveAndTag:(NSMutableAttributedString*)input
            solutionStyles:(SVRSolverTextAttachmentStyles)solutionStyles
    previousSolutionStyles:(SVRSolverTextAttachmentStyles)previousSolutionStyles
               errorStyles:(SVRSolverTextAttachmentStyles)errorStyles;
+(void)__step5_styleAndTag:(NSMutableAttributedString*)input
                    styles:(SVRSolverTextStyles)styles;


@end

// MARK: Enumerations

typedef XP_ENUM(XPInteger, SVRSolverTag) {
  // Stores NSDecimalNumber
  SVRSolverTagNumber,
  // Stores NSString of the range of the bracket
  // NSStringFromRange (use NSRangeFromString to extract)
  SVRSolverTagBracket,
  // Stores NSNumber containing the SVRSoulverOperator
  SVRSolverTagOperator,
  // Stores NSString of the range of the bracket - (Minus the Equal Sign)
  // NSStringFromRange (use NSRangeFromString to extract)
  SVRSolverTagExpression,
  // Stores NSString with the original value
  // before it was replaced with NSTextAttachment
  SVRSolverTagOriginal
};

typedef XP_ENUM(XPInteger, SVRSolverOperator) {
  SVRSolverOperatorExponent,
  SVRSolverOperatorDivide,
  SVRSolverOperatorMultiply,
  SVRSolverOperatorSubtract,
  SVRSolverOperatorAdd,
  SVRSolverOperatorRoot,
  SVRSolverOperatorLog,
  SVRSolverOperatorUnknown
};

typedef XP_ENUM(XPInteger, SVRCalculationError) {
  SVRCalculationNoError            = NSCalculationNoError,
  SVRCalculationLossOfPrecision    = NSCalculationLossOfPrecision,
  SVRCalculationUnderflow          = NSCalculationUnderflow,
  SVRCalculationOverflow           = NSCalculationOverflow,
  SVRCalculationDivideByZero       = NSCalculationDivideByZero,
  SVRCalculationInvalidCharacter   = 105,
  SVRCalculationMismatchedBrackets = 106,
  SVRCalculationMissingOperand     = 107,
  SVRCalculationResultNaN          = 108,
  SVRCalculationResultInfinite     = 109,
  SVRCalculationResultImaginary    = 110,
  SVRCalculationRootByZero         = 111,
  SVRCalculationArgumentNegative   = 112,
  SVRCalculationBaseNegative       = 113,
  SVRCalculationBaseOne            = 114,
};

typedef SVRCalculationError* SVRCalculationErrorPointer;

// MARK: SVRSolverTextAttachment Input

typedef XP_ENUM(XPInteger, SVRSolverTextAttachmentBackground) {
  SVRSolverTextAttachmentBackgroundCapsuleFill,
  SVRSolverTextAttachmentBackgroundCapsuleStroke,
  SVRSolverTextAttachmentBackgroundLegacyBoxStroke
};

extern NSString *const SVRSolverTextAttachmentBackgroundKey;
extern NSString *const SVRSolverTextAttachmentMixColorKey;

extern NSString *const SVRSolverTextStyleMathFont;
extern NSString *const SVRSolverTextStyleOtherFont;
extern NSString *const SVRSolverTextStyleOtherColor;
extern NSString *const SVRSolverTextStyleOperandColor;
extern NSString *const SVRSolverTextStyleOperatorColor;
extern NSString *const SVRSolverTextStyleBracketColor;

// MARK: Enumeration Helper Functions

XPAttributedStringKey XPAttributedStringKeyForTag(SVRSolverTag tag);
SVRSolverTag          SVRSolverTagForKey(XPAttributedStringKey string);
NSNumber             *NSNumberForOperator(SVRSolverOperator operator);
SVRSolverOperator     SVRSolverOperatorForNumber(NSNumber *number);
SVRSolverOperator     SVRSolverOperatorForRawString(NSString *string);
NSString             *RawStringForOperator(SVRSolverOperator operator);
NSString             *SVRSolverDescriptionForError(SVRCalculationError error);
NSString             *SVRSolverDebugDescriptionForError(SVRCalculationError error);

// MARK: NSDecimalNumber Helper Methods

@interface SVRSolverDecimalBehavior: NSObject <NSDecimalNumberBehaviors>
{
  SVRCalculationErrorPointer _errorPtr;
}
-(id)initWithErrorPtr:(SVRCalculationErrorPointer)errorPtr;
+(id)behaviorWithErrorPtr:(SVRCalculationErrorPointer)errorPtr;
-(NSRoundingMode)roundingMode;
-(short)scale;
-(NSDecimalNumber*)exceptionDuringOperation:(SEL)operation
                                      error:(SVRCalculationError)error
                                leftOperand:(NSDecimalNumber*)leftOperand
                               rightOperand:(NSDecimalNumber*)rightOperand;
@end

@interface NSDecimalNumber (Soulver)

/// In OpenStep, NaN comparisons are weird, so this uses a string comparison
-(BOOL)SVR_isNotANumber;

-(NSDecimalNumber*)SVR_decimalNumberByRaisingWithExponent:(NSDecimalNumber*)exponent
                                             withBehavior:(SVRSolverDecimalBehavior*)behavior;
-(NSDecimalNumber*)SVR_decimalNumberByRootingWithExponent:(NSDecimalNumber*)exponent
                                             withBehavior:(SVRSolverDecimalBehavior*)behavior;
/// 10L100=2 10=base 100=argument (self)
-(NSDecimalNumber*)SVR_decimalNumberByLogarithmWithBase:(NSDecimalNumber*)base
                                           withBehavior:(SVRSolverDecimalBehavior*)behavior;
@end

// MARK: NSUserDefaults Helper Methods

@interface NSUserDefaults (SVRSolverTextAttachmentStyles)

-(SVRSolverTextAttachmentStyles)SVR_stylesForSolution;
-(SVRSolverTextAttachmentStyles)SVR_stylesForPreviousSolution;
-(SVRSolverTextAttachmentStyles)SVR_stylesForError;
-(SVRSolverTextStyles)SVR_stylesForText;

@end

@interface NSDictionary (SVRSolverTextAttachmentStyles)

+(SVRSolverTextAttachmentStyles)__SVR_stylesWithFont:(NSFont*)font
                                     foregroundColor:(NSColor*)foregroundColor
                                     backgroundColor:(NSColor*)backgroundColor
                                            mixColor:(NSColor*)mixColor
                                          background:(SVRSolverTextAttachmentBackground)purpose;

+(SVRSolverTextAttachmentStyles)__SVR_stylesWithMathFont:(NSFont*)mathFont
                                            neighborFont:(NSFont*)otherTextFont
                                          otherTextColor:(NSColor*)otherTextColor
                                            operandColor:(NSColor*)operandColor
                                           operatorColor:(NSColor*)operatorColor
                                            previousColor:(NSColor*)previousColor;

@end
