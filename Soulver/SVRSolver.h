//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>
#import "SVRCrossPlatform.h"

/// Used by SVRSolverTagger
typedef enum {
  // Stores NSDecimalNumber
  SVRSolverTagNumber,
  // Stores NSNumber containing the SVRSoulverOperator
  SVRSolverTagOperator,
  // Stores NSValue of the range of the expression
  SVRSolverTagExpression,
  // Stores NSValue of the range of the bracket
  SVRSolverTagBracket,
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
SVRSolverOperator SVR_operatorForString(NSString *string);

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)annotateStorage:(NSMutableAttributedString*)input;
+(void)solveAnnotatedStorage:(NSMutableAttributedString*)input;
+(void)colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

// MARK: Private: annotateStorage
+(void)__annotateBrackets:(NSMutableAttributedString*)input;
+(void)__annotateOperators:(NSMutableAttributedString*)input;
+(void)__annotateNumerals:(NSMutableAttributedString*)input;

// MARK: Private: solveAnnotatedStorage
+(void)__solveExpressions:(NSMutableAttributedString*)input;
+(BOOL)__solveIsSolvedExpressionInStorage:(NSMutableAttributedString*)input
                                withRange:(NSRange)range
                         rangeOfEqualSign:(NSRange*)rangeOfEqualSign;
+(NSDecimalNumber*)__solveMathInExpression:(NSAttributedString*)input;
+(NSValue*)__solveRangeForNextBracketsInExpression:(NSAttributedString*)input;
+(NSDecimalNumber*)__solveNextSubexpressionInExpression:(NSAttributedString*)expression
                                      forOperatorsInSet:(NSSet*)operators
                                   rangeOfSubexpression:(NSRange*)range;
+(NSDecimalNumber*)__solveWithOperator:(NSString*)anOp
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs;
+(NSAttributedString*)__solveAttributedStringForPatchingWithDecimalNumber:(NSDecimalNumber*)number;
+(BOOL)__solveValidateOnlyNumeralsInAttributedString:(NSAttributedString*)string;

// MARK: Private: colorAnnotatedAndSolvedStorage
+(void)__colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end
