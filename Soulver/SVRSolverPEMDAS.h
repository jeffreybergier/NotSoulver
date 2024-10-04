//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>

@interface SVRSolverPEMDAS: NSObject

+(NSDecimalNumber*)solveTaggedString:(NSAttributedString*)input;

@end

@interface SVRSolverPEMDAS (Tests)
+(void)executeTests;
@end
