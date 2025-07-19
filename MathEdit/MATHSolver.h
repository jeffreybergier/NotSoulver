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

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"

typedef NSDictionary* MATHSolverTextAttachmentStyles;
typedef NSDictionary* MATHSolverTextStyles;

// MARK: MATHSolver

@interface MATHSolver: NSObject

// MARK: Configure Constants
+(void)initialize;

// MARK: Business Logic
+(BOOL)solveAttributedString:(NSMutableAttributedString*)input
              solutionStyles:(MATHSolverTextAttachmentStyles)solutionStyles
      previousSolutionStyles:(MATHSolverTextAttachmentStyles)previousSolutionStyles
                 errorStyles:(MATHSolverTextAttachmentStyles)errorStyles
                  textStyles:(MATHSolverTextStyles)textStyles
                       error:(XPErrorPointer)outError;

// Returns mutable string to avoid making an immutable copy, but it is still a copy of the original string
+(NSAttributedString*)replacingAttachmentsWithOriginalCharacters:(NSAttributedString*)input;
// Returns mutable string to avoid making an immutable copy, but it is still a copy of the original string
+(NSAttributedString*)replacingAttachmentsWithStringValue:(NSAttributedString*)input;

// MARK: Private
+(void)__step1_restoreOriginals:(NSMutableAttributedString*)input;
+(void)__step2_removeAllTags:(NSMutableAttributedString*)input;
+(void)__step3_scanAndTag:(NSMutableAttributedString*)input;
+(void)__step4_solveAndTag:(NSMutableAttributedString*)input
            solutionStyles:(MATHSolverTextAttachmentStyles)solutionStyles
    previousSolutionStyles:(MATHSolverTextAttachmentStyles)previousSolutionStyles
               errorStyles:(MATHSolverTextAttachmentStyles)errorStyles;
+(void)__step5_styleAndTag:(NSMutableAttributedString*)input
                    styles:(MATHSolverTextStyles)styles;


@end

// MARK: Enumerations

typedef XP_ENUM(XPInteger, MATHSolverTag) {
  // Stores NSDecimalNumber
  MATHSolverTagNumber,
  // Stores NSString of the range of the bracket
  // NSStringFromRange (use NSRangeFromString to extract)
  MATHSolverTagBracket,
  // Stores NSNumber containing the MATHSolverOperator
  MATHSolverTagOperator,
  // Stores NSString of the range of the bracket - (Minus the Equal Sign)
  // NSStringFromRange (use NSRangeFromString to extract)
  MATHSolverTagExpression,
  // Stores NSString with the original value
  // before it was replaced with NSTextAttachment
  MATHSolverTagOriginal
};

typedef XP_ENUM(XPInteger, MATHSolverOperator) {
  MATHSolverOperatorExponent,
  MATHSolverOperatorDivide,
  MATHSolverOperatorMultiply,
  MATHSolverOperatorSubtract,
  MATHSolverOperatorAdd,
  MATHSolverOperatorRoot,
  MATHSolverOperatorLog,
  MATHSolverOperatorUnknown
};

typedef XP_ENUM(XPInteger, MATHCalculationError) {
  MATHCalculationNoError            = NSCalculationNoError,
  MATHCalculationLossOfPrecision    = NSCalculationLossOfPrecision,
  MATHCalculationUnderflow          = NSCalculationUnderflow,
  MATHCalculationOverflow           = NSCalculationOverflow,
  MATHCalculationDivideByZero       = NSCalculationDivideByZero,
  MATHCalculationInvalidCharacter   = 105,
  MATHCalculationMismatchedBrackets = 106,
  MATHCalculationMissingOperand     = 107,
  MATHCalculationResultNaN          = 108,
  MATHCalculationResultInfinite     = 109,
  MATHCalculationResultImaginary    = 110,
  MATHCalculationRootByZero         = 111,
  MATHCalculationArgumentNegative   = 112,
  MATHCalculationBaseNegative       = 113,
  MATHCalculationBaseOne            = 114,
};

typedef MATHCalculationError* MATHCalculationErrorPointer;

// MARK: MATHSolverTextAttachment Input

