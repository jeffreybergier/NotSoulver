//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRSolver.h"
#import "JSBRegex.h"

NSString *kSVRSolverSolutionKey   = @"kSVRSolverSolutionKey"; // Store NSDecimalNumber
NSString *kSVRSolverExpressionKey = @"kSVRSolverExpressionKey";
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
  [output removeAttribute:kSVRSolverExpressionKey range:range];
  [output removeAttribute:kSVRSolverBracketsKey range:range];
  [output removeAttribute:kSVRSolverOperatorKey range:range];
  [output removeAttribute:kSVRSolverNumeralKey range:range];
  [output removeAttribute:kSVRSolverOtherKey range:range];
  
  // Restart annotation process
  [self __annotateExpressions:output];
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
+(void)__annotateExpressions:(NSMutableAttributedString*)output;
{
  NSRange range;
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [output addAttribute:kSVRSolverExpressionKey value:kSVRSolverYES range:range];
    range = [regex nextMatch];
  }
}

+(void)__annotateBrackets:(NSMutableAttributedString*)output;
{
  NSRange range;
  // Check for opening brackets
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"\\([\\-\\d]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.length = 1;
    [output addAttribute:kSVRSolverBracketsKey value:kSVRSolverYES range:range];
    range = [regex nextMatch];
  }
  
  // Check for closing brackets
  regex = [JSBRegex regexWithString:[output string]
                            pattern:@"\\d\\)[\\^\\*\\/\\+\\-\\=]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.location += 1;
    range.length = 1;
    [output addAttribute:kSVRSolverBracketsKey value:kSVRSolverYES range:range];
    range = [regex nextMatch];
  }
}

+(void)__annotateOperators:(NSMutableAttributedString*)output;
{
  NSRange range;
  NSString *operator;
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\)][\\*\\-\\+\\/\\^][\\-\\d\\(]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.location += 1;
    range.length = 1;
    operator = [[output string] substringWithRange:range];
    [output addAttribute:kSVRSolverOperatorKey
                   value:kSVRSolverOperator(operator)
                   range:range];
    range = [regex nextMatch];
  }
  
  // Do a second round looking for just the exponent
  // TODO: Fix problem where Regex doesn't seem to work right when ^ is in []
  regex = [JSBRegex regexWithString:[output string]
                            pattern:@"[\\d\\)]\\^[\\-\\d\\(]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.location += 1;
    range.length = 1;
    operator = [[output string] substringWithRange:range];
    [output addAttribute:kSVRSolverOperatorKey
                   value:kSVRSolverOperator(operator)
                   range:range];
    range = [regex nextMatch];
  }
}

+(void)__annotateNumerals:(NSMutableAttributedString*)output;
{
  NSRange range;
  NSString *check;
  // Find floats
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"\\-?\\d+\\.\\d+"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    check = [output attribute:kSVRSolverOperatorKey
                      atIndex:range.location
               effectiveRange:NULL];
    if (check == nil) {
      [output addAttribute:kSVRSolverNumeralKey value:kSVRSolverYES range:range];
    }
    range = [regex nextMatch];
  }
  
  // Find integers
  regex = [JSBRegex regexWithString:[output string]
                            pattern:@"\\d+"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    check = [output attribute:kSVRSolverNumeralKey
                      atIndex:range.location
               effectiveRange:NULL];
    if (check == nil) {
      [output addAttribute:kSVRSolverNumeralKey value:kSVRSolverYES range:range];
    }
    range = [regex nextMatch];
  }
}

// MARK: Private: annotateStorage
+(void)__solveExpressions:(NSMutableAttributedString*)output;
{
  NSRange rangeOfExpression; // found by regex
  NSRange rangeForSolving;   // subtracting the = sign at the end
  NSRange rangeForEqualSign; // to apply to the solution key to the equal sign
  NSAttributedString *solution;
  
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
  rangeOfExpression = [regex nextMatch];
  while (rangeOfExpression.location != NSNotFound) {
    if (![self __solveIsSolvedExpressionInStorage:output
                                        withRange:rangeOfExpression])
    {
      rangeForEqualSign = NSMakeRange(rangeOfExpression.location + rangeOfExpression.length - 1, 1);
      rangeForSolving = NSMakeRange(rangeOfExpression.location, rangeOfExpression.length - 1);
      solution = [self __solvePEMDASInExpression:[output attributedSubstringFromRange:rangeForSolving]];
      NSLog(@"Solved: %@`%@`", [[output string] substringWithRange:rangeOfExpression], [solution string]);
      [output insertAttributedString:solution atIndex:rangeOfExpression.location + rangeOfExpression.length];
      [output addAttribute:kSVRSolverSolutionKey
                     value:[solution attribute:kSVRSolverSolutionKey atIndex:0 effectiveRange:NULL]
                     range:rangeForEqualSign];
    }
    rangeOfExpression = [regex nextMatch];
  }
}

