//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"

// MARK: SVRSolver

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)solveAttributedString:(NSMutableAttributedString*)input;

// MARK: Private
+(void)__step1_decodeExpressionTerminator:(NSMutableAttributedString*)input;
+(void)__step2_removeAllTags:(NSMutableAttributedString*)input;
+(void)__step3_scanAndTag:(NSMutableAttributedString*)input;
+(void)__step4_solveAndTag:(NSMutableAttributedString*)input;
+(void)__step5_styleAndTag:(NSMutableAttributedString*)input;


@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end

// MARK: Enumerations

typedef enum {
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
  // Stores NSDecimalNumber with the solution for the expression in the = sign
  // Stores NSNumber if its an error
  SVRSolverTagSolution,
  // Stores NSDecimalNumber with the solution of the previous expression
  SVRSolverTagPreviousSolution,
} SVRSolverTag;

typedef enum {
  SVRSolverOperatorExponent,
  SVRSolverOperatorDivide,
  SVRSolverOperatorMultiply,
  SVRSolverOperatorSubtract,
  SVRSolverOperatorAdd,
} SVRSolverOperator;

typedef enum {
  SVRSolverErrorNone = -1,
  SVRSolverErrorInvalidCharacter = -1001,
  SVRSolverErrorMismatchedBrackets = -1002,
  SVRSolverErrorMissingOperand = -1003,
  SVRSolverErrorDivideByZero = -1004,
} SVRSolverError;

typedef SVRSolverError* SVRSolverErrorPointer;

// MARK: Enumeration Helper Functions

XPAttributedStringKey XPAttributedStringKeyForTag(SVRSolverTag tag);
SVRSolverTag          SVRSolverTagForKey(XPAttributedStringKey string);
NSNumber             *NSNumberForOperator(SVRSolverOperator operator);
SVRSolverOperator     SVRSolverOperatorForNumber(NSNumber *number);
SVRSolverOperator     SVRSolverOperatorForRawString(NSString *string);
NSString             *SVRSolverDescriptionForError(SVRSolverError error);
NSString             *SVRSolverDebugDescriptionForError(SVRSolverError error);
