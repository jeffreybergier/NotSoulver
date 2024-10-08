//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRSolver.h"
#import "SVRCrossPlatform.h"
#import "SVRSolverStyler.h"
#import "SVRSolverScanner.h"
#import "SVRSolverSolutionTagger.h"
#import "SVRSolverSolutionInserter.h"
#import "SVRSolverExpressionTagger.h"

NSNumber* SVR_numberForOperator(SVRSolverOperator operator)
{
  return [NSNumber XP_numberWithInteger:operator];
}

SVRSolverOperator SVR_operatorForNumber(NSNumber *number)
{
  return (SVRSolverOperator)[number XP_integerValue];
}

SVRSolverOperator SVR_operatorForRawString(NSString *string)
{
  if        ([string isEqualToString:@"^"]) {
    return SVRSolverOperatorExponent;
  } else if ([string isEqualToString:@"/"]) {
    return SVRSolverOperatorDivide;
  } else if ([string isEqualToString:@"*"]) {
    return SVRSolverOperatorMultiply;
  } else if ([string isEqualToString:@"-"]) {
    return SVRSolverOperatorSubtract;
  } else if ([string isEqualToString:@"+"]) {
    return SVRSolverOperatorAdd;
  } else {
    [XPLog error:@"SVR_operatorForRawStringUnknown: %@", string];
    return (SVRSolverOperator)-1;
  }
}

NSString *SVR_stringForTag(SVRSolverTag tag)
{
  switch (tag) {
    case SVRSolverTagNumber:             return @"kSVRSoulverTagNumberKey";
    case SVRSolverTagBracket:            return @"kSVRSoulverTagBracketKey";
    case SVRSolverTagOperator:           return @"kSVRSoulverTagOperatorKey";
    case SVRSolverTagExpression:         return @"kSVRSoulverTagExpressionKey";
    case SVRSolverTagSolution:           return @"kSVRSolverTagSolutionKey";
    case SVRSolverTagPreviousSolution:   return @"kSVRSolverTagPreviousSolutionKey";
    default:
      [XPLog error:@"SVR_stringForTagUnknown: %d", tag];
      return nil;
  }
}

SVRSolverTag SVR_tagForString(NSString *string)
{
  if        ([string isEqualToString:SVR_stringForTag(SVRSolverTagNumber)])           {
    return SVRSolverTagNumber;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSolverTagBracket)])          {
    return SVRSolverTagBracket;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSolverTagOperator)])         {
    return SVRSolverTagOperator;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSolverTagExpression)])       {
    return SVRSolverTagExpression;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSolverTagSolution)])         {
    return SVRSolverTagSolution;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSolverTagPreviousSolution)]) {
    return SVRSolverTagPreviousSolution;
  } else {
    [XPLog error:@"SVR_tagForStringUnknown: %@", string];
    return (SVRSolverTag)-1;
  }
}

@implementation SVRSolver: NSObject

// MARK: Business Logic
+(void)annotateStorage:(NSMutableAttributedString*)input;
{
  SVRSolverScanner *scanner = nil;
  [input retain];
  [self __removeAllAttributesInStorage:input];
  scanner = [SVRSolverScanner scannerWithString:[input string]];
  [SVRSolverExpressionTagger tagNumbersAtRanges:[scanner numberRanges]
                             inAttributedString:input];
  [SVRSolverExpressionTagger tagBracketsAtRanges:[scanner bracketRanges]
                              inAttributedString:input];
  [SVRSolverExpressionTagger tagOperatorsAtRanges:[scanner operatorRanges]
                               inAttributedString:input];
  [SVRSolverExpressionTagger tagExpressionsAtRanges:[scanner expressionRanges]
                                 inAttributedString:input];
  [input autorelease];
}

+(void)solveAnnotatedStorage:(NSMutableAttributedString*)input;
{
  //NSArray *solutions = nil;
  [SVRSolverSolutionTagger tagSolutionsInAttributedString:input];
  //solutions = [SVRSolverSolutionInserter solutionsToInsertFromAttributedString:input];
  //[SVRSolverSolutionInserter insertSolutions:solutions inAttributedString:input];
}

+(void)colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;
{
  [SVRSolverStyler styleTaggedExpression:input];
}

// MARK: Private

+(void)__removeAllAttributesInStorage:(NSMutableAttributedString*)input;
{
  NSRange range = NSMakeRange(0, [input length]);
  [input removeAttribute:SVR_stringForTag(SVRSolverTagNumber) range:range];
  [input removeAttribute:SVR_stringForTag(SVRSolverTagBracket) range:range];
  [input removeAttribute:SVR_stringForTag(SVRSolverTagOperator) range:range];
  [input removeAttribute:SVR_stringForTag(SVRSolverTagSolution) range:range];
  [input removeAttribute:SVR_stringForTag(SVRSolverTagExpression) range:range];
  [input removeAttribute:SVR_stringForTag(SVRSolverTagPreviousSolution) range:range];
  [input removeAttribute:NSFontAttributeName range:range];
  [input removeAttribute:NSForegroundColorAttributeName range:range];
  [input removeAttribute:NSBackgroundColorAttributeName range:range];
}


@end

@implementation SVRSolver (Testing)

+(void)executeTests;
{
  /*
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
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"-10.89"]], @"");
  
  userInput = @"-3+4*5=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"-3+4*5="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"17"]], @"");
  
  userInput = @"-3.5+4.5*5.5=";
  storage = [[[NSMutableAttributedString alloc] initWithString:userInput] autorelease];
  [SVRSolver annotateStorage:storage];
  NSAssert([[storage string] isEqualToString:@"-3.5+4.5*5.5="], @"");
  [SVRSolver solveAnnotatedStorage:storage];
  attributedSolution = [storage attribute:kSVRSolverSolutionKey
                                  atIndex:[storage length] - 1
                           effectiveRange:NULL];
  NSAssert([attributedSolution isEqual:[NSDecimalNumber decimalNumberWithString:@"21.25"]], @"");
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
  */
}

@end
