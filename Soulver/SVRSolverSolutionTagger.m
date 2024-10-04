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

+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)string
                                     error:(NSNumber**)errorPtr;
{
  return nil;
}

/*
+(NSDecimalNumber*)__solveMathInExpression:(NSAttributedString*)input;
{
  NSSet *setExponent = [NSSet setWithObject:kSVRSolverOperatorExponent];
  NSSet *setMultDiv  = [NSSet setWithObjects:kSVRSolverOperatorMultiply, kSVRSolverOperatorDivide, nil];
  NSSet *setAddSub   = [NSSet setWithObjects:kSVRSolverOperatorAdd, kSVRSolverOperatorSubtract, nil];
  
  NSRange patchRange = XPNotFoundRange;
  NSValue *bracketRange = nil;
  NSDecimalNumber *output = nil;
  NSAttributedString *patchString = nil;
  NSMutableAttributedString *expression = [[input mutableCopy] autorelease];
  
  // Remove trailing equal sign if needed
  patchRange = NSMakeRange([expression length]-1, 1);
  if ([[[expression string] substringWithRange:NSMakeRange([expression length]-1, 1)] isEqualToString:@"="])
  {
    [expression deleteCharactersInRange:patchRange];
  }
  
  // Find brackets
  while ((bracketRange = [self __solveRangeForNextBracketsInExpression:expression])) {
    patchRange = [bracketRange XP_rangeValue];
    output = [self __solveMathInExpression:[expression attributedSubstringFromRange:NSMakeRange(patchRange.location+1, patchRange.length-2)]];
    if (output) {
      [XPLog extra:@"<()> `%@` %@ → %@", [expression string], [[expression string] substringWithRange:patchRange], output];
      patchString = [self __solveAttributedStringForPatchingWithDecimalNumber:output];
      [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
    } else {
      [XPLog pause:@"<()> `%@` %@ → %@", [expression string], [[expression string] substringWithRange:patchRange], [NSDecimalNumber notANumber]];
    }
    output = nil;
  }
  
  // Solve Exponents
  while ((output = [self __solveNextSubexpressionInExpression:expression
                                            forOperatorsInSet:setExponent
                                         rangeOfSubexpression:&patchRange]))
  {
    [XPLog extra:@"<^^> `%@` %@ → %@", [expression string], [[expression string] substringWithRange:patchRange], output];
    patchString = [self __solveAttributedStringForPatchingWithDecimalNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  // Find Multiplying and Dividing
  while ((output = [self __solveNextSubexpressionInExpression:expression
                                            forOperatorsInSet:setMultDiv
                                         rangeOfSubexpression:&patchRange]))
  {
    [XPLog extra:@"<**> `%@` %@ → %@", [expression string], [[expression string] substringWithRange:patchRange], output];
    patchString = [self __solveAttributedStringForPatchingWithDecimalNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  while ((output = [self __solveNextSubexpressionInExpression:expression
                                            forOperatorsInSet:setAddSub
                                         rangeOfSubexpression:&patchRange]))
  {
    [XPLog extra:@"<+-> `%@` %@ → %@", [expression string], [[expression string] substringWithRange:patchRange], output];
    patchString = [self __solveAttributedStringForPatchingWithDecimalNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (![self __solveValidateOnlyNumeralsInAttributedString:expression]) {
    [XPLog pause:@"__solveMathInExpression: Non-numbers present in: `%@`", [expression string]];
    return nil;
  }
  
  output = [NSDecimalNumber decimalNumberWithString:[expression string]];
  return output;
}
*/

@end

#import "SVRSolverExpressionTagger.h"

@implementation SVRSolverSolutionTagger (Tests)
+(void)executeTests;
{
  [XPLog alwys:@"SVRSolverSolutionTagger Tests: Starting"];
  [SVRSolverSolutionTagger embedSolutionsInString:[SVRSolverExpressionTagger executeTests]];
  [XPLog alwys:@"SVRSolverSolutionTagger Tests: Passed"];
}
@end
