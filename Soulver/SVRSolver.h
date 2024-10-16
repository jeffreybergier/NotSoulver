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
  // Stores NSValue of the range of the bracket
  SVRSolverTagBracket,
  // Stores NSNumber containing the SVRSoulverOperator
  SVRSolverTagOperator,
  // Stores NSValue of the range of the expression (minus the = sign)
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

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end
