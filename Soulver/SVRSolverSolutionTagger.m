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

#import "SVRSolverSolutionTagger.h"
#import "SVRSolverTextAttachment.h"

NSSet *SVRSolverSolutionTaggerSetExponent = nil;
NSSet *SVRSolverSolutionTaggerSetMultDiv  = nil;
NSSet *SVRSolverSolutionTaggerSetAddSub   = nil;

@implementation SVRSolverSolutionTagger

+(void)initialize;
{
  SVRSolverSolutionTaggerSetExponent = [[NSSet alloc] initWithObjects:
                                        NSNumberForOperator(SVRSolverOperatorExponent),
                                        NSNumberForOperator(SVRSolverOperatorRoot),
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
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)output;
{
  SVRSolverError error = SVRSolverErrorNone;
  NSMutableAttributedString *expressionToSolve = nil;
  NSDecimalNumber *solution = nil;
  NSAttributedString *solutionString = nil;
  SVRSolverOperator previousSolutionOperator = SVRSolverOperatorUnknown;
  BOOL didInsertPreviousSolution = NO;
  NSRange solutionRange = XPNotFoundRange; // range of the equal sign
  NSEnumerator *e = nil;
  NSString *next = nil;
  NSRange nextRange = XPNotFoundRange;

  e = [output SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression)
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
          [SVRSolverPreviousSolutionTextAttachment attachmentWithPreviousSolution:solution
                                                                         operator:previousSolutionOperator]
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
          [SVRSolverSolutionTextAttachment attachmentWithSolution:solution]
      ];
    } else {
      solutionString = [
        NSAttributedString attributedStringWithAttachment:
          [SVRSolverErrorTextAttachment attachmentWithError:error]
      ];
    }
    XPLogExtra2(@"=: %@<-%@", [[output string] SVR_descriptionHighlightingRange:solutionRange], solution);
    // Step 6: Insert the text attachment for the solution or error
    [output replaceCharactersInRange:solutionRange
                withAttributedString:solutionString];
    [output addAttribute:XPAttributedStringKeyForTag(SVRSolverTagOriginal)
                   value:@"="
                   range:solutionRange];
    error = SVRSolverErrorNone;
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
      XPLogRaise2(@"__prepareExpression: unknownOperator:%@ foundInExpression:%@", operatorNumber, input);
      return NO;
  }
}

+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)input
                                     error:(SVRSolverErrorPointer)errorPtr;
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
      XPLogExtra2(@"(): %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output);
      patchString = [self __taggedStringWithNumber:output];
      [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
      output = nil;
    } else {
      XPLogExtra1(@"(): %@<-Deleted", [[expression string] SVR_descriptionHighlightingRange:patchRange]);
      [expression deleteCharactersInRange:patchRange];
    }
  }
  
  if (errorPtr != NULL && *errorPtr != SVRSolverErrorNone) {
    return nil;
  }
  
  // Solve Exponents
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setExponent
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    XPLogExtra2(@"Op^: %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output);
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != SVRSolverErrorNone) {
    return nil;
  }
  
  // Solve MultDiv
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setMultDiv
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    XPLogExtra2(@"Op*: %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output);
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != SVRSolverErrorNone) {
    return nil;
  }
  
  // Solve AddSub
  while ((output = [self __nextSolutionInExpression:expression
                                  forOperatorsInSet:setAddSub
                                         patchRange:&patchRange
                                              error:errorPtr]))
  {
    XPLogExtra2(@"Op+: %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output);
    patchString = [self __taggedStringWithNumber:output];
    [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
  }
  
  if (errorPtr != NULL && *errorPtr != SVRSolverErrorNone) {
    return nil;
  }
  
  output = [NSDecimalNumber decimalNumberWithString:[expression string]];
  if ([output SVR_isNotANumber]) {
    if (errorPtr != NULL) { *errorPtr = SVRSolverErrorInvalidCharacter; }
    return nil;
  }
  return output;
}

+(NSValue*)__rangeOfNextBracketsInExpression:(NSAttributedString*)input
                                       error:(SVRSolverErrorPointer)errorPtr;
{
  NSRange range = XPNotFoundRange;
  NSValue *lhs = nil;
  NSValue *rhs = nil;
  XPAttributeEnumerator *e = [input SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)];
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
    *errorPtr = SVRSolverErrorMismatchedBrackets;
  }
  return nil;
}

