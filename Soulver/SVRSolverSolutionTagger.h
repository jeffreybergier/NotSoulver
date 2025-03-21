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

#import <Foundation/Foundation.h>
#import "SVRSolver.h"
#import "XPCrossPlatform.h"

@interface SVRSolverSolutionTagger: NSObject

// MARK: Configure constants
+(void)initialize;

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string
                       solutionStyles:(SVRSolverTextAttachmentStyles)solutionStyles
               previousSolutionStyles:(SVRSolverTextAttachmentStyles)previousSolutionStyles
                          errorStyles:(SVRSolverTextAttachmentStyles)errorStyles;


// MARK: Private
+(BOOL)__prepareExpression:(NSMutableAttributedString*)input
      withPreviousSolution:(NSDecimalNumber*)previousSolution
           operatorPointer:(SVRSolverOperator*)operatorPointer;
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(SVRCalculationErrorPointer)errorPtr;
+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(SVRCalculationErrorPointer)errorPtr;
+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(XPRangePointer)rangePtr
                                        error:(SVRCalculationErrorPointer)errorPtr;
+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
+(NSDecimalNumber*)__solveWithOperator:(SVRSolverOperator)operator
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs
                                 error:(SVRCalculationErrorPointer)errorPtr;

@end
