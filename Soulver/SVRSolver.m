//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRSolver.h"
#import "JSBRegex.h"

NSString *kSVRSolverSolutionKey   = @"kSVRSolverSolutionKey"; // Store NSDecimalNumber or NSNumber for Error
NSString *kSVRSolverBracketsKey   = @"kSVRSolverBracketsKey";
NSString *kSVRSolverOperatorKey   = @"kSVRSolverOperatorKey";
NSString *kSVRSolverNumeralKey    = @"kSVRSolverNumeralKey"; // TODO: Delete
NSString *kSVRSolverNumberKey     = @"kSVRSolverNumberKey"; // Stores NSDecimalNumber
NSString *kSVRSolverOtherKey      = @"kSVRSolverOtherKey";

NSString *kSVRSolverOperatorExponent    = @"kSVRSolverOperator^";
NSString *kSVRSolverOperatorMultiply    = @"kSVRSolverOperator*";
NSString *kSVRSolverOperatorDivide      = @"kSVRSolverOperator/";
NSString *kSVRSolverOperatorAdd         = @"kSVRSolverOperator+";
NSString *kSVRSolverOperatorSubtract    = @"kSVRSolverOperator-";
NSString *kSVRSolverYES                 = @"kSVRSolverYES";

static NSString *kSVRSolverOperator(NSString* operator) {
  return [@"kSVRSolverOperator" stringByAppendingString:operator];
}

@implementation SVRSolver: NSObject

// MARK: Business Logic
+(void)annotateStorage:(NSMutableAttributedString*)output;
{
  NSRange range;
  [output retain];
  
  // Clear existing annotations except solution keys
  range = NSMakeRange(0, [output length]);
  [output removeAttribute:kSVRSolverBracketsKey range:range];
  [output removeAttribute:kSVRSolverOperatorKey range:range];
  [output removeAttribute:kSVRSolverNumberKey range:range];
  [output removeAttribute:kSVRSolverOtherKey range:range];
  
  // Restart annotation process
  [self __annotateNumerals:output];
  [self __annotateBrackets:output];
  [self __annotateOperators:output];
  
  [output autorelease];
}

+(void)solveAnnotatedStorage:(NSMutableAttributedString*)output;
{
  [output retain];
  [self __solveExpressions:output];
  [output autorelease];
}

+(void)colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)output;
{
  NSRange range;
  [output retain];
  
  // Remove all font, foreground, and backgorund color attributes
  range = NSMakeRange(0, [output length]);
  [output removeAttribute:NSFontAttributeName range:range];
  [output removeAttribute:NSForegroundColorAttributeName range:range];
  [output removeAttribute:NSBackgroundColorAttributeName range:range];
  
  // Reapply coloring
  [self __colorAnnotatedAndSolvedStorage:output];
  
  [output autorelease];
}

// MARK: Private: solveTextStorage

+(void)__annotateBrackets:(NSMutableAttributedString*)output;
{
  NSRange range;
  NSValue *value;
  // Check for opening brackets
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"\\([\\-\\d]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.length = 1;
    [output addAttribute:kSVRSolverBracketsKey value:kSVRSolverYES range:range];
  }
  
  // Check for closing brackets
  regex = [JSBRegex regexWithString:[output string]
                            pattern:@"\\d\\)[\\^\\*\\/\\+\\-\\=]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.location += 1;
    range.length = 1;
    [output addAttribute:kSVRSolverBracketsKey value:kSVRSolverYES range:range];
  }
}

+(void)__annotateOperators:(NSMutableAttributedString*)output;
{
  NSRange range;
  NSValue *value;
  NSString *operator;
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\)][\\*\\-\\+\\/\\^][\\-\\d\\(]"
                               forceIteration:YES];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.location += 1;
    range.length = 1;
    operator = [[output string] substringWithRange:range];
    [XPLog extra:@"<+-*/> '%@' '%@'→'%@'", [output string], operator, [[output string] substringWithRange:range]];
    [output addAttribute:kSVRSolverOperatorKey
                   value:kSVRSolverOperator(operator)
                   range:range];
  }
}