+(NSDecimalNumber*)__nextSolutionInExpression:(NSAttributedString*)expression
                            forOperatorsInSet:(NSSet*)operators
                                   patchRange:(XPRangePointer)rangePtr
                                        error:(SVRSolverErrorPointer)errorPtr;
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
    if (errorPtr != NULL) { *errorPtr = SVRSolverErrorMissingOperand; }
    return nil;
  }
  
  lhsRange = NSMakeRange(operatorRange.location - 1, 1);
  if (lhsRange.location >= 0) {
    lhs = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                        atIndex:lhsRange.location
                 effectiveRange:&lhsRange];
  }
  if (lhs == nil) {
    if (errorPtr != NULL) { *errorPtr = SVRSolverErrorMissingOperand; }
    return nil;
  }
  
  rhsRange = NSMakeRange(NSMaxRange(operatorRange), 1);
  if (rhsRange.location + rhsRange.length <= [expression length]) {
    rhs = [expression attribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                        atIndex:rhsRange.location
                 effectiveRange:&rhsRange];
  }
  if (rhs == nil) {
    if (errorPtr != NULL) { *errorPtr = SVRSolverErrorMissingOperand; }
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
                                 error:(SVRSolverErrorPointer)errorPtr;
{
  SVRSolverDecimalBehavior *ohBehave = [SVRSolverDecimalBehavior behaviorWithErrorPtr:errorPtr];
  switch (operator) {
    case SVRSolverOperatorExponent:
      return [lhs SVR_decimalNumberByRaisingToPower:rhs withBehavior:ohBehave];
    case SVRSolverOperatorDivide:
      return [lhs decimalNumberByDividingBy:rhs withBehavior:ohBehave];
    case SVRSolverOperatorMultiply:
      return [lhs decimalNumberByMultiplyingBy:rhs withBehavior:ohBehave];
    case SVRSolverOperatorSubtract:
      return [lhs decimalNumberBySubtracting:rhs withBehavior:ohBehave];
    case SVRSolverOperatorAdd:
      return [lhs decimalNumberByAdding:rhs withBehavior:ohBehave];
    case SVRSolverOperatorRoot:
      return [rhs SVR_decimalNumberByRootingByIndex:lhs];
    default:
      XPLogRaise1(@"__solveWithOperatorUnknown:%d", operator);
      return nil;
  }
}

@end

@implementation SVRSolverDecimalBehavior

-(id)initWithErrorPtr:(SVRSolverErrorPointer)errorPtr;
{
  self = [super init];
  _errorPtr = errorPtr;
  return self;
}

+(id)behaviorWithErrorPtr:(SVRSolverErrorPointer)errorPtr;
{
  return [[[SVRSolverDecimalBehavior alloc] initWithErrorPtr:errorPtr] autorelease];
}

-(NSRoundingMode)roundingMode;
{
  return NSRoundPlain;
}

-(short)scale;
{
  return 5;
}

-(NSDecimalNumber*)exceptionDuringOperation:(SEL)operation
                                      error:(NSCalculationError)error
                                leftOperand:(NSDecimalNumber*)leftOperand
                               rightOperand:(NSDecimalNumber*)rightOperand;
{
  switch (error) {
    case NSCalculationNoError: return nil;
    case NSCalculationLossOfPrecision:
      XPLogDebug3(@"exceptionDuringOperation:%@ error:NSCalculationLossOfPrecision leftOperand:%@ rightOperand:%@",
                  NSStringFromSelector(operation), leftOperand, rightOperand);
      return nil;
    case NSCalculationUnderflow:
      XPLogDebug3(@"exceptionDuringOperation:%@ error:NSCalculationUnderflow leftOperand:%@ rightOperand:%@",
                  NSStringFromSelector(operation), leftOperand, rightOperand);
      return nil;
    case NSCalculationOverflow:
      XPLogDebug3(@"exceptionDuringOperation:%@ error:NSCalculationOverflow leftOperand:%@ rightOperand:%@",
                  NSStringFromSelector(operation), leftOperand, rightOperand);
      return nil;
    case NSCalculationDivideByZero:
      XPLogDebug3(@"exceptionDuringOperation:%@ error:NSCalculationDivideByZero leftOperand:%@ rightOperand:%@",
                  NSStringFromSelector(operation), leftOperand, rightOperand);
      if (_errorPtr != NULL) { *_errorPtr = SVRSolverErrorDivideByZero; }
      return [NSDecimalNumber notANumber];
  }
  return nil;
}

-(void)dealloc;
{
  XPLogExtra1(@"DEALLOC: %@", self);
  _errorPtr = NULL;
  [super dealloc];
}
@end
