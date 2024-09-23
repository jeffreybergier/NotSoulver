//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>
#import "SVRCrossPlatform.h"

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)annotateStorage:(NSMutableAttributedString*)input;
+(void)solveAnnotatedStorage:(NSMutableAttributedString*)input;
+(void)colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

// MARK: Private: annotateStorage
+(void)__annotateExpressions:(NSMutableAttributedString*)input;
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
                            leftString:(NSString*)leftString
                           rightString:(NSString*)rightString;
+(NSAttributedString*)__solveAttributedStringForPatchingWithDecimalNumber:(NSDecimalNumber*)number;
+(BOOL)__solveValidateOnlyNumeralsInAttributedString:(NSAttributedString*)string;

// MARK: Private: colorAnnotatedAndSolvedStorage
+(void)__colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end
