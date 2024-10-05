//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverSolutionTagger.h"
#import "SVRCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRSolverSolutionTagger

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;
{
  id attribute = nil;
  XPUInteger index = 0;
  NSRange expressionRange = XPNotFoundRange;
  NSDecimalNumber *solution = nil;
  
  // Find expressions
  while (index < [string length]) {
    attribute = [string attribute:SVR_stringForTag(SVRSolverTagExpression)
                          atIndex:index
                   effectiveRange:NULL];
    if (!attribute) { index += 1; continue; }
    expressionRange = [attribute XP_rangeValue];
    if (solution) {
      // For previous solution, add it to the string in case it needs it
      [string addAttribute:SVR_stringForTag(SVRSolverTagPreviousSolution)
                     value:solution
                     range:expressionRange];
    }
    solution = [self __solutionForExpression:[string attributedSubstringFromRange:expressionRange]
                                       error:NULL];
    if (solution) {
      [string addAttribute:SVR_stringForTag(SVRSolverTagExpressionSolution)
                     value:solution
                     range:expressionRange];
    } else {
      // Store error in SVRSolverTagExpressionSolution
    }
    index = NSMaxRange(expressionRange);
  }
}

// MARK: Private
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)input
                                     error:(NSNumber**)errorPtr;
{
  NSSet *setExponent = [NSSet setWithObject:
                        SVR_numberForOperator(SVRSolverOperatorExponent)];
  NSSet *setMultDiv  = [NSSet setWithObjects:
                        SVR_numberForOperator(SVRSolverOperatorMultiply),
                        SVR_numberForOperator(SVRSolverOperatorDivide),
                        nil];
  NSSet *setAddSub   = [NSSet setWithObjects:
                        SVR_numberForOperator(SVRSolverOperatorSubtract),
                        SVR_numberForOperator(SVRSolverOperatorAdd),
                        nil];
  
  NSRange patchRange = XPNotFoundRange;
  NSValue *bracketRange = nil;
  NSDecimalNumber *output = nil;
  NSAttributedString *patchString = nil;
  NSMutableAttributedString *expression = [[input mutableCopy] autorelease];
  
  // Find brackets later
  
  // Solve Exponents
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setExponent
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    [XPLog extra:@"Op^: %@ ← %@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  // Solve MultDiv
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setMultDiv
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    [XPLog extra:@"Op*: %@ ← %@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  // Solve AddSub
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setAddSub
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    [XPLog extra:@"Op+: %@ ← %@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  output = [NSDecimalNumber decimalNumberWithString:[expression string]];
  if ([output SVR_isNotANumber]) {
    // TODO: Populate errorPtr
    return nil;
  }
  return output;
}

+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(NSRange*)rangePtr
                                        error:(NSNumber**)errorPtr;
{
  NSRange operatorRange = NSMakeRange(0, 1);
  NSRange lhsRange = XPNotFoundRange;
  NSRange rhsRange = XPNotFoundRange;
  NSNumber *operator = nil;
  NSDecimalNumber *lhs = nil;
  NSDecimalNumber *rhs = nil;
  
  // Find the first matching operator
  while (NSMaxRange(operatorRange) < [expression length]) {
    operator = [expression attribute:SVR_stringForTag(SVRSolverTagOperator)
                             atIndex:operatorRange.location
                      effectiveRange:&operatorRange];
    if ([operators member:operator]) { break; }
    operatorRange.location = NSMaxRange(operatorRange);
    operatorRange.length = 1;
  }
  if (![operators member:operator]) {
    return nil;
  }
  
  lhsRange = NSMakeRange(operatorRange.location - 1, 1);
  if (lhsRange.location >= 0) {
    lhs = [expression attribute:SVR_stringForTag(SVRSolverTagNumber)
                        atIndex:lhsRange.location
                 effectiveRange:&lhsRange];
  }
  if (lhs == nil) {
    // TODO: Populate ErrorPtr
    return nil;
  }
  
  rhsRange = NSMakeRange(NSMaxRange(operatorRange), 1);
  if (rhsRange.location + rhsRange.length <= [expression length]) {
    rhs = [expression attribute:SVR_stringForTag(SVRSolverTagNumber)
                        atIndex:rhsRange.location
                 effectiveRange:&rhsRange];
  }
  if (rhs == nil) {
    // TODO: Populate ErrorPtr
    return nil;
  }
  
  rangePtr->location = lhsRange.location;
  rangePtr->length   = lhsRange.length + operatorRange.length + rhsRange.length;
  
  // TODO: Do the solving
  return [self __solveWithOperator:SVR_operatorForNumber(operator)
                        leftNumber:lhs
                       rightNumber:rhs];
}

+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
{
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:number
                                                         forKey:SVR_stringForTag(SVRSolverTagNumber)];
  return [[[NSAttributedString alloc] initWithString:[number SVR_description]
                                          attributes:attributes] autorelease];
}

+(NSDecimalNumber*)__solveWithOperator:(SVRSolverOperator)operator
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs;
{
  switch (operator) {
    case SVRSolverOperatorExponent:
      return [lhs SVR_decimalNumberByRaisingToPower:rhs];
    case SVRSolverOperatorDivide:
      return [lhs decimalNumberByDividingBy:rhs];
    case SVRSolverOperatorMultiply:
      return [lhs decimalNumberByMultiplyingBy:rhs];
    case SVRSolverOperatorSubtract:
      return [lhs decimalNumberBySubtracting:rhs];
    case SVRSolverOperatorAdd:
      return [lhs decimalNumberByAdding:rhs];
    default:
      [XPLog error:@"__solveWithOperatorUnknown"];
      return nil;
  }
}

@end

#import "SVRSolverExpressionTagger.h"

@implementation SVRSolverSolutionTagger (Tests)
+(void)executeTests;
{
  [XPLog alwys:@"SVRSolverSolutionTagger Tests: Starting"];
  [SVRSolverSolutionTagger tagSolutionsInAttributedString:[SVRSolverExpressionTagger executeTests]];
  [XPLog alwys:@"SVRSolverSolutionTagger Tests: Passed"];
}
@end
