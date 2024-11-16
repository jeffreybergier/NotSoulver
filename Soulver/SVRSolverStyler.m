//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
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
                value:[ud SVR_fontForTheme:SVRThemeFontOther]
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
                    value:[ud SVR_fontForTheme:SVRThemeFontMath]
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
                      value:[ud SVR_fontForTheme:SVRThemeFontMath]
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
                        value:[ud SVR_fontForTheme:SVRThemeFontMath]
                        range:checkRange];
          [input addAttribute:NSForegroundColorAttributeName
                        value:[ud SVR_colorForTheme:SVRThemeColorOperator]
                        range:checkRange];
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
