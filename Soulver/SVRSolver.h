//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"

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

XPAttributedStringKey XPAttributedStringKeyForTag(SVRSolverTag tag);
SVRSolverTag SVRSolverTagForKey(XPAttributedStringKey string);
NSNumber* NSNumberForOperator(SVRSolverOperator operator);
SVRSolverOperator SVRSolverOperatorForNumber(NSNumber *number);
SVRSolverOperator SVRSolverOperatorForRawString(NSString *string);

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)removeAllSolutionsAndTags:(NSMutableAttributedString*)input;
+(void)solveAndTagAttributedString:(NSMutableAttributedString*)input;
+(void)styleSolvedAndTaggedAttributedString:(NSMutableAttributedString*)input;

+(void)__decodeExpressionTerminator:(NSMutableAttributedString*)input;

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end