typedef XP_ENUM(XPInteger, MATHSolverTextAttachmentBackground) {
  MATHSolverTextAttachmentBackgroundCapsuleFill,
  MATHSolverTextAttachmentBackgroundCapsuleStroke,
  MATHSolverTextAttachmentBackgroundLegacyBoxStroke
};

extern NSString *const MATHSolverTextAttachmentBackgroundKey;
extern NSString *const MATHSolverTextAttachmentMixColorKey;

extern NSString *const MATHSolverTextStyleMathFont;
extern NSString *const MATHSolverTextStyleOtherFont;
extern NSString *const MATHSolverTextStyleOtherColor;
extern NSString *const MATHSolverTextStyleOperandColor;
extern NSString *const MATHSolverTextStyleOperatorColor;
extern NSString *const MATHSolverTextStyleBracketColor;

// MARK: Enumeration Helper Functions

XPAttributedStringKey XPAttributedStringKeyForTag(MATHSolverTag tag);
MATHSolverTag         MATHSolverTagForKey(XPAttributedStringKey string);
NSNumber             *NSNumberForOperator(MATHSolverOperator operator);
MATHSolverOperator    MATHSolverOperatorForNumber(NSNumber *number);
MATHSolverOperator    MATHSolverOperatorForRawString(NSString *string);
NSString             *RawStringForOperator(MATHSolverOperator operator);
NSString             *MATHSolverDescriptionForError(MATHCalculationError error);
NSString             *MATHSolverDebugDescriptionForError(MATHCalculationError error);

// MARK: NSDecimalNumber Helper Methods

@interface MATHSolverDecimalBehavior: NSObject <NSDecimalNumberBehaviors>
{
  MATHCalculationErrorPointer _errorPtr;
}
-(id)initWithErrorPtr:(MATHCalculationErrorPointer)errorPtr;
+(id)behaviorWithErrorPtr:(MATHCalculationErrorPointer)errorPtr;
-(NSRoundingMode)roundingMode;
-(short)scale;
-(NSDecimalNumber*)exceptionDuringOperation:(SEL)operation
                                      error:(MATHCalculationError)error
                                leftOperand:(NSDecimalNumber*)leftOperand
                               rightOperand:(NSDecimalNumber*)rightOperand;
@end

@interface NSDecimalNumber (MathEdit)

/// In OpenStep, NaN comparisons are weird, so this uses a string comparison
-(BOOL)MATH_isNotANumber;

-(NSDecimalNumber*)MATH_decimalNumberByRaisingWithExponent:(NSDecimalNumber*)exponent
                                              withBehavior:(MATHSolverDecimalBehavior*)behavior;
-(NSDecimalNumber*)MATH_decimalNumberByRootingWithExponent:(NSDecimalNumber*)exponent
                                              withBehavior:(MATHSolverDecimalBehavior*)behavior;
/// 10L100=2 10=base 100=argument (self)
-(NSDecimalNumber*)MATH_decimalNumberByLogarithmWithBase:(NSDecimalNumber*)base
                                            withBehavior:(MATHSolverDecimalBehavior*)behavior;
@end

// MARK: NSUserDefaults Helper Methods

@interface NSUserDefaults (MATHSolverTextAttachmentStyles)

-(MATHSolverTextAttachmentStyles)MATH_stylesForSolution;
-(MATHSolverTextAttachmentStyles)MATH_stylesForPreviousSolution;
-(MATHSolverTextAttachmentStyles)MATH_stylesForError;
-(MATHSolverTextStyles)MATH_stylesForText;

@end

@interface NSDictionary (MATHSolverTextAttachmentStyles)

+(MATHSolverTextAttachmentStyles)__MATH_stylesWithFont:(NSFont*)font
                                       foregroundColor:(NSColor*)foregroundColor
                                       backgroundColor:(NSColor*)backgroundColor
                                              mixColor:(NSColor*)mixColor
                                            background:(MATHSolverTextAttachmentBackground)purpose;

+(MATHSolverTextAttachmentStyles)__MATH_stylesWithMathFont:(NSFont*)mathFont
                                              neighborFont:(NSFont*)otherTextFont
                                            otherTextColor:(NSColor*)otherTextColor
                                              operandColor:(NSColor*)operandColor
                                             operatorColor:(NSColor*)operatorColor
                                             previousColor:(NSColor*)previousColor;

@end
