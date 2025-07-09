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

#import "MATHSolverSolutionTagger.h"
#import "MATHSolverTextAttachment.h"

NSSet *SVRSolverSolutionTaggerSetExponent = nil;
NSSet *SVRSolverSolutionTaggerSetMultDiv  = nil;
NSSet *SVRSolverSolutionTaggerSetAddSub   = nil;

@implementation SVRSolverSolutionTagger

+(void)initialize;
{
  SVRSolverSolutionTaggerSetExponent = [[NSSet alloc] initWithObjects:
                                        NSNumberForOperator(SVRSolverOperatorExponent),
                                        NSNumberForOperator(SVRSolverOperatorRoot),
                                        NSNumberForOperator(SVRSolverOperatorLog),
                                        nil];
  SVRSolverSolutionTaggerSetMultDiv  = [[NSSet alloc] initWithObjects:
                                        NSNumberForOperator(SVRSolverOperatorMultiply),
                                        NSNumberForOperator(SVRSolverOperatorDivide),
                                        nil];
  SVRSolverSolutionTaggerSetAddSub   = [[NSSet alloc] initWithObjects:
                                        NSNumberForOperator(SVRSolverOperatorSubtract),
                                        NSNumberForOperator(SVRSolverOperatorAdd),
                                        nil];
}

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)output
                       solutionStyles:(SVRSolverTextAttachmentStyles)solutionStyles
               previousSolutionStyles:(SVRSolverTextAttachmentStyles)previousSolutionStyles
                          errorStyles:(SVRSolverTextAttachmentStyles)errorStyles;
{
  SVRCalculationError error = SVRCalculationNoError;
  NSMutableAttributedString *expressionToSolve = nil;
  NSDecimalNumber *solution = nil;
  NSAttributedString *solutionString = nil;
  SVRSolverOperator previousSolutionOperator = SVRSolverOperatorUnknown;
  BOOL didInsertPreviousSolution = NO;
  NSRange solutionRange = XPNotFoundRange; // range of the equal sign
  NSEnumerator *e = nil;
  NSString *next = nil;
  NSRange nextRange = XPNotFoundRange;

  e = [output MATH_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression)
               usingLongestEffectiveRange:YES];
  while ((next = [e nextObject])) {
    nextRange = NSRangeFromString(next);
    solutionRange = NSMakeRange(NSMaxRange(nextRange), 1);
    expressionToSolve = [[[output attributedSubstringFromRange:nextRange] mutableCopy] autorelease];
    // Step 1: Prepare the expression string with previous solution if needed
    didInsertPreviousSolution = [self __prepareExpression:expressionToSolve
                                     withPreviousSolution:solution
                                          operatorPointer:&previousSolutionOperator];
    if (didInsertPreviousSolution) {
      // Step 2: If the previous solution is used, create a text attachment
      solutionString = [
        NSAttributedString attributedStringWithAttachment:
          [SVRSolverTextAttachment attachmentWithPreviousSolution:solution
                                                         operator:previousSolutionOperator
                                                           styles:previousSolutionStyles]
      ];
      // Step 3: Insert the previous solution text attachment
      [output replaceCharactersInRange:NSMakeRange(nextRange.location, 1)
                  withAttributedString:solutionString];
      [output addAttribute:XPAttributedStringKeyForTag(SVRSolverTagOriginal)
                     value:RawStringForOperator(previousSolutionOperator)
                     range:NSMakeRange(nextRange.location, 1)];
    }
    // Step 4: Solve the exoression string.
    solution = [self __solutionForExpression:expressionToSolve error:&error];
    // Step 5: Create the text attachment for solution or error
    if (solution) {
      solutionString = [
        NSAttributedString attributedStringWithAttachment:
          [SVRSolverTextAttachment attachmentWithSolution:solution
                                                   styles:solutionStyles]
      ];
    } else {
      solutionString = [
        NSAttributedString attributedStringWithAttachment:
          [SVRSolverTextAttachment attachmentWithError:error
                                                styles:errorStyles]
      ];
    }
    XPLogExtra2(@"%@<-%@", [[output string] MATH_descriptionHighlightingRange:solutionRange], solution);
    // Step 6: Insert the text attachment for the solution or error
    [output replaceCharactersInRange:solutionRange
                withAttributedString:solutionString];
    [output addAttribute:XPAttributedStringKeyForTag(SVRSolverTagOriginal)
                   value:@"="
                   range:solutionRange];
    error = SVRCalculationNoError;
  }
}

