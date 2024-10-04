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

+(void)embedSolutionsInString:(NSMutableAttributedString*)input;
{
  id attribute = nil;
  NSDecimalNumber *solution = nil;
  XPUInteger index = 0;
  NSRange expressionRange = XPNotFoundRange;
  while (index < [input length]) {
    attribute = [input attribute:SVR_stringForTag(SVRSolverTagExpression)
                         atIndex:index
                  effectiveRange:NULL];
    if (![attribute isKindOfClass:[NSValue class]]) { index += 1; continue; }
    expressionRange = [attribute XP_rangeValue];
    solution = [self __solveMathInExpression:[input attributedSubstringFromRange:expressionRange]];
    [input addAttribute:SVR_stringForTag(SVRSolverTagExpressionSolution) value:solution range:expressionRange];
    index = NSMaxRange(expressionRange);
  }
}

+(NSDecimalNumber*)__solveMathInExpression:(NSAttributedString*)input;
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
