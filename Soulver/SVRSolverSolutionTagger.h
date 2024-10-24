//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "SVRSolver.h"
#import "XPCrossPlatform.h"

@interface SVRSolverSolutionTagger: NSObject

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;

// MARK: Private
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(SVRSolverErrorPointer)errorPtr;
+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(SVRSolverErrorPointer)errorPtr;
+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(XPRangePointer)rangePtr
                                        error:(SVRSolverErrorPointer)errorPtr;
+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
+(NSDecimalNumber*)__solveWithOperator:(SVRSolverOperator)operator
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs
                                 error:(SVRSolverErrorPointer)errorPtr;

@end

@interface SVRSolverDecimalBehavior: NSObject <NSDecimalNumberBehaviors>
{
  SVRSolverErrorPointer _errorPtr;
}
-(id)initWithErrorPtr:(SVRSolverErrorPointer)errorPtr;
+(id)behaviorWithErrorPtr:(SVRSolverErrorPointer)errorPtr;
-(NSRoundingMode)roundingMode;
-(short)scale;
-(NSDecimalNumber*)exceptionDuringOperation:(SEL)operation
                                      error:(NSCalculationError)error
                                leftOperand:(NSDecimalNumber*)leftOperand
                               rightOperand:(NSDecimalNumber*)rightOperand;
@end
