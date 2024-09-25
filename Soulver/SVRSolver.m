//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRSolver.h"
#import "JSBRegex.h"

NSString *kSVRSolverSolutionKey   = @"kSVRSolverSolutionKey"; // Store NSDecimalNumber
NSString *kSVRSolverBracketsKey   = @"kSVRSolverBracketsKey";
NSString *kSVRSolverOperatorKey   = @"kSVRSolverOperatorKey";
NSString *kSVRSolverNumeralKey    = @"kSVRSolverNumeralKey";
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
  [output removeAttribute:kSVRSolverNumeralKey range:range];
  [output removeAttribute:kSVRSolverOtherKey range:range];
  
  // Restart annotation process
  [self __annotateBrackets:output];
  [self __annotateOperators:output];
  [self __annotateNumerals:output];
  
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
    [output addAttribute:kSVRSolverOperatorKey
                   value:kSVRSolverOperator(operator)
                   range:range];
  }
}

+(void)__annotateNumerals:(NSMutableAttributedString*)output;
{
  NSRange range;
  NSValue *value;
  NSString *check;
  // Find floats
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"\\-?\\d+\\.\\d+"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    check = [output attribute:kSVRSolverOperatorKey
                      atIndex:range.location
               effectiveRange:NULL];
    if (check == nil) {
      [output addAttribute:kSVRSolverNumeralKey value:kSVRSolverYES range:range];
    }
  }
  
  // Find integers
  regex = [JSBRegex regexWithString:[output string]
                            pattern:@"\\d+"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    check = [output attribute:kSVRSolverNumeralKey
                      atIndex:range.location
               effectiveRange:NULL];
    if (check == nil) {
      [output addAttribute:kSVRSolverNumeralKey value:kSVRSolverYES range:range];
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
  XPUInteger index = 0;
  NSRange lhsRange = XPNotFoundRange;
  NSRange rhsRange = XPNotFoundRange;
  NSString *check    = nil;
  NSString *operator = nil;
  NSDecimalNumber *solution = nil;
  
  while (index < [expression length]) {
    // find numbers
    check = [expression attribute:kSVRSolverNumeralKey
                     atIndex:index
              effectiveRange:NULL];
    if (check) {
      if (XPIsNotFoundRange(lhsRange)) {
        lhsRange.location = index;
        lhsRange.length = 1;
      } else if (XPIsFoundRange(lhsRange) && !operator) {
        lhsRange.length = index - lhsRange.location + 1;
      } else if (XPIsNotFoundRange(rhsRange) && operator) {
        rhsRange.location = index;
        rhsRange.length = 1;
      } else if (XPIsFoundRange(rhsRange) && operator) {
        rhsRange.length = index - rhsRange.location + 1;
      }
    } else {
      if (XPIsFoundRange(lhsRange) && XPIsFoundRange(rhsRange) && operator) {
        break; // everything is satisfied and we can break
      } else if (XPIsFoundRange(lhsRange) && !operator) {
        check = [expression attribute:kSVRSolverOperatorKey
                         atIndex:index
                  effectiveRange:NULL];
        if ([operators member:check]) {
          operator = check;
        } else {
          // reset everything because we just found the wrong operator
          lhsRange = XPNotFoundRange;
          rhsRange = XPNotFoundRange;
        }
      }
    }
    index += 1;
  }
  if (XPIsNotFoundRange(lhsRange) || XPIsNotFoundRange(rhsRange) || !operator) {
    // no problem to solve
    return nil;
  }
  solution = [self __solveWithOperator:operator
                            leftString:[[expression string] substringWithRange:lhsRange]
                           rightString:[[expression string] substringWithRange:rhsRange]];
  *range = NSMakeRange(lhsRange.location, lhsRange.length + 1 + rhsRange.length);
  
  return solution;
}

+(NSDecimalNumber*)__solveWithOperator:(NSString*)anOp
                            leftString:(NSString*)leftString
                           rightString:(NSString*)rightString;
{
  NSDecimalNumber *lhs = [NSDecimalNumber decimalNumberWithString:leftString];
  NSDecimalNumber *rhs = [NSDecimalNumber decimalNumberWithString:rightString];
  
  if ([lhs SVR_isNotANumber] || [rhs SVR_isNotANumber]) {
    [XPLog error:@"__solveWithOperator:%@ lhs:%@ rhs:%@", anOp, leftString, rightString];
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
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:kSVRSolverYES
                                                         forKey:kSVRSolverNumeralKey];
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
    if (![attributes objectForKey:kSVRSolverNumeralKey]) {
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
    check = [output attribute:kSVRSolverNumeralKey atIndex:index effectiveRange:&range];
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
  
  userInput = @"5+7+3=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"5+7+3="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"15"]], @"");
  
  
  /*
  _string = @"(5+7)+3=";
  string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [SVRSolver annotateStorage:string];
  [SVRSolver solveAnnotatedStorage:string];
  NSAssert([[string string] isEqualToString:@"(5+7)+3=15"], @"");
  
  _string = @"5+7+3=";
  string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [SVRSolver annotateStorage:string];
  [SVRSolver solveAnnotatedStorage:string];
  NSAssert([[string string] isEqualToString:@"5+7+3=15"], @"");
  
  _string = @"150.0+120.0-37*30/8^2=";
  string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [SVRSolver annotateStorage:string];
  NSAssert([[string string] isEqualToString:@"150.0+120.0-37*30/8^2="], @"");
  [SVRSolver solveAnnotatedStorage:string];
  NSAssert([[string string] isEqualToString:@"150.0+120.0-37*30/8^2=252.65625\n"], @"");
  [SVRSolver colorAnnotatedAndSolvedStorage:string];
  
  _string = @"(5.4+5)*(4--4.30)=3.3^2/(2+2)=";
  string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [SVRSolver annotateStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver solveAnnotatedStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver colorAnnotatedAndSolvedStorage:string];
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
