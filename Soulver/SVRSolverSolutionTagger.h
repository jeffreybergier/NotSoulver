//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "SVRSolver.h"

@interface SVRSolverSolutionTagger: NSObject

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;

// MARK: Private
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(NSNumber**)errorPtr;
+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(NSNumber **)errorPtr;
+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(NSRange*)rangePtr
                                        error:(NSNumber**)errorPtr;
+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
+(NSDecimalNumber*)__solveWithOperator:(SVRSolverOperator)operator
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs;

@end

@interface SVRSolverSolutionTagger (Tests)
+(NSMutableAttributedString*)executeTests;
@end