// TODO: Refactor all regex in this file to XPRegex
// Its getting really messy and can be optimized on its own in later OS versions
+(void)__annotateNumerals:(NSMutableAttributedString*)output;
{
  NSRange range = XPNotFoundRange;
  NSValue *rangeV = nil;
  NSDecimalNumber *number = nil;
  JSBRegex *regex = nil;
  JSBRegex *n_regex = nil; // for testing negative numbers to make sure they are preceded by an operator

  // Annotate positive integers
  regex = [JSBRegex regexWithString:[output string] pattern:@"\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    number = [NSDecimalNumber decimalNumberWithString:[[output string] substringWithRange:range]];
    [XPLog extra:@"<#> '%@' '%@'→'%@'", [output string], [number SVR_description], [[output string] substringWithRange:range]];
    [output addAttribute:kSVRSolverNumberKey value:number range:range];
  }
  
  // Annotate positive floats
  regex = [JSBRegex regexWithString:[output string] pattern:@"\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    number = [NSDecimalNumber decimalNumberWithString:[[output string] substringWithRange:range]];
    [XPLog extra:@"<#> '%@' '%@'→'%@'", [output string], [number SVR_description], [[output string] substringWithRange:range]];
    [output addAttribute:kSVRSolverNumberKey value:number range:range];
  }
  
  // Annotate negative integers
  regex = [JSBRegex regexWithString:[output string] pattern:@"\\-\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    n_regex = [JSBRegex regexWithString:[[output string] substringWithRange:NSMakeRange(range.location-1, 1)]
                                pattern:@"[\\(\\+\\-\\*\\/\\^]"];
    if ([n_regex nextObject]) {
      number = [NSDecimalNumber decimalNumberWithString:[[output string] substringWithRange:range]];
      [XPLog extra:@"<#> '%@' '%@'→'%@'", [output string], [number SVR_description], [[output string] substringWithRange:range]];
      [output addAttribute:kSVRSolverNumberKey value:number range:range];
    }
  }
  
  // Annotate negative floats
  regex = [JSBRegex regexWithString:[output string] pattern:@"\\-\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    n_regex = [JSBRegex regexWithString:[[output string] substringWithRange:NSMakeRange(range.location-1, 1)]
                                pattern:@"[\\(\\+\\-\\*\\/\\^]"];
    if ([n_regex nextObject]) {
      number = [NSDecimalNumber decimalNumberWithString:[[output string] substringWithRange:range]];
      [XPLog extra:@"<#> '%@' '%@'→'%@'", [output string], [number SVR_description], [[output string] substringWithRange:range]];
      [output addAttribute:kSVRSolverNumberKey value:number range:range];
    }
  }
}

// MARK: Private: solveAnnotatedStorage

// TODO: Find a way to show the answer without modifying the string... NSLayoutManager?
+(void)__solveExpressions:(NSMutableAttributedString*)output;
{
  NSValue *value = nil;
  NSRange range = XPNotFoundRange;
  NSRange rangeOfEqualSign = XPNotFoundRange;
  NSDecimalNumber *solution = nil;
  
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    if (![self __solveIsSolvedExpressionInStorage:output
                                        withRange:range
                                 rangeOfEqualSign:&rangeOfEqualSign])
    {
      // Calculate solution
      solution = [self __solveMathInExpression:[output attributedSubstringFromRange:range]];
      if (solution) {
        [output addAttribute:kSVRSolverSolutionKey value:solution range:rangeOfEqualSign];
      } else {
        // TODO: Add Error as Attribute
        [XPLog alwys:@"%@: Error: Could not calculate solution", [[output string] substringWithRange:range]];
      }
    }
  }
}

