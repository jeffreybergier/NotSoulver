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

#import <Foundation/Foundation.h>

@interface SVRSolverExpressionTagger: NSObject

+(void)step1_tagOperatorsAtRanges:(NSSet*)ranges
               inAttributedString:(NSMutableAttributedString*)string;
// TODO: Improve Regex so that this does not have to manually
// remove the - operator which can conflict with negative numbers
+(void)step2_tagNumbersAtRanges:(NSSet*)ranges
             inAttributedString:(NSMutableAttributedString*)string;
+(void)step3_tagBracketsAtRanges:(NSSet*)ranges
              inAttributedString:(NSMutableAttributedString*)string;
+(void)step4_tagExpressionsAtRanges:(NSSet*)ranges
                 inAttributedString:(NSMutableAttributedString*)string;

@end
