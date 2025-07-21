//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "MATHSolverStyler.h"
#import "XPCrossPlatform.h"
#import "MATHSolverSolutionTagger.h"
#import "MATHSolver.h"

@implementation MATHSolverStyler

+(void)styleTaggedExpression:(NSMutableAttributedString*)input
                      styles:(MATHSolverTextAttachmentStyles)styles;
{
  XPUInteger index = 0;
  NSRange checkRange = XPNotFoundRange;
  id check = nil;
  
  NSFont  *mathFont       = [styles objectForKey:MATHSolverTextStyleMathFont];
  NSFont  *otherTextFont  = [styles objectForKey:MATHSolverTextStyleOtherFont];
  NSColor *otherTextColor = [styles objectForKey:MATHSolverTextStyleOtherColor];
  NSColor *operandColor   = [styles objectForKey:MATHSolverTextStyleOperandColor];
  NSColor *operatorColor  = [styles objectForKey:MATHSolverTextStyleOperatorColor];
  
  XPParameterRaise(mathFont);
  XPParameterRaise(otherTextFont);
  XPParameterRaise(otherTextColor);
  XPParameterRaise(operandColor);
  XPParameterRaise(operatorColor);
  
  // Give everything default appearance
  [input addAttribute:NSFontAttributeName
                value:otherTextFont
                range:NSMakeRange(0, [input length])];
  [input addAttribute:NSForegroundColorAttributeName
                value:otherTextColor
                range:NSMakeRange(0, [input length])];
  
  while (index < [input length]) {
    check = [input attribute:XPAttributedStringKeyForTag(MATHSolverTagNumber)
                     atIndex:index
              effectiveRange:&checkRange];
    if (check) {
      [input addAttribute:NSFontAttributeName
                    value:mathFont
                    range:checkRange];
      [input addAttribute:NSForegroundColorAttributeName
                    value:operandColor
                    range:checkRange];
    } else {
      check = [input attribute:XPAttributedStringKeyForTag(MATHSolverTagBracket)
                       atIndex:index
                effectiveRange:&checkRange];
      if (check) {
        [input addAttribute:NSFontAttributeName
                      value:mathFont
                      range:checkRange];
        [input addAttribute:NSForegroundColorAttributeName
                      value:operatorColor
                      range:checkRange];
      } else {
        check = [input attribute:XPAttributedStringKeyForTag(MATHSolverTagOperator)
                         atIndex:index
                  effectiveRange:&checkRange];
        if (check) {
          [input addAttribute:NSFontAttributeName
                        value:mathFont
                        range:checkRange];
          [input addAttribute:NSForegroundColorAttributeName
                        value:operatorColor
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