+(BOOL)__solveIsSolvedExpressionInStorage:(NSMutableAttributedString*)input
                                withRange:(NSRange)range
                         rangeOfEqualSign:(NSRange*)checkRange;
{
  NSDecimalNumber *check;
  
  *checkRange = NSMakeRange(range.location + range.length - 1, 1);
  check = [input attribute:kSVRSolverSolutionKey
                   atIndex:checkRange->location
            effectiveRange:NULL];
  return check != nil;
}

+(NSDecimalNumber*)__solveMathInExpression:(NSAttributedString*)input;
{
  NSSet *setExponent = [NSSet setWithObject:kSVRSolverOperatorExponent];
  NSSet *setMultDiv  = [NSSet setWithObjects:kSVRSolverOperatorMultiply, kSVRSolverOperatorDivide, nil];
  NSSet *setAddSub   = [NSSet setWithObjects:kSVRSolverOperatorAdd, kSVRSolverOperatorSubtract, nil];
  
  NSRange patchRange = XPNotFoundRange;
  NSValue *bracketRange = nil;
  NSDecimalNumber *output = nil;
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
      [XPLog extra:@"<()> `%@` %@ → %@",
       [expression string], [[expression string] substringWithRange:patchRange], output
      ];
      [expression replaceCharactersInRange:patchRange
                      withAttributedString:[self __solveAttributedStringForPatchingWithDecimalNumber:output]];
    } else {
      [XPLog pause:@"<()> `%@` %@ → %@",
       [expression string], [[expression string] substringWithRange:patchRange], [NSDecimalNumber notANumber]
      ];
    }
    output = nil;
  }
  
  // Solve Exponents
  while ((output = [self __solveNextSubexpressionInExpression:expression
                                            forOperatorsInSet:setExponent
                                         rangeOfSubexpression:&patchRange]))
  {
    [XPLog extra:@"<^^> `%@` %@ → %@",
      [expression string], [[expression string] substringWithRange:patchRange], output
    ];
    [expression replaceCharactersInRange:patchRange
                    withAttributedString:[self __solveAttributedStringForPatchingWithDecimalNumber:output]];
  }
  
  // Find Multiplying and Dividing
  while ((output = [self __solveNextSubexpressionInExpression:expression
                                            forOperatorsInSet:setMultDiv
                                         rangeOfSubexpression:&patchRange]))
  {
    [XPLog extra:@"<*/> `%@` %@ → %@",
     [expression string], [[expression string] substringWithRange:patchRange], output
    ];
    [expression replaceCharactersInRange:patchRange
                    withAttributedString:[self __solveAttributedStringForPatchingWithDecimalNumber:output]];
  }
  
  while ((output = [self __solveNextSubexpressionInExpression:expression
                                            forOperatorsInSet:setAddSub
                                         rangeOfSubexpression:&patchRange]))
  {
    [XPLog extra:@"<+-> `%@` %@ → %@",
     [expression string], [[expression string] substringWithRange:patchRange], output
    ];
    [expression replaceCharactersInRange:patchRange
                    withAttributedString:[self __solveAttributedStringForPatchingWithDecimalNumber:output]];
  }
  
  if (![self __solveValidateOnlyNumeralsInAttributedString:expression]) {
    [XPLog pause:@"__solveMathInExpression: Non-numbers present in: `%@`", [expression string]];
    return nil;
  }
  
  output = [NSDecimalNumber decimalNumberWithString:[expression string]];
  return output;
}

+(NSValue*)__solveRangeForNextBracketsInExpression:(NSAttributedString*)input;
{
  NSString *check = nil;
  XPUInteger index = 0;
  NSRange output = XPNotFoundRange;
  while (index < [input length]) {
    check = [input attribute:kSVRSolverBracketsKey
                     atIndex:index
              effectiveRange:NULL];
    if (check && XPIsNotFoundRange(output)) {
      output.location = index;
      output.length = 1;
    } else if (check && XPIsFoundRange(output)) {
      output.length = index - output.location + 1;;
      if ((output.length-2)-(output.location+1) >= 1) {
        return [NSValue XP_valueWithRange:output];
      } else {
        output = XPNotFoundRange;
      }
    }
    index += 1;
  }
  return [NSValue XP_valueWithRange:XPNotFoundRange];
}

