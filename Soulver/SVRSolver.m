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
#import "SVRSolverExpressionTagger.h"

NSNumber* NSNumberForOperator(SVRSolverOperator operator)
{
  return [NSNumber XP_numberWithInteger:operator];
}

SVRSolverOperator SVRSolverOperatorForNumber(NSNumber *number)
{
  return (SVRSolverOperator)[number XP_integerValue];
}

SVRSolverOperator SVRSolverOperatorForRawString(NSString *string)
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

NSString *XPAttributedStringKeyForTag(SVRSolverTag tag)
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

SVRSolverTag SVRSolverTagForKey(XPAttributedStringKey string)
{
  if        ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagNumber)])           {
    return SVRSolverTagNumber;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagBracket)])          {
    return SVRSolverTagBracket;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagOperator)])         {
    return SVRSolverTagOperator;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagExpression)])       {
    return SVRSolverTagExpression;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagSolution)])         {
    return SVRSolverTagSolution;
  } else if ([string isEqualToString:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution)]) {
    return SVRSolverTagPreviousSolution;
  } else {
    [XPLog error:@"SVR_tagForStringUnknown: %@", string];
    return (SVRSolverTag)-1;
  }
}

@implementation SVRSolver: NSObject

+(void)removeAllSolutionsAndTags:(NSMutableAttributedString*)input;
{
  NSRange range = XPNotFoundRange;
  [input retain];
  
  range = NSMakeRange(0, [input length]);
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagNumber) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression) range:range];
  [input removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagPreviousSolution) range:range];
  [input removeAttribute:NSFontAttributeName range:range];
  [input removeAttribute:NSForegroundColorAttributeName range:range];
  [input removeAttribute:NSBackgroundColorAttributeName range:range];
  
  [input autorelease];
}

// MARK: Business Logic
+(void)solveAndTagAttributedString:(NSMutableAttributedString*)input;
{
  SVRSolverScanner *scanner = nil;
  [input retain];
  
  // Add Tags
  scanner = [SVRSolverScanner scannerWithString:[input string]];
  [SVRSolverExpressionTagger tagNumbersAtRanges:[scanner numberRanges]
                             inAttributedString:input];
  [SVRSolverExpressionTagger tagBracketsAtRanges:[scanner bracketRanges]
                              inAttributedString:input];
  [SVRSolverExpressionTagger tagOperatorsAtRanges:[scanner operatorRanges]
                               inAttributedString:input];
  [SVRSolverExpressionTagger tagExpressionsAtRanges:[scanner expressionRanges]
                                 inAttributedString:input];
  
  // Solve
  [SVRSolverSolutionTagger tagSolutionsInAttributedString:input];
  
  [input autorelease];
}
+(void)styleSolvedAndTaggedAttributedString:(NSMutableAttributedString*)input;
{
  [SVRSolverStyler styleTaggedExpression:input];
}

@end

@implementation SVRSolver (Testing)

+(void)executeTests;
{
  
}

@end
