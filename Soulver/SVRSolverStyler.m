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
                value:[ud SVR_fontForTheme:SVRThemeFontOtherText]
                range:NSMakeRange(0, [input length])];
  [input addAttribute:NSForegroundColorAttributeName
                value:[ud SVR_colorForTheme:SVRThemeColorOtherText]
                range:NSMakeRange(0, [input length])];
  
  while (index < [input length]) {
    check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                     atIndex:index
              effectiveRange:&checkRange];
    if (check) {
      [input addAttribute:NSFontAttributeName
                    value:[ud SVR_fontForTheme:SVRThemeFontMathText]
                    range:checkRange];
      [input addAttribute:NSForegroundColorAttributeName
                    value:[ud SVR_colorForTheme:SVRThemeColorOperand]
                    range:checkRange];
    } else {
      check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)
                       atIndex:index
                effectiveRange:&checkRange];
      if (check) {
        [input addAttribute:NSFontAttributeName
                      value:[ud SVR_fontForTheme:SVRThemeFontMathText]
                      range:checkRange];
        [input addAttribute:NSForegroundColorAttributeName
                      value:[ud SVR_colorForTheme:SVRThemeColorBracket]
                      range:checkRange];
      } else {
        check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                         atIndex:index
                  effectiveRange:&checkRange];
        if (check) {
          [input addAttribute:NSFontAttributeName
                        value:[ud SVR_fontForTheme:SVRThemeFontMathText]
                        range:checkRange];
          [input addAttribute:NSForegroundColorAttributeName
                        value:[ud SVR_colorForTheme:SVRThemeColorOperator]
                        range:checkRange];
        } else {
          check = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution)
                           atIndex:index
                    effectiveRange:&checkRange];
          if (check) {
            [input addAttribute:NSFontAttributeName
                          value:[ud SVR_fontForTheme:SVRThemeFontMathText]
                          range:checkRange];
            [input addAttribute:NSForegroundColorAttributeName
                          value:[ud SVR_colorForTheme:SVRThemeColorSolutionSecondary]
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