+(NSDecimalNumber*)__solveNextSubexpressionInExpression:(NSAttributedString*)expression
                                      forOperatorsInSet:(NSSet*)operators
                                   rangeOfSubexpression:(NSRange*)range;
{
  NSRange operatorRange = NSMakeRange(0, 1);
  NSRange lhsRange = XPNotFoundRange;
  NSRange rhsRange = XPNotFoundRange;
  NSString *operator = nil;
  NSDecimalNumber *lhs = nil;
  NSDecimalNumber *rhs = nil;
  
  // Find the first matching operator
  while (operatorRange.location + operatorRange.length <= [expression length]) {
    operator = [expression attribute:kSVRSolverOperatorKey
                             atIndex:operatorRange.location
                      effectiveRange:&operatorRange];
    if ([operators member:operator]) { break; }
    operatorRange.location = operatorRange.location + operatorRange.length;
    operatorRange.length = 1;
  }
  
  if (![operators member:operator]) {
    [XPLog extra:@"__solveNextSubexpressionInExpression: operator not found in set: '%@'", [expression string]];
    return nil;
  }
  
  lhsRange = NSMakeRange(operatorRange.location - 1, 1);
  if (lhsRange.location >= 0) {
    lhs = [expression attribute:kSVRSolverNumberKey
                        atIndex:lhsRange.location
                 effectiveRange:&lhsRange];
  }
  if (lhs == nil) {
    [XPLog extra:@"__solveNextSubexpressionInExpression: LHS number not found in expression: '%@'", [expression string]];
    return nil;
  }
  
  rhsRange = NSMakeRange(operatorRange.location + operatorRange.length, 1);
  if (rhsRange.location + rhsRange.length <= [expression length]) {
    rhs = [expression attribute:kSVRSolverNumberKey
                        atIndex:rhsRange.location
                 effectiveRange:&rhsRange];
  }
  if (rhs == nil) {
    [XPLog extra:@"__solveNextSubexpressionInExpression: RHS number not found in expression: '%@'", [expression string]];
    return nil;
  }
  
  range->location = lhsRange.location;
  range->length = lhsRange.length + operatorRange.length + rhsRange.length;
  
  return [self __solveWithOperator:operator leftNumber:lhs rightNumber:rhs];
}

+(NSDecimalNumber*)__solveWithOperator:(NSString*)anOp
                            leftNumber:(NSDecimalNumber*)lhs
                           rightNumber:(NSDecimalNumber*)rhs;
{
  
  if (anOp == nil || [lhs SVR_isNotANumber] || [rhs SVR_isNotANumber]) {
    [XPLog error:@"__solveWithOperator:%@ lhs:%@ rhs:%@", anOp, [lhs SVR_description], [rhs SVR_description]];
    return nil;
  }
  if ([kSVRSolverOperatorExponent isEqualToString:anOp]) {
    return [lhs SVR_decimalNumberByRaisingToPower:rhs];
  } else if ([kSVRSolverOperatorMultiply isEqualToString:anOp]) {
    return [lhs decimalNumberByMultiplyingBy:rhs];
  } else if ([kSVRSolverOperatorDivide isEqualToString:anOp]) {
    return [lhs decimalNumberByDividingBy:rhs];
  } else if ([kSVRSolverOperatorAdd isEqualToString:anOp]) {
    return [lhs decimalNumberByAdding:rhs];
  } else if ([kSVRSolverOperatorSubtract isEqualToString:anOp]) {
    return [lhs decimalNumberBySubtracting:rhs];
  } else {
    [XPLog error:@"Unknown Operator: %@", anOp];
    return nil;
  }
}

+(NSAttributedString*)__solveAttributedStringForPatchingWithDecimalNumber:(NSDecimalNumber*)number;
{
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:number
                                                         forKey:kSVRSolverNumberKey];
  return [[[NSAttributedString alloc] initWithString:[number SVR_description] attributes:attributes] autorelease];
}

