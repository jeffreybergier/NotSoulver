//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverSolutionTagger.h"
#import "SVRCrossPlatform.h"

@implementation SVRSolverSolutionTagger

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;
{
  NSNumber *error = nil;
  NSDecimalNumber *solution = nil;
  NSRange solutionRange = XPNotFoundRange; // range of the equal sign
  
  XPAttributeEnumerator *e = [string SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression)];
  NSValue *nextExpressionValue = nil;
  NSRange nextExpressionRange = XPNotFoundRange;
  
  while ((nextExpressionValue = [e nextObject])) {
    nextExpressionRange = [nextExpressionValue XP_rangeValue];
    solutionRange = NSMakeRange(NSMaxRange(nextExpressionRange), 1);
    if (solution) {
      // For previous solution, add it to the string in case it needs it
      [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution)
                     value:solution
                     range:solutionRange];
    }
    solution = [self __solutionForExpression:[string attributedSubstringFromRange:nextExpressionRange]
                                       error:&error];
    if (solution) {
      [XPLog extra:@"=: %@←%@", [[string string] SVR_descriptionHighlightingRange:solutionRange], solution];
      [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)
                     value:solution
                     range:solutionRange];
    } else {
      [XPLog extra:@"=: %@←%@", [[string string] SVR_descriptionHighlightingRange:solutionRange], error];
      [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)
                     value:error
                     range:solutionRange];
    }
  }
}

// MARK: Private
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)input
                                     error:(NSNumber**)errorPtr;
{
  NSSet *setExponent = [NSSet setWithObject:
                        NSNumberForOperator(SVRSolverOperatorExponent)];
  NSSet *setMultDiv  = [NSSet setWithObjects:
                        NSNumberForOperator(SVRSolverOperatorMultiply),
                        NSNumberForOperator(SVRSolverOperatorDivide),
                        nil];
  NSSet *setAddSub   = [NSSet setWithObjects:
                        NSNumberForOperator(SVRSolverOperatorSubtract),
                        NSNumberForOperator(SVRSolverOperatorAdd),
                        nil];
  
  NSRange patchRange = XPNotFoundRange;
  NSValue *bracketRange = nil;
  NSDecimalNumber *output = nil;
  NSAttributedString *patchString = nil;
  NSMutableAttributedString *expression = [[input mutableCopy] autorelease];
  
  // Find brackets
  while ((bracketRange = [self __rangeOfNextBracketsInExpression:expression
                                                           error:errorPtr]))
  {
    patchRange = [bracketRange XP_rangeValue];
    // Configure patch for subexpression within brackets
    patchRange.location += 1;
    patchRange.length -= 2;
    output = [self __solutionForExpression:[expression attributedSubstringFromRange:patchRange]
                                     error:errorPtr];
    // Revert patch back to subexpression with brackets
    patchRange = [bracketRange XP_rangeValue];
    if (output) {
      [XPLog extra:@"(): %@←%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
      patchString = [self __taggedStringWithNumber:output];
      [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
      output = nil;
    } else {
      [XPLog pause:@"(): %@←%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], [NSDecimalNumber notANumber]];
    }
  }
  
  if (errorPtr != NULL && *errorPtr != nil) {
    return nil;
  }
  
  // Solve Exponents
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setExponent
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    [XPLog extra:@"Op^: %@←%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != nil) {
    return nil;
  }
  
  // Solve MultDiv
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setMultDiv
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    [XPLog extra:@"Op*: %@←%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != nil) {
    return nil;
  }
  
  // Solve AddSub
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setAddSub
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    [XPLog extra:@"Op+: %@←%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != nil) {
    return nil;
  }
  
  output = [NSDecimalNumber decimalNumberWithString:[expression string]];
  if ([output SVR_isNotANumber]) {
    if (errorPtr != NULL) { *errorPtr = [XPError SVR_errorInvalidCharacter]; }
    return nil;
  }
  return output;
}

+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(NSNumber **)errorPtr;
{
  NSRange range = XPNotFoundRange;
  NSValue *lhs = nil;
  NSValue *rhs = nil;
  NSValue *check = nil;
  XPAttributeEnumerator *e = [input SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)];
  while ((check = [e nextObject])) {
    if (!lhs) {
      lhs = check;
    } else if (!rhs) {
      rhs = check;
    }
    if (lhs && rhs) {
      range = NSMakeRange([lhs XP_rangeValue].location, NSMaxRange([rhs XP_rangeValue]) - [lhs XP_rangeValue].location);
      return [NSValue XP_valueWithRange:range];
    }
  }
  if (lhs && errorPtr != NULL) {
    *errorPtr = [XPError SVR_errorMismatchedBrackets];
  }
  return nil;
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
    operator = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                             atIndex:operatorRange.location
                      effectiveRange:&operatorRange];
    if ([operators member:operator]) { break; }
    operatorRange.location = NSMaxRange(operatorRange);
    operatorRange.length = 1;
  }
  
  if (operator == nil || ![operators member:operator]) {
    // Not an error, just no math to do
    // in this string with this operator set
    return nil;
  }
  
  lhsRange = NSMakeRange(operatorRange.location - 1, 1);
  if (lhsRange.location >= 0) {
    lhs = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                        atIndex:lhsRange.location
                 effectiveRange:&lhsRange];
  }
  if (lhs == nil) {
    if (errorPtr != NULL) { *errorPtr = [XPError SVR_errorMissingNumber]; }
    return nil;
  }
  
  rhsRange = NSMakeRange(NSMaxRange(operatorRange), 1);
  if (rhsRange.location + rhsRange.length <= [expression length]) {
    rhs = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                        atIndex:rhsRange.location
                 effectiveRange:&rhsRange];
  }
  if (rhs == nil) {
    if (errorPtr != NULL) { *errorPtr = [XPError SVR_errorMissingNumber]; }
    return nil;
  }
  
  rangePtr->location = lhsRange.location;
  rangePtr->length   = lhsRange.length + operatorRange.length + rhsRange.length;
  
  // TODO: Do the solving
  return [self __solveWithOperator:SVRSolverOperatorForNumber(operator)
                        leftNumber:lhs
                       rightNumber:rhs];
}

+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
{
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:number
                                                         forKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)];
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
+(NSMutableAttributedString*)executeTests;
{
  NSDecimalNumber *output = nil;
  NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"0.10958904109589041095890410958904109589"];
  NSMutableAttributedString *taggedUserInput = [SVRSolverExpressionTagger executeTests];
  [XPLog alwys:@"SVRSolverSolutionTagger Tests: Starting"];
  [SVRSolverSolutionTagger tagSolutionsInAttributedString:taggedUserInput];
  output = [taggedUserInput attribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)
                              atIndex:12
                       effectiveRange:NULL];
  NSAssert([expected isEqualToNumber:output], @"");
  [XPLog alwys:@"SVRSolverSolutionTagger Tests: Passed"];
  return taggedUserInput;
}
@end
