//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>

@interface SVRSolverSolutionTagger: NSObject

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;

// MARK: Private
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(NSNumber**)errorPtr;
+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(NSRange*)rangePtr
                                        error:(NSNumber**)errorPtr;
+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;

@end

@interface SVRSolverSolutionTagger (Tests)
+(void)executeTests;
@end
