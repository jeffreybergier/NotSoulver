//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>

@interface SVRSolverSolutionTagger: NSObject
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(NSNumber**)errorPtr;
@end

@interface SVRSolverSolutionTagger (Tests)
+(void)executeTests;
@end
