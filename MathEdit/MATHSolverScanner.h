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
#import "XPRegularExpression.h"

@interface MATHSolverScanner: NSObject
{
  mm_copy NSString *_string;
  mm_new  NSSet    *_numbers;
  mm_new  NSSet    *_operators;
  mm_new  NSSet    *_expressions;
  mm_new  NSSet    *_brackets;
}

// MARK: Load
+(void)initialize;

// MARK: Initialization
-(id)initWithString:(NSString*)string;
+(id)scannerWithString:(NSString*)string;

// MARK: Access the ranges
-(NSSet*)expressionRanges;
-(NSSet*)numberRanges;
-(NSSet*)operatorRanges;
-(NSSet*)bracketRanges;

// MARK: Convenience Properties
-(NSString*)string;
-(NSString*)description;

// MARK: Private
-(void)__populateExpressions;
-(void)__populateNumbers;
-(void)__populateOperators;
-(void)__populateBrackets;

@end

@interface XPRegularExpression (MathEdit)

+(id)MATH_regexForNumbers;
+(id)MATH_regexForOperators;
+(id)MATH_regexForExpressions;
+(id)MATH_regexForBrackets;

@end