// MARK: Private

+(BOOL)__prepareExpression:(NSMutableAttributedString*)input
      withPreviousSolution:(NSDecimalNumber*)previousSolution
           operatorPointer:(SVRSolverOperator*)operatorPointer;
{
  NSNumber *operatorNumber = nil;
  SVRSolverOperator operator = SVRSolverOperatorUnknown;
  NSAttributedString *toInsert = nil;
  NSDictionary *attribs = nil;
  
  // Remove the expression attribute as we already used that
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression)
                   range:NSMakeRange(0, [input length])];
  
  // Do basic sanity checks
  if (!previousSolution) { return NO; }
  if ([input length] == 0) { return NO; }
  if (operatorPointer == NULL) { return NO; }
  
  // Find the operator
  operatorNumber = [input attribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                         atIndex:0
                  effectiveRange:NULL];
  if (operatorNumber == nil) { return NO; }
  operator = SVRSolverOperatorForNumber(operatorNumber);
  switch (operator) {
    case SVRSolverOperatorExponent:
    case SVRSolverOperatorDivide:
    case SVRSolverOperatorMultiply:
    case SVRSolverOperatorAdd:
    case SVRSolverOperatorRoot:
    case SVRSolverOperatorLog:
      // Insert the previous solution
      attribs = [NSDictionary dictionaryWithObject:previousSolution
                                            forKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)];
      toInsert = [[[NSAttributedString alloc] initWithString:[previousSolution description]
                                                  attributes:attribs] autorelease];
      [input insertAttributedString:toInsert atIndex:0];
      *operatorPointer = operator;
      return YES;
    case SVRSolverOperatorSubtract:
      // We can't distinguish between operator and negative number in this case.
      // Just remove the operator key so its treated as a negative number.
      [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                       range:NSMakeRange(0, 1)];
      return NO;
    default:
      XPLogAssrt2(NO, @"unknownOperator:%@ foundInExpression:%@", operatorNumber, input);
      return NO;
  }
}

+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)input
                                     error:(SVRCalculationErrorPointer)errorPtr;
{
  NSSet *setExponent = SVRSolverSolutionTaggerSetExponent;
  NSSet *setMultDiv  = SVRSolverSolutionTaggerSetMultDiv;
  NSSet *setAddSub   = SVRSolverSolutionTaggerSetAddSub;
  
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
      XPLogExtra2(@"(): %@<-%@", [[expression string] MATH_descriptionHighlightingRange:patchRange], output);
      patchString = [self __taggedStringWithNumber:output];
      [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
      output = nil;
    } else {
      XPLogExtra1(@"(): %@<-Deleted", [[expression string] MATH_descriptionHighlightingRange:patchRange]);
      [expression deleteCharactersInRange:patchRange];
    }
  }
  
  if (errorPtr != NULL && *errorPtr != SVRCalculationNoError) {
    return nil;
  }
  
  // Solve Exponents
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setExponent
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    XPLogExtra2(@"Op^: %@<-%@", [[expression string] MATH_descriptionHighlightingRange:patchRange], output);
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != SVRCalculationNoError) {
    return nil;
  }
  
  // Solve MultDiv
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setMultDiv
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    XPLogExtra2(@"Op*: %@<-%@", [[expression string] MATH_descriptionHighlightingRange:patchRange], output);
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != SVRCalculationNoError) {
    return nil;
  }
  
  // Solve AddSub
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setAddSub
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    XPLogExtra2(@"Op+: %@<-%@", [[expression string] MATH_descriptionHighlightingRange:patchRange], output);
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != SVRCalculationNoError) {
    return nil;
  }
  
  output = [NSDecimalNumber decimalNumberWithString:[expression string]];
  if ([output MATH_isNotANumber]) {
    if (errorPtr != NULL) { *errorPtr = SVRCalculationInvalidCharacter; }
    return nil;
  }
  return output;
}

