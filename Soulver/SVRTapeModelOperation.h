/* SVRTapeModelOperation.h created by me on Sat 27-Jul-2024 */

#import <AppKit/AppKit.h>

typedef enum {
  SVRTapeModelOperatorAddition = 0,
  SVRTapeModelOperatorSubtraction = 1,
  SVRTapeModelOperatorMultiplication = 2,
  SVRTapeModelOperatorDivision = 3,
  SVRTapeModelOperatorUnknown = 0,
} SVRTapeModelOperator;

@interface SVRTapeModelOperation : NSObject
{
  float value;
  int operator;
}

+(SVRTapeModelOperator)operatorForString:(NSString *)aString;
-(id)initWithValue:(float)aValue operator:(SVRTapeModelOperator)anOperator;

@end
