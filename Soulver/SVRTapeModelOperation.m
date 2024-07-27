/* SVRTapeModelOperation.m created by me on Sat 27-Jul-2024 */

#import "SVRTapeModelOperation.h"

@implementation SVRTapeModelOperation

+(SVRTapeModelOperator)operatorForString:(NSString *)aString;
{
  if ([aString isEqual:@"+"]) {
    return SVRTapeModelOperatorAddition;
  } else if ([aString isEqual:@"-"]) {
    return SVRTapeModelOperatorSubtraction;
  } else if ([aString isEqual:@"/"]) {
    return SVRTapeModelOperatorDivision;
  } else if ([aString isEqual:@"*"]) {
    return SVRTapeModelOperatorMultiplication;
  } else {
    return SVRTapeModelOperatorUnknown;
  }
}

-(id)initWithValue:(float)aValue operator:(SVRTapeModelOperator)anOperator;
{
  value = value;
  operator = anOperator;
  self = [super init];
  return self;
}

@end
