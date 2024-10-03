//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSoulverTagger.h"
#import "SVRCrossPlatform.h"

NSString *SVR_stringForTag(SVRSoulverTag tag)
{
  switch (tag) {
    case SVRSoulverTagNumber:     return @"kSVRSoulverTagNumberKey";
    case SVRSoulverTagOperator:   return @"kSVRSoulverTagOperatorKey";
    case SVRSoulverTagExpression: return @"kSVRSoulverTagExpressionKey";
    case SVRSoulverTagBracket:    return @"kSVRSoulverTagBracketKey";
    default:
      [XPLog error:@"SVR_stringForTagUnknown: %d", tag];
      return nil;
  }
}
SVRSoulverTag SVR_tagForString(NSString *string)
{
  if        ([string isEqualToString:SVR_stringForTag(SVRSoulverTagNumber)])     {
    return SVRSoulverTagNumber;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSoulverTagOperator)])   {
    return SVRSoulverTagOperator;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSoulverTagExpression)]) {
    return SVRSoulverTagExpression;
  } else if ([string isEqualToString:SVR_stringForTag(SVRSoulverTagBracket)])    {
    return SVRSoulverTagBracket;
  } else {
    [XPLog error:@"SVR_tagForStringUnknown: %@", string];
    return (SVRSoulverTag)-1;
  }
}

@implementation SVRSoulverTagger

+(void)tagNumbersAtRanges:(NSSet*)ranges
       inAttributedString:(NSMutableAttributedString*)string;
{
  
}

+(void)tagOperatorsAtRanges:(NSSet*)ranges
         inAttributedString:(NSMutableAttributedString*)string;
{
  
}

+(void)tagExpressionsAtRanges:(NSSet*)ranges
           inAttributedString:(NSMutableAttributedString*)string;
{
  
}

+(void)tagBracketsAtRanges:(NSSet*)ranges
        inAttributedString:(NSMutableAttributedString*)string;
{
  
}

+(NSDictionary*)attributesWithTag:(SVRSoulverTag)tag andValue:(id)value;
{
  return [NSDictionary dictionaryWithObject:value forKey:SVR_stringForTag(tag)];
}

@end

@implementation SVRSoulverTagger (Tests)
+(void)executeTests;
{
  
}
@end
