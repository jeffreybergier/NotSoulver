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

// MARK: Private: annotateStorage
+(void)__solveExpressions:(NSMutableAttributedString*)input;
+(BOOL)__solveIsValidSolutionInStorage:(NSMutableAttributedString*)input
                forExpressionWithRange:(NSRange)range;
+(NSAttributedString*)__solvePEMDASInExpression:(NSAttributedString*)input;
+(NSRange)__solveRangeForBracketsInExpression:(NSAttributedString*)input;
+(NSAttributedString*)__solveSubexpression:(NSAttributedString*)input
                         forOperatorsInSet:(NSSet*)operators
                          rangeForPatching:(NSRange*)range;

// MARK: Private: colorAnnotatedAndSolvedStorage
+(void)__colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end
