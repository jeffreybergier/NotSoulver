//
//  SVRMathString+Tests.m
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/18.
//

#import "SVRMathString+Rendering.h"
#import "SVRMathString+Tests.h"
#import "SVRConstants.h"

@implementation SVRMathString (Tests)

+(void)executeTests;
{
  // MARK: Test Interactive
  
  SVRMathString *model = [[[SVRMathString alloc] init] autorelease];
  NSNumber *error = nil;
  [model __testAssertEqual:@""];
  [model appendCharacter:@"H" error:&error];
  NSAssert([error isEqualToNumber:[NSNumber SVR_errorInvalidCharacter]], @"");
  error = nil;
  [model appendCharacter:@"5" error:&error];
  [model __testAssertEqual:@"5"];
  [model appendCharacter:@"+" error:&error];
  [model __testAssertEqual:@"5+"];
  [model appendCharacter:@"5" error:&error];
  [model __testAssertEqual:@"5+5"];
  [model appendCharacter:@"=" error:&error];
  [model __testAssertEqual:@"5+5=10\n"];
  [model appendCharacter:@"=" error:&error];
  [model appendCharacter:@"=" error:&error];
  [model __testAssertEqual:@"5+5=10\n"];
  [model appendCharacter:@"*" error:&error];
  [model __testAssertEqual:@"5+5=10\n10*"];
  [model appendCharacter:@"9" error:&error];
  [model __testAssertEqual:@"5+5=10\n10*9"];
  [model appendCharacter:@"=" error:&error];
  [model __testAssertEqual:@"5+5=10\n10*9=90\n"];
  NSAssert(error == nil, @"");
  model = nil;
  
  // MARK: Test Errors
  
  [[SVRMathString mathStringWithString:@"5a5a5Xa6a6a6="]
                     __testAssertEqual:@"5a5a5Xa6a6a6=<Error:-1002>\n"];
  
  [[SVRMathString mathStringWithString:@"(5m((10a3)m10a2)e2="]
                     __testAssertEqual:@"(5m((10a3)m10a2)e2=<Error:-1003>\n"];
  
  [[SVRMathString mathStringWithString:@"1m2=s3=aa4=6a7="]
                     __testAssertEqual:@"1m2=s3=aa4=6a7=<Error:-1004>\n"];
  
  [[SVRMathString mathStringWithString:@"5aa="]
                     __testAssertEqual:@"5aa=<Error:-1004>\n"];
  
  [[SVRMathString mathStringWithString:@"aa5="]
                     __testAssertEqual:@"aa5=<Error:-1004>\n"];
  
  [[SVRMathString mathStringWithString:@"a5="]
                     __testAssertEqual:@"a5=<Error:-1004>\n"];
  
  [[SVRMathString mathStringWithString:@"5a="]
                     __testAssertEqual:@"5a=<Error:-1004>\n"];
  
  [[SVRMathString mathStringWithString:@"1m2=s3=4a=6a7="]
                     __testAssertEqual:@"1m2=s3=4a=6a7=<Error:-1004>\n"];
  
  [[SVRMathString mathStringWithString:@"5(10)="]
                     __testAssertEqual:@"5(10)=<Error:-1005>\n"];
  
  [[SVRMathString mathStringWithString:@"(10)5="]
                     __testAssertEqual:@"(10)5=<Error:-1005>\n"];
  
  [[SVRMathString mathStringWithString:@"8e8=d8e5="]
                     __testAssertEqual:@"8^8=16777216\n16777216/8^5=512\n"];
  
  // MARK: Test Normal Math
  
  [[SVRMathString mathStringWithString:@"(5m((10a3)m10a2)e2)="]
                     __testAssertEqual:@"(5*((10+3)*10+2)^2)=87120\n"];
  
  [[SVRMathString mathStringWithString:@"(10a2)a(8s7)m5="]
                     __testAssertEqual:@"(10+2)+(8-7)*5=17\n"];
  
  [[SVRMathString mathStringWithString:@"12a1m5="]
                     __testAssertEqual:@"12+1*5=17\n"];

  [[SVRMathString mathStringWithString:@"1111a(222)a1111="]
                     __testAssertEqual:@"1111+(222)+1111=2444\n"];
  
  [[SVRMathString mathStringWithString:@"5="]
                     __testAssertEqual:@"5=5\n"];
  
  [[SVRMathString mathStringWithString:@"2.0a2.0="]
                     __testAssertEqual:@"2.0+2.0=4\n"];
  
  [[SVRMathString mathStringWithString:@"-2.0a-2.0="]
                     __testAssertEqual:@"-2.0+-2.0=-4\n"];
  
  [[SVRMathString mathStringWithString:@"5m5="]
                     __testAssertEqual:@"5*5=25\n"];
  
  [[SVRMathString mathStringWithString:@"5m5=s5="]
                     __testAssertEqual:@"5*5=25\n25-5=20\n"];
  
  [[SVRMathString mathStringWithString:@"5m5=5s5="]
                     __testAssertEqual:@"5*5=25\n5-5=0\n"];
  
  [[SVRMathString mathStringWithString:@"10d2="]
                     __testAssertEqual:@"10/2=5\n"];
  
  [[SVRMathString mathStringWithString:@"(10a2)m5="]
                     __testAssertEqual:@"(10+2)*5=60\n"];
  
  [[SVRMathString mathStringWithString:@"8e8="]
                     __testAssertEqual:@"8^8=16777216\n"];
  
  [[SVRMathString mathStringWithString:@"2e-2="]
                     __testAssertEqual:@"2^-2=0.25\n"];
  
  [[SVRMathString mathStringWithString:@"1m2=3e4=5d6=7s8=9a10=(11a12)=((13a14))="]
                     __testAssertEqual:@"1*2=2\n3^4=81\n5/6=0.83333333333333333333333333333333333333\n7-8=-1\n9+10=19\n(11+12)=23\n((13+14))=27\n"];
  
}

-(void)__testAssertEqual:(NSString*)rhs;
{
  NSString *lhs = [[self render] string];
  NSString *message = [NSString stringWithFormat:@"SVRMathStringTest: FAIL: %@ != %@", lhs, rhs];
  NSAssert([lhs isEqualToString:rhs], message);
  [[NSString stringWithFormat:@"SVRMathStringTest: PASS: %@", lhs] SVR_debugLOG];
}

@end

// MARK: Logging
@implementation NSString (SVRLog)
/// Replaces newlines from logged strings with \n
-(void)SVR_debugLOG;
{
  NSMutableString *output = [[NSMutableString new] autorelease];
  NSArray *components = [self componentsSeparatedByString:@"\n"];
  NSEnumerator *e = [components objectEnumerator];
  NSString *current = [e nextObject];
  NSString *next;
  while (current) {
    [output appendString:current];
    next = [e nextObject];
    if (next) {
      [output appendString:@"\\n"];
    }
    current = next;
  }
  NSLog(@"%@", output);
}
@end
