//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>

@interface SVRSolverSolutionTagger: NSObject

+(NSDecimalNumber*)solveTaggedString:(NSAttributedString*)input;

@end

@interface SVRSolverSolutionTagger (Tests)
+(void)executeTests;
@end
