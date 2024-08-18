//
//  SVRMathString+Tests.m
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/18.
//

#import "SVRMathString+Rendering.h"
#import "SVRMathString+Tests.h"

@implementation SVRMathString (Tests)

+(void)executeTests;
{
  [[SVRMathString mathStringWithString:@"5*5="]
                     __testAssertEqual:@"5*5=25\n"];
  
  [[SVRMathString mathStringWithString:@"5*5=-5="]
                     __testAssertEqual:@"5*5=25\n25-5=20\n"];
  
  [[SVRMathString mathStringWithString:@"10/2="]
                     __testAssertEqual:@"10/2=5\n"];
  
  [[SVRMathString mathStringWithString:@"(10+2)*5="]
                     __testAssertEqual:@"(10+2)*5=60\n"];
  
  [[SVRMathString mathStringWithString:@"(10+2)+(8-7)*5="]
                     __testAssertEqual:@"(10+2)+(8-7)*5=17\n"];
  
  [[SVRMathString mathStringWithString:@"5="]
                     __testAssertEqual:@"5=5\n"];
  
  [[SVRMathString mathStringWithString:@"+5="]
                     __testAssertEqual:@"+5=<ERROR>"];
  
  [[SVRMathString mathStringWithString:@"5+="]
                     __testAssertEqual:@"5+=<ERROR>"];
  
  [[SVRMathString mathStringWithString:@"(5*((10+3)*10+2)^2)="]
                     __testAssertEqual:@"(5*((10+3)*10+2)^2)=87120\n"];
  
  [[SVRMathString mathStringWithString:@"(5*((10+3)*10+2)^2="]
                     __testAssertEqual:@"(5*((10+3)*10+2)^2=<ERROR>"];
  
  [[SVRMathString mathStringWithString:@"5(10)="]
                     __testAssertEqual:@"5(10)=<ERROR>"];
  
  [[SVRMathString mathStringWithString:@"(10)5="]
                     __testAssertEqual:@"(10)5=<ERROR>"];
}

-(void)__testAssertEqual:(NSString*)rhs;
{
  NSString *lhs = [[self render] string];
  NSString *message = [NSString stringWithFormat:@"SVRMathStringTest: FAIL: %@ != %@", lhs, rhs];
  NSAssert([lhs isEqualToString:rhs], message);
  NSLog(@"SVRMathStringTest: PASS: %@", lhs);
}

@end