+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(SVRCalculationErrorPointer)errorPtr;
{
  NSRange range = XPNotFoundRange;
  NSValue *lhs = nil;
  NSValue *rhs = nil;
  XPAttributeEnumerator *e = [input MATH_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)];
  while ([e nextObjectEffectiveRange:&range]) {
    if (!lhs) {
      lhs = [NSValue XP_valueWithRange:range];
    } else if (!rhs) {
      rhs = [NSValue XP_valueWithRange:range];
    }
    if (lhs && rhs) {
      range = NSMakeRange([lhs XP_rangeValue].location,
                          NSMaxRange([rhs XP_rangeValue]) - [lhs XP_rangeValue].location);
      return [NSValue XP_valueWithRange:range];
    }
  }
  if (lhs && errorPtr != NULL) {
    *errorPtr = SVRCalculationMismatchedBrackets;
  }
  return nil;
}

+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(XPRangePointer)rangePtr
                                        error:(SVRCalculationErrorPointer)errorPtr;
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

  if (operatorRange.location == 0) {
    if (errorPtr != NULL) { *errorPtr = SVRCalculationMissingOperand; }
    return nil;
  }
  
  lhsRange = NSMakeRange(operatorRange.location - 1, 1);
  lhs = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                      atIndex:lhsRange.location
               effectiveRange:&lhsRange];
  if (lhs == nil) {
    if (errorPtr != NULL) { *errorPtr = SVRCalculationMissingOperand; }
    return nil;
  }
  
  rhsRange = NSMakeRange(NSMaxRange(operatorRange), 1);
  if (rhsRange.location + rhsRange.length <= [expression length]) {
    rhs = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                        atIndex:rhsRange.location
                 effectiveRange:&rhsRange];
  }
  if (rhs == nil) {
    if (errorPtr != NULL) { *errorPtr = SVRCalculationMissingOperand; }
    return nil;
  }
  
  rangePtr->location = lhsRange.location;
  rangePtr->length   = lhsRange.length + operatorRange.length + rhsRange.length;
  
  return [self __solveWithOperator:SVRSolverOperatorForNumber(operator)
                        leftNumber:lhs
                       rightNumber:rhs
                             error:errorPtr];
}

+(NSAttributedString*)__taggedStringWithNumber:(NSDecimalNumber*)number;
{
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:number
                                                         forKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)];
  return [[[NSAttributedString alloc] initWithString:[number description]
                                          attributes:attributes] autorelease];
}

+(NSDecimalNumber*)__solveWithOperator:(SVRSolverOperator)operator
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs
                                 error:(SVRCalculationErrorPointer)errorPtr;
{
  SVRSolverDecimalBehavior *ohBehave = [SVRSolverDecimalBehavior behaviorWithErrorPtr:errorPtr];
  switch (operator) {
    case SVRSolverOperatorExponent:
      return [lhs MATH_decimalNumberByRaisingWithExponent:rhs withBehavior:ohBehave];
    case SVRSolverOperatorDivide:
      return [lhs decimalNumberByDividingBy:rhs withBehavior:ohBehave];
    case SVRSolverOperatorMultiply:
      return [lhs decimalNumberByMultiplyingBy:rhs withBehavior:ohBehave];
    case SVRSolverOperatorSubtract:
      return [lhs decimalNumberBySubtracting:rhs withBehavior:ohBehave];
    case SVRSolverOperatorAdd:
      return [lhs decimalNumberByAdding:rhs withBehavior:ohBehave];
    case SVRSolverOperatorRoot:
      return [rhs MATH_decimalNumberByRootingWithExponent:lhs withBehavior:ohBehave];
    case SVRSolverOperatorLog:
      return [rhs MATH_decimalNumberByLogarithmWithBase:lhs withBehavior:ohBehave];
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRSolverOperator(%d)", (int)operator);
      return nil;
  }
}

@end
