//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>

typedef enum {
  // Stores NSDecimalNumber
  SVRSolverTagNumber,
  // Stores NSValue of the range of the bracket
  SVRSolverTagBracket,
  // Stores NSNumber containing the SVRSoulverOperator
  SVRSolverTagOperator,
  // Stores NSValue of the range of the expression
  SVRSolverTagExpression,
  // Stores NSDecimalNumber with the solution for the expression
  SVRSolverTagExpressionSolution,
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

NSString *SVR_stringForTag(SVRSolverTag tag);
SVRSolverTag SVR_tagForString(NSString *string);
NSNumber* SVR_numberForOperator(SVRSolverOperator operator);
SVRSolverOperator SVR_operatorForRawString(NSString *string);
SVRSolverOperator SVR_operatorForNumber(NSNumber *number);

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)annotateStorage:(NSMutableAttributedString*)input;
+(void)solveAnnotatedStorage:(NSMutableAttributedString*)input;
+(void)colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

// MARK: Private
+(void)__removeAllAttributesInStorage:(NSMutableAttributedString*)input;

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end
