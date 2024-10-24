//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverSolutionTagger.h"
#import "SVRSolverTextAttachment.h"

@implementation SVRSolverSolutionTagger

// MARK: Business Logic
+(void)tagSolutionsInAttributedString:(NSMutableAttributedString*)string;
{
  SVRSolverError error = SVRSolverErrorNone;
  NSDecimalNumber *solution = nil;
  NSAttributedString *solutionString = nil;
  NSRange solutionRange = XPNotFoundRange; // range of the equal sign
  NSEnumerator *e = nil;
  NSString *next = nil;
  NSRange nextRange = XPNotFoundRange;

  e = [string SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression)
              usingLongestEffectiveRange:YES];
  while ((next = [e nextObject])) {
    nextRange = NSRangeFromString(next);
    solutionRange = NSMakeRange(NSMaxRange(nextRange), 1);
    if (solution) {
      // For previous solution, add it to the string in case it needs it
      [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution)
                     value:solution
                     range:solutionRange];
    }
    solution = [self __solutionForExpression:[string attributedSubstringFromRange:nextRange]
                                       error:&error];
    solutionString = [
      NSAttributedString attributedStringWithAttachment:
        [SVRSolverTextAttachment attachmentWithSolution:solution error:error]
    ];
    [XPLog extra:@"=: %@<-%@",
     [[string string] SVR_descriptionHighlightingRange:solutionRange], solution];
    [string replaceCharactersInRange:solutionRange
                withAttributedString:solutionString];
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)
                   value:(solution) ? (NSNumber*)solution : [NSNumber numberWithInt:error]
                   range:solutionRange];
    error = SVRSolverErrorNone;
  }
}

// MARK: Private
+(NSDecimalNumber*)__solutionForExpression:(NSAttributedString*)input
                                     error:(SVRSolverErrorPointer)errorPtr;
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
      [XPLog extra:@"(): %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
      patchString = [self __taggedStringWithNumber:output];
      [expression replaceCharactersInRange:patchRange withAttributedString:patchString];
      output = nil;
    } else {
      [XPLog pause:@"(): %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], [NSDecimalNumber notANumber]];
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
    [XPLog extra:@"Op^: %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
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
    [XPLog extra:@"Op*: %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
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
    [XPLog extra:@"Op+: %@<-%@", [[expression string] SVR_descriptionHighlightingRange:patchRange], output];
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
  
  // TODO: Do the solving
  return [self __solveWithOperator:SVRSolverOperatorForNumber(operator)
                        leftNumber:lhs
                       rightNumber:rhs
                             error:errorPtr];
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
      [XPLog debug:@"exceptionDuringOperation: NSCalculationLossOfPrecision"];
      return nil;
    case NSCalculationUnderflow:
      [XPLog debug:@"exceptionDuringOperation: NSCalculationUnderflow"];
      return nil;
    case NSCalculationOverflow:
      [XPLog debug:@"exceptionDuringOperation: NSCalculationOverflow"];
      return nil;
    case NSCalculationDivideByZero:
      if (_errorPtr != NULL) { *_errorPtr = SVRSolverErrorDivideByZero; }
      [XPLog debug:@"NSCalculationDivideByZero"];
      return [NSDecimalNumber notANumber];
  }
  return nil;
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  _errorPtr = NULL;
  [super dealloc];
}
@end
