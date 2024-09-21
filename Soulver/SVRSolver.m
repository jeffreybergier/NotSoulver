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

//NSString *kSVRSolverExpressionSolved    = @"kSVRSolverExpressionSolved";
//NSString *kSVRSolverExpressionNotSolved = @"kSVRSolverExpressionNotSolved";
NSString *kSVRSolverOperatorExponent    = @"kSVRSolverOperatorExponent";
NSString *kSVRSolverOperatorMultDiv     = @"kSVRSolverOperatorMultDiv";
NSString *kSVRSolverOperatorAddSub      = @"kSVRSolverOperatorAddSub";
NSString *kSVRSolverYES                 = @"kSVRSolverYES";

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
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\)][\\^\\*\\-\\+\\/][\\-\\d\\(]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.location += 1;
    range.length = 1;
    [output addAttribute:kSVRSolverOperatorKey value:kSVRSolverYES range:range];
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
  NSRange range;
  NSAttributedString *solution;
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"[\\d\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    if (![self __solveIsValidSolutionInStorage:output
                        forExpressionWithRange:range])
    {
      NSLog(@"Solving: %@", [[output string] substringWithRange:range]);
      solution = [self __solvePEMDASInExpression:[output attributedSubstringFromRange:range]];
      NSLog(@"Solved: %@%@", [[output string] substringWithRange:range], solution);
    }
    range = [regex nextMatch];
  }
}

+(BOOL)__solveIsValidSolutionInStorage:(NSMutableAttributedString*)input
                forExpressionWithRange:(NSRange)range;
{
  NSRange checkRange;
  NSDecimalNumber *check;
  
  if (range.location + range.length >= [input length]) {
    return NO;
  }
  checkRange = NSMakeRange(range.location + 1, 1);
  check = [input attribute:kSVRSolverSolutionKey
                    atIndex:checkRange.location
             effectiveRange:NULL];
  return check != nil;
}

+(NSAttributedString*)__solvePEMDASInExpression:(NSAttributedString*)input;
{
  NSMutableAttributedString *output = [[input mutableCopy] autorelease];
  return output;
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
  NSString *_string = @"(5.4+5)*(4--4.30)=3.3^2/(2+2)=";
  NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  [SVRSolver annotateStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver colorAnnotatedAndSolvedStorage:string];
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
