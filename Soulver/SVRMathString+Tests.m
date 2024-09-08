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
  // MARK: Test Interactive
  
  SVRMathString *model = [[[SVRMathString alloc] init] autorelease];
  NSNumber *error = nil;
  [model __testAssertEqual:@""];
  // [model appendEncodedString:@"H"];
  // NSAssert([error isEqualToNumber:[NSNumber SVR_errorInvalidCharacter]], @"");
  error = nil;
  [model appendEncodedString:@"5"];
  [model __testAssertEqual:@"5"];
  [model appendEncodedString:[[SVRMathString operatorEncodeMap] objectForKey:@"+"]];
  [model __testAssertEqual:@"5+"];
  [model appendEncodedString:@"5"];
  [model __testAssertEqual:@"5+5"];
  [model appendEncodedString:@"="];
  [model __testAssertEqual:@"5+5=10\n"];
  [model appendEncodedString:@"="];
  [model appendEncodedString:@"="];
  [model __testAssertEqual:@"5+5=10\n"];
  [model appendEncodedString:[[SVRMathString operatorEncodeMap] objectForKey:@"*"]];
  [model __testAssertEqual:@"5+5=10\n10*"];
  [model appendEncodedString:@"9"];
  [model __testAssertEqual:@"5+5=10\n10*9"];
  [model appendEncodedString:@"="];
  [model __testAssertEqual:@"5+5=10\n10*9=90\n"];
  NSAssert(error == nil, @"");
  model = nil;
  
  // MARK: Test Backspace
  model = [[[SVRMathString alloc] initWithString:@"1a2a3=a4a5a6=7a8a9"] autorelease];
  [model __testAssertEqual:@"1+2+3=6\n6+4+5+6=21\n7+8+9"];
  [model backspaceAll];
  [model __testAssertEqual:@""];
  model = [[[SVRMathString alloc] initWithString:@"1a2a3=a4a5a6=7a8a9"] autorelease];
  [model __testAssertEqual:@"1+2+3=6\n6+4+5+6=21\n7+8+9"];
  [model backspaceCharacter];
  [model backspaceCharacter];
  [model __testAssertEqual:@"1+2+3=6\n6+4+5+6=21\n7+8"];
  [model backspaceLine];
  [model __testAssertEqual:@"1+2+3=6\n6+4+5+6=21\n"];
  [model backspaceLine];
  [model __testAssertEqual:@"1+2+3=6\n"];
  [model backspaceLine];
  [model __testAssertEqual:@""];
  
  // MARK: Test Maps
  
  NSAssert([[[SVRMathString operatorEncodeMap] objectForKey:@"*"] isEqualToString:@"m"], @"FAIL: Encode *");
  NSAssert([[[SVRMathString operatorEncodeMap] objectForKey:@"+"] isEqualToString:@"a"], @"FAIL: Encode +");
  NSAssert([[[SVRMathString operatorEncodeMap] objectForKey:@"-"] isEqualToString:@"s"], @"FAIL: Encode -");
  NSAssert([[[SVRMathString operatorEncodeMap] objectForKey:@"/"] isEqualToString:@"d"], @"FAIL: Encode /");
  NSAssert([[[SVRMathString operatorEncodeMap] objectForKey:@"^"] isEqualToString:@"e"], @"FAIL: Encode ^");
  
  NSAssert([[[SVRMathString operatorDecodeMap] objectForKey:@"m"] isEqualToString:@"*"], @"FAIL: Decode *");
  NSAssert([[[SVRMathString operatorDecodeMap] objectForKey:@"a"] isEqualToString:@"+"], @"FAIL: Decode +");
  NSAssert([[[SVRMathString operatorDecodeMap] objectForKey:@"s"] isEqualToString:@"-"], @"FAIL: Decode -");
  NSAssert([[[SVRMathString operatorDecodeMap] objectForKey:@"d"] isEqualToString:@"/"], @"FAIL: Decode /");
  NSAssert([[[SVRMathString operatorDecodeMap] objectForKey:@"e"] isEqualToString:@"^"], @"FAIL: Decode ^");

  NSAssert([[SVRMathString operatorEncodeMap] count] == 5, @"FAIL: Decode Count");
  NSAssert([[SVRMathString operatorDecodeMap] count] == 5, @"FAIL: Decode Count");
  
  // MARK: Test Errors
  
  [[SVRMathString mathStringWithString:@"5a5a5Xa6a6a6="]
                     __testAssertEqual:@"5+5+5X+6+6+6=\n<Error:-1002> An incompatible character was found"
                           expectError:[NSNumber SVR_errorInvalidCharacter]];
  
  [[SVRMathString mathStringWithString:@"(5m((10a3)m10a2)e2="]
                     __testAssertEqual:@"(5*((10+3)*10+2)^2=\n<Error:-1003> Parentheses were unbalanced"
                           expectError:[NSNumber SVR_errorMismatchedBrackets]];
  
  [[SVRMathString mathStringWithString:@"1m2=s3=aa4=6a7="]
                     __testAssertEqual:@"1*2=\n-3=\n++4=\n6+7=\n<Error:-1004> Operators around the numbers were unbalanced"
                           expectError:[NSNumber SVR_errorMissingNumber]];
  
  [[SVRMathString mathStringWithString:@"5aa="]
                     __testAssertEqual:@"5++=\n<Error:-1004> Operators around the numbers were unbalanced"
                           expectError:[NSNumber SVR_errorMissingNumber]];
  
  [[SVRMathString mathStringWithString:@"aa5="]
                     __testAssertEqual:@"++5=\n<Error:-1004> Operators around the numbers were unbalanced"
                           expectError:[NSNumber SVR_errorMissingNumber]];
  
  [[SVRMathString mathStringWithString:@"a5="]
                     __testAssertEqual:@"+5=\n<Error:-1004> Operators around the numbers were unbalanced"
                           expectError:[NSNumber SVR_errorMissingNumber]];
  
  [[SVRMathString mathStringWithString:@"5a="]
                     __testAssertEqual:@"5+=\n<Error:-1004> Operators around the numbers were unbalanced"
                           expectError:[NSNumber SVR_errorMissingNumber]];
  
  [[SVRMathString mathStringWithString:@"1m2=s3=4a=6a7="]
                     __testAssertEqual:@"1*2=\n-3=\n4+=\n6+7=\n<Error:-1004> Operators around the numbers were unbalanced"
                           expectError:[NSNumber SVR_errorMissingNumber]];
  
  [[SVRMathString mathStringWithString:@"5(10)="]
                     __testAssertEqual:@"5(10)=\n<Error:-1005> Operators around the parentheses were missing"
                           expectError:[NSNumber SVR_errorPatching]];
  
  [[SVRMathString mathStringWithString:@"(10)5="]
                     __testAssertEqual:@"(10)5=\n<Error:-1005> Operators around the parentheses were missing"
                           expectError:[NSNumber SVR_errorPatching]];
  
  // MARK: Test Normal Math
  
  [[SVRMathString mathStringWithString:@"8e8=d8e5="]
   __testAssertEqual:@"8^8=16777216\n16777216/8^5=512\n"];
  
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
  NSString *lhs = nil;
  NSString *message = nil;
  
  lhs = [[self renderWithError:NULL] string];
  message = [NSString stringWithFormat:@"SVRMathStringTest: FAIL: %@ != %@", lhs, rhs];
  NSAssert([lhs isEqualToString:rhs], message);
  
  [[NSString stringWithFormat:@"SVRMathStringTest: PASS: %@", lhs] SVR_debugLOG];
}

-(void)__testAssertEqual:(NSString*)rhs expectError:(NSNumber*)expectedError;
{
  NSNumber *error = nil;
  NSString *lhs = nil;
  NSString *message1 = nil;
  NSString *message2 = nil;

  lhs = [[self renderWithError:&error] string];
  message1 = [NSString stringWithFormat:@"SVRMathStringTest: FAIL: %@ NOT %@", lhs, rhs];
  NSAssert([lhs isEqualToString:rhs], message1);
  message2 = [NSString stringWithFormat:@"SVRMathStringTest: FAIL: %@ NOT %@", expectedError, error];
  NSAssert([error isEqualToNumber:expectedError], message2);
  
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
  [XPLog alwys:@"%@", output];
}
@end
