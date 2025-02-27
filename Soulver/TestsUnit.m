//
// MIT License
//
// Copyright (c) 2025 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "TestsUnit.h"
#import "SVRSolverScanner.h"

void TestsUnitExecute(void)
{
  [XPLog executeTests];
  [SLRERegex executeTests];
  [XPRegularExpression executeTests];
}

@implementation XPLog (TestsUnit)

+(void)executeTests;
{
  XPLogAlwys (@"TestsUnit-XPLog: Start");
  XPLogAlwys (@"XPLogAlwys");
  XPLogAlwys1(@"XPLogAlwys1: %d", 1);
  XPLogAlwys2(@"XPLogAlwys2: %d, %d", 1, 2);
  XPLogAlwys3(@"XPLogAlwys3: %d, %d, %d", 1, 2, 3);
  XPLogAlwys4(@"XPLogAlwys4: %d, %d, %d, %d", 1, 2, 3, 4);
  XPLogDebug (@"XPLogDebug");
  XPLogDebug1(@"XPLogDebug1: %d", 1);
  XPLogDebug2(@"XPLogDebug2: %d, %d", 1, 2);
  XPLogDebug3(@"XPLogDebug3: %d, %d, %d", 1, 2, 3);
  XPLogDebug4(@"XPLogDebug4: %d, %d, %d, %d", 1, 2, 3, 4);
  XPLogExtra (@"XPLogExtra");
  XPLogExtra1(@"XPLogExtra1: %d", 1);
  XPLogExtra2(@"XPLogExtra2: %d, %d", 1, 2);
  XPLogExtra3(@"XPLogExtra3: %d, %d, %d", 1, 2, 3);
  XPLogExtra4(@"XPLogExtra4: %d, %d, %d, %d", 1, 2, 3, 4);
  /*
  XPLogPause (@"XPLogPause");
  XPLogPause1(@"XPLogPause1: %d", 1);
  XPLogPause2(@"XPLogPause2: %d, %d", 1, 2);
  XPLogPause3(@"XPLogPause3: %d, %d, %d", 1, 2, 3);
  XPLogPause4(@"XPLogPause4: %d, %d, %d, %d", 1, 2, 3, 4);
  XPLogRaise(@"XPLogRaise");
  XPLogRaise1(@"XPLogRaise1: %d", 1);
  XPLogRaise2(@"XPLogRaise2: %d, %d", 1, 2);
  XPLogRaise3(@"XPLogRaise3: %d, %d, %d", 1, 2, 3);
  XPLogRaise4(@"XPLogRaise4: %d, %d, %d, %d", 1, 2, 3, 4);
  */
  XPLogAlwys (@"TestsUnit-XPLog: Pass");
}

@end

@implementation SLRERegex (TestsUnit)

+(void)executeTests;
{
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // Super basic operator finding
  regex = [SLRERegex regexWithString:@"and 5+5 and 4-4 and 6*6 and 7/6 and 8^8 and"
                             pattern:@"\\d(\\+|\\-|\\/|\\*|\\^)\\d"
                                mode:SLRERegexAdvanceAfterMatch];
  NSAssert([regex containsMatch], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"5+5"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"+"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"4-4"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"-"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"6*6"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"7/6"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"/"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"8^8"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"^"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  // More Square root finding finding
  regex = [SLRERegex SVR_regexForOperatorsInString:@"and 2R64 and"];
  NSAssert([regex containsMatch], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"R6"], @"");
  
  // More complete operator finding
  regex = [SLRERegex SVR_regexForOperatorsInString:@"and (1+2)^(6*7)-3*4*(7) and 9-(4) and"];
  NSAssert([regex containsMatch], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"+2"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"+"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"^("], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"^"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"*7"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-3"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"-"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"*4"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"*("], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-("], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"-"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  // Number finding
  regex = [SLRERegex SVR_regexForNumbersInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888) and -9-(400) and"];
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 0, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-102.34"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"243.333"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"666"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-700"], @"");
  match = [regex nextObject];
  // This is a known issue that is adjusted for in -[SVRSolverScanner SVR_regexForNumbersInString:]
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-33.44"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-4.444"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"7"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"888"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-9"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"400"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  
  // Left Bracket Finding
  regex = [SLRERegex SVR_regexForBracketsInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888) and -9-(400) and"];
  match = [regex nextObject];
   NSAssert([[match groupRanges] count] == 0, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  // Expression Finding
  regex = [SLRERegex SVR_regexForExpressionsInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888)= and -9-(400)= and"];
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 0, @"");
  NSAssert([[[regex string] substringWithRange:[match range]]
            isEqualToString:@"(-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888)="], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-9-(400)="], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  NSLog(@"%@ Unit Tests: PASSED", self);
}
@end

@implementation XPRegularExpression (TestsUnit)

+(void)executeTests;
{
  XPRegularExpression *regex = nil;
  NSString *string = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // Super basic operator finding
  string = @"and 5+5 and 4-4 and 6*6 and 7/6 and 8^8 and";
  regex = [XPRegularExpression regularExpressionWithPattern:@"\\d(\\+|\\-|\\/|\\*|\\^)\\d" options:0 error:NULL];
  NSAssert([regex matchesInString:string options:0 range:NSMakeRange(0, [string length])], @"");
}

@end

