//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverStyler.h"
#import "SVRCrossPlatform.h"
#import "SVRSolver.h"

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
    check = [input attribute:SVR_stringForTag(SVRSolverTagNumber)
                     atIndex:index
              effectiveRange:&checkRange];
    if (check) {
      [input addAttribute:NSForegroundColorAttributeName
                    value:[ud SVR_colorForNumeral]
                    range:checkRange];
    } else {
      check = [input attribute:SVR_stringForTag(SVRSolverTagBracket)
                       atIndex:index
                effectiveRange:&checkRange];
      if (check) {
        [input addAttribute:NSForegroundColorAttributeName
                      value:[ud SVR_colorForBracket]
                      range:checkRange];
      } else {
        check = [input attribute:SVR_stringForTag(SVRSolverTagOperator)
                         atIndex:index
                  effectiveRange:&checkRange];
        if (check) {
          [input addAttribute:NSForegroundColorAttributeName
                        value:[ud SVR_colorForOperator]
                        range:checkRange];
        } else {
          check = [input attribute:SVR_stringForTag(SVRSolverTagSolution)
                           atIndex:index
                    effectiveRange:&checkRange];
          if (check) {
            [input addAttribute:NSForegroundColorAttributeName
                          value:[ud SVR_colorForSolutionPrimary]
                          range:checkRange];
            [input addAttribute:NSBackgroundColorAttributeName
                          value:[ud SVR_backgroundColorForSolutionPrimary]
                          range:checkRange];
          } else {
            check = [input attribute:SVR_stringForTag(SVRSolverTagSolutionError)
                             atIndex:index
                      effectiveRange:&checkRange];
            if (check) {
              [input addAttribute:NSForegroundColorAttributeName
                            value:[NSColor orangeColor]
                            range:checkRange];
            }
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

#import "SVRSolverSolutionInserter.h"

@implementation SVRSolverStyler (Tests)
+(void)executeTests;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSMutableAttributedString *input = [SVRSolverSolutionInserter executeTests];
  XPColor *output = nil;
  
  [XPLog alwys:@"SVRSolverStyler Tests: Starting"];
  [SVRSolverStyler styleTaggedExpression:input];
  
  // Iterate through the string to verify attributes
  output = [input attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForBracket]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:1 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:2 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:4 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:5 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForOperator]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:6 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:7 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForBracket]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:8 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForOperator]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:9 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:10 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:11 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForNumeral]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:12 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForText]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:13 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForSolutionPrimary]], @"");
  output = [input attribute:NSBackgroundColorAttributeName atIndex:13 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_backgroundColorForSolutionPrimary]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:14 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForSolutionPrimary]], @"");
  output = [input attribute:NSBackgroundColorAttributeName atIndex:14 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_backgroundColorForSolutionPrimary]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:15 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForSolutionPrimary]], @"");
  output = [input attribute:NSBackgroundColorAttributeName atIndex:15 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_backgroundColorForSolutionPrimary]], @"");
  
  output = [input attribute:NSForegroundColorAttributeName atIndex:16 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_colorForSolutionPrimary]], @"");
  output = [input attribute:NSBackgroundColorAttributeName atIndex:16 effectiveRange:NULL];
  NSAssert([output isEqual:[ud SVR_backgroundColorForSolutionPrimary]], @"");
  
  [XPLog alwys:@"SVRSolverStyler Tests: Passed"];
}
@end
