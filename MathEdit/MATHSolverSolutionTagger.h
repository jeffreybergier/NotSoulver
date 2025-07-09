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
#import "MATHSolver.h"
#import "XPCrossPlatform.h"

@interface MATHSolverSolutionTagger: NSObject

// MARK: Configure constants
+(void)initialize;

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string
                       solutionStyles:(MATHSolverTextAttachmentStyles)solutionStyles
               previousSolutionStyles:(MATHSolverTextAttachmentStyles)previousSolutionStyles
                          errorStyles:(MATHSolverTextAttachmentStyles)errorStyles;


// MARK: Private
+(BOOL)__prepareExpression:(NSMutableAttributedString*)input
      withPreviousSolution:(NSDecimalNumber*)previousSolution
           operatorPointer:(MATHSolverOperator*)operatorPointer;
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(MATHCalculationErrorPointer)errorPtr;
+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(MATHCalculationErrorPointer)errorPtr;
+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(XPRangePointer)rangePtr
                                        error:(MATHCalculationErrorPointer)errorPtr;
+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
+(NSDecimalNumber*)__solveWithOperator:(MATHSolverOperator)operator
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs
                                 error:(MATHCalculationErrorPointer)errorPtr;

@end