+(BOOL)__solveIsSolvedExpressionInStorage:(NSMutableAttributedString*)input
                                withRange:(NSRange)range;
{
  NSRange checkRange;
  NSDecimalNumber *check;
  
  checkRange = NSMakeRange(range.location + range.length - 1, 1);
  check = [input attribute:kSVRSolverSolutionKey
                   atIndex:checkRange.location
            effectiveRange:NULL];
  return check != nil;
}

+(NSAttributedString*)__solvePEMDASInExpression:(NSAttributedString*)input;
{
  NSSet *setExponent = [NSSet setWithObject:kSVRSolverOperatorExponent];
  NSSet *setMultDiv  = [NSSet setWithObjects:kSVRSolverOperatorMultiply, kSVRSolverOperatorDivide, nil];
  NSSet *setAddSub   = [NSSet setWithObjects:kSVRSolverOperatorAdd, kSVRSolverOperatorSubtract, nil];
  
  NSDecimalNumber *finalSolution = nil;
  NSAttributedString *patchSolution = nil;
  NSRange patchRange = NSMakeRange(NSNotFound, 0);
  NSMutableAttributedString *output = [[input mutableCopy] autorelease];
  
  // Find brackets
  patchRange = [self __solveRangeForBracketsInExpression:output];
  while (patchRange.location != NSNotFound) {
    patchSolution = [self __solvePEMDASInExpression:[output attributedSubstringFromRange:NSMakeRange(patchRange.location+1, patchRange.length-2)]];
    NSAssert(patchSolution, @"BOOM");
    NSLog(@"<()> `%@` %@ → %@", [output string], [[output string] substringWithRange:patchRange], [patchSolution string]);
    [output replaceCharactersInRange:patchRange withAttributedString:patchSolution];
    patchRange = [self __solveRangeForBracketsInExpression:output];
  }
  
  // Solve Exponents
  while ((patchSolution = [self __solveSubexpression:output forOperatorsInSet:setExponent rangeForPatching:&patchRange]))
  {
    NSLog(@"<^^> `%@` %@ → %@", [output string], [[output string] substringWithRange:patchRange], [patchSolution string]);
    [output replaceCharactersInRange:patchRange withAttributedString:patchSolution];
  }
  
  // Find Multiplying and Dividing
  while ((patchSolution = [self __solveSubexpression:output forOperatorsInSet:setMultDiv rangeForPatching:&patchRange]))
  {
    NSLog(@"<*/> `%@` %@ → %@", [output string], [[output string] substringWithRange:patchRange], [patchSolution string]);
    [output replaceCharactersInRange:patchRange withAttributedString:patchSolution];
  }
  
  while ((patchSolution = [self __solveSubexpression:output forOperatorsInSet:setAddSub rangeForPatching:&patchRange]))
  {
    NSLog(@"<+-> `%@` %@ → %@", [output string], [[output string] substringWithRange:patchRange], [patchSolution string]);
    [output replaceCharactersInRange:patchRange withAttributedString:patchSolution];
  }
  
  finalSolution = [NSDecimalNumber decimalNumberWithString:[output string]];
  if ([finalSolution SVR_isNotANumber]) {
    return nil;
  }
  
  [output addAttribute:kSVRSolverSolutionKey value:finalSolution range:NSMakeRange(0, [output length])];
  return output;
}