+(BOOL)__solveValidateOnlyNumeralsInAttributedString:(NSAttributedString*)string;
{
  NSDictionary *attributes;
  XPUInteger index = 0;
  while (index < [string length]) {
    attributes = [string attributesAtIndex:index effectiveRange:NULL];
    if ([[attributes allKeys] count] != 1) {
      return NO;
    }
    if (![attributes objectForKey:kSVRSolverNumberKey]) {
      return NO;
    }
    index += 1;
  }
  return YES;
}

// MARK: Private: colorTextStorage
+(void)__colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)output;
{
  id check;
  XPUInteger index = 0;
  NSRange range = NSMakeRange(0, [output length]);
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  // Add font and other text attributes
  [output addAttribute:NSFontAttributeName value:[ud SVR_fontForText] range:range];
  [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForText] range:range];
  
  while (index < [output length]) {
    range = XPNotFoundRange;
    check = [output attribute:kSVRSolverBracketsKey atIndex:index effectiveRange:&range];
    if (check) {
      [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForBrackets] range:range];
    }
    check = [output attribute:kSVRSolverOperatorKey atIndex:index effectiveRange:&range];
    if (check) {
      [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForOperator] range:range];
    }
    check = [output attribute:kSVRSolverNumberKey atIndex:index effectiveRange:&range];
    if (check) {
      [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForNumeral] range:range];
    }
    check = [output attribute:kSVRSolverSolutionKey atIndex:index effectiveRange:&range];
    if (check) {
      [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForSolutionPrimary] range:range];
      [output addAttribute:NSBackgroundColorAttributeName value:[ud SVR_backgroundColorForSolutionPrimary] range:range];
    }
    if (XPIsNotFoundRange(range)) {
      index += 1;
    } else {
      index = range.location + range.length;
    }
  }
}


@end

@implementation SVRSolver (Testing)

+(void)executeTests;
{
  NSString *userInput = nil;
  NSMutableAttributedString *storage = nil;
  NSDecimalNumber *attributedSolution = nil;
  
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  
  userInput = @"5+7+3=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"5+7+3="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"15"]], @"");
  
  userInput = @"(2.0+-3.75)+150.0+120.0-37*30/8^2=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"(2.0+-3.75)+150.0+120.0-37*30/8^2="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"250.90625"]], @"");
  
  userInput = @"(5+7)+3=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"(5+7)+3="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"15"]], @"");
  
  userInput = @"150.0+120.0-37*30/8^2=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"150.0+120.0-37*30/8^2="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"252.65625"]], @"");
  
  userInput = @"(5.4+5)*(4--4.30)=3.3^2/(2+2)=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"(5.4+5)*(4--4.30)=3.3^2/(2+2)="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:17
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"86.32"]], @"");
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"2.7225"]], @"");
  
  /*
  // TODO: Still Failing
  userInput = @"4.0+3=-3.3^2=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"4.0+3=-3.3^2="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:5
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"7"]], @"");
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"-2.7225"]], @"");
   */
  
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];

}

@end

/*

// MARK: Testing
@implementation SVRMathString2 (Testing)
+(void)executeUnitTests;
{
  
  // MARK: Test Encoding
  SVRMathString2 *math;
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  math = [SVRMathString2 mathStringWithExpressionString:   @"-4(-2.35+2.2)-3*5-(50/-2)^2"];
  NSAssert([[math expressionString] isEqualToString:       @"-4(-2.35+2.2)-3*5-(50/-2)^2"], @"");
  NSAssert([[math encodedExpressionString] isEqualToString:@"-4(-2.35a2.2)s3m5s(50d-2)e2"], @"");
  
  // MARK: Test Coloring
  NSAssert([[[math coloredExpressionString] string] isEqualToString:@"-4(-2.35+2.2)-3*5-(50/-2)^2"], @"");
  // TODO: Test for the actual attributes
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
}
@end

*/
