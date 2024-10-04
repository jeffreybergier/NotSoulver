//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>

@interface SVRSolverTagger: NSObject

+(void)tagNumbersAtRanges:(NSSet*)ranges
       inAttributedString:(NSMutableAttributedString*)string;
+(void)tagOperatorsAtRanges:(NSSet*)ranges
         inAttributedString:(NSMutableAttributedString*)string;
+(void)tagExpressionsAtRanges:(NSSet*)ranges
           inAttributedString:(NSMutableAttributedString*)string;
+(void)tagBracketsAtRanges:(NSSet*)ranges
        inAttributedString:(NSMutableAttributedString*)string;

@end

@interface SVRSolverTagger (Tests)
+(NSMutableAttributedString*)executeTests;
@end