+(NSRange)__solveRangeForBracketsInExpression:(NSAttributedString*)input;
{
  NSString *check = nil;
  XPUInteger index = 0;
  NSRange output = NSMakeRange(NSNotFound, 0);
  while (index < [input length]) {
    check = [input attribute:kSVRSolverBracketsKey
                     atIndex:index
              effectiveRange:NULL];
    if (check && output.location == NSNotFound) {
      output.location = index;
      output.length = 1;
    } else if (check && output.location != NSNotFound) {
      output.length = index - output.location + 1;;
      if ((output.length-2)-(output.location+1) >= 1) {
        return output;
      } else {
        output.location = NSNotFound;
      }
    }
    index += 1;
  }
  return NSMakeRange(NSNotFound, 0);
}

+(NSAttributedString*)__solveSubexpression:(NSAttributedString*)input
                         forOperatorsInSet:(NSSet*)operators
                          rangeForPatching:(NSRange*)range;
{
  XPUInteger index = 0;
  NSRange lhsRange = NSMakeRange(NSNotFound, 0);
  NSRange rhsRange = NSMakeRange(NSNotFound, 0);
  NSString *check    = nil;
  NSString *operator = nil;
  NSDecimalNumber *solution = nil;
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:kSVRSolverYES
                                                         forKey:kSVRSolverNumeralKey];
  
  while (index < [input length]) {
    // find numbers
    check = [input attribute:kSVRSolverNumeralKey
                     atIndex:index
              effectiveRange:NULL];
    if (check) {
      if (lhsRange.location == NSNotFound) {
        lhsRange.location = index;
        lhsRange.length = 1;
      } else if (lhsRange.location != NSNotFound && operator == nil) {
        lhsRange.length = index - lhsRange.location + 1;
      } else if (rhsRange.location == NSNotFound && operator != nil) {
        rhsRange.location = index;
        rhsRange.length = 1;
      } else if (rhsRange.location != NSNotFound && operator != nil) {
        rhsRange.length = index - rhsRange.location + 1;
      }
    } else {
      if (lhsRange.location != NSNotFound && rhsRange.location != NSNotFound && operator != nil) {
        break; // everything is satisfied and we can break
      } else if (lhsRange.location != NSNotFound && operator == nil) {
        check = [input attribute:kSVRSolverOperatorKey
                         atIndex:index
                  effectiveRange:NULL];
        if ([operators member:check]) {
          operator = check;
        } else {
          // reset everything because we just found the wrong operator
          lhsRange = NSMakeRange(NSNotFound, 0);
          rhsRange = NSMakeRange(NSNotFound, 0);
        }
      }
    }
    index += 1;
  }
  if (lhsRange.location == NSNotFound || rhsRange.location == NSNotFound || operator == nil) {
    // no problem to solve
    return nil;
  }
  solution = [self __solveWithOperator:operator
                            leftString:[[input string] substringWithRange:lhsRange]
                           rightString:[[input string] substringWithRange:rhsRange]];
  *range = NSMakeRange(lhsRange.location, lhsRange.length + 1 + rhsRange.length);
  return [[[NSAttributedString alloc] initWithString:[solution SVR_description]
                                          attributes:attributes] autorelease];
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

// MARK: Private: colorTextStorage
+(void)__colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)output;
{
  NSString *check;
  XPUInteger index = 0;
  NSRange range = NSMakeRange(0, [output length]);
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  // Add font and other text attributes
  [output addAttribute:NSFontAttributeName value:[ud SVR_fontForText] range:range];
  [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForText] range:range];
  
  while (index < [output length]) {
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
    index += 1;
  }
}


@end

@implementation SVRSolver (Testing)

+(void)executeTests;
{
  NSString *_string = @"150.0+120.0-37*30/8^2=";
  NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  [SVRSolver annotateStorage:string];
  NSAssert([[string string] isEqualToString:@"150.0+120.0-37*30/8^2="], @"");
  [SVRSolver solveAnnotatedStorage:string];
  NSAssert([[string string] isEqualToString:@"150.0+120.0-37*30/8^2=252.65625"], @"");
  [SVRSolver colorAnnotatedAndSolvedStorage:string];
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
  /*
  NSString *_string = @"(5.4+5)*(4--4.30)=3.3^2/(2+2)=";
  NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  [SVRSolver annotateStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver solveAnnotatedStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver colorAnnotatedAndSolvedStorage:string];
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
   */
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
