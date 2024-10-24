//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverStyler.h"
#import "XPCrossPlatform.h"
#import "SVRSolverSolutionTagger.h"
#import "SVRSolver.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRSolverStyler

+(void)styleTaggedExpression:(NSMutableAttributedString*)input;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUInteger index = 0;
  NSRange checkRange = XPNotFoundRange;
  id check = nil;
  
  // Give everything default appearance
  [input addAttribute:NSFontAttributeName
                value:[ud SVR_fontForText]
                range:NSMakeRange(0, [input length])];
  [input addAttribute:NSForegroundColorAttributeName
                value:[ud SVR_colorForText]
                range:NSMakeRange(0, [input length])];
  
  while (index < [input length]) {
    check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                     atIndex:index
              effectiveRange:&checkRange];
    if (check) {
      [input addAttribute:NSForegroundColorAttributeName
                    value:[ud SVR_colorForNumeral]
                    range:checkRange];
    } else {
      check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)
                       atIndex:index
                effectiveRange:&checkRange];
      if (check) {
        [input addAttribute:NSForegroundColorAttributeName
                      value:[ud SVR_colorForBracket]
                      range:checkRange];
      } else {
        check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                         atIndex:index
                  effectiveRange:&checkRange];
        if (check) {
          [input addAttribute:NSForegroundColorAttributeName
                        value:[ud SVR_colorForOperator]
                        range:checkRange];
        } else {
          check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)
                           atIndex:index
                    effectiveRange:&checkRange];
          if (check) {
            [input addAttribute:NSForegroundColorAttributeName
                          value:[ud SVR_colorForOperator]
                          range:checkRange];
          }
        }
      }
    }
    
    if (XPIsNotFoundRange(checkRange)) {
      index += 1;
    } else {
      index = NSMaxRange(checkRange);
    }
  }
}

@end
