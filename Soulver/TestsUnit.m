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
  NSArray *matches = nil;
  XPTextCheckingResult *result;
  NSString *string = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // MARK: SVR_regexForNumbers
  string = @"this isA1,B2,C3,D1.1,E2.2,F3.3,g10.10,h20.20JI30.30,O-1, -2, -3,M-1.1, -2.2, -3.3, -10.10, -20.20, -30.30END";
  regex = [XPRegularExpression SVR_regexForNumbers];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(3, [string length] - 3)];
  XPTestInt([matches count], 18);
  result = [matches objectAtIndex:0];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"1");
  result = [matches objectAtIndex:1];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"2");
  result = [matches objectAtIndex:2];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"3");
  result = [matches objectAtIndex:3];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"1.1");
  result = [matches objectAtIndex:4];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"2.2");
  result = [matches objectAtIndex:5];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"3.3");
  result = [matches objectAtIndex:6];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"10.10");
  result = [matches objectAtIndex:7];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"20.20");
  result = [matches objectAtIndex:8];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"30.30");
  result = [matches objectAtIndex:9];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-1");
  result = [matches objectAtIndex:10];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-2");
  result = [matches objectAtIndex:11];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-3");
  result = [matches objectAtIndex:12];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-1.1");
  result = [matches objectAtIndex:13];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-2.2");
  result = [matches objectAtIndex:14];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-3.3");
  result = [matches objectAtIndex:15];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-10.10");
  result = [matches objectAtIndex:16];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-20.20");
  result = [matches objectAtIndex:17];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-30.30");
  
  // MARK: SVR_regexForOperators - MegaSimple
  string = @"a2+2=";
  regex = [XPRegularExpression SVR_regexForOperators];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(1, [string length]-2)];
  XPTestInt([matches count], 1);
  result = [matches objectAtIndex:0];
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"+2");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"+");
  
  // MARK: SVR_regexForOperators
  // TODO: Make more robust to handle 6.3*-6.0
  string = @"___15+15 and 40-400 and 6.3*6.0 and 7/07 and 8^8 and 9R9 and 9r9 and 10l10 and 10L100_______";
  regex = [XPRegularExpression SVR_regexForOperators];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(3, [string length]-6)];
  XPTestInt([matches count], 7);
  result = [matches objectAtIndex:0];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"+1");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"+");
  result = [matches objectAtIndex:1];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"-4");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"-");
  result = [matches objectAtIndex:2];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"*6");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"*");
  result = [matches objectAtIndex:3];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"/0");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"/");
  result = [matches objectAtIndex:4];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"^8");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"^");
  result = [matches objectAtIndex:5];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"R9");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"R");
  result = [matches objectAtIndex:6];
  XPTestInt([result numberOfRanges], 2);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"L1");
  XPTestString([string substringWithRange:[result rangeAtIndex:1]], @"L");
  
  // MARK: SVR_regexForExpressions - MegaSimple
  string = @"2+2=";
  regex = [XPRegularExpression SVR_regexForExpressions];
  matches = [regex matchesInString:string];
  XPTestInt([matches count], 1);
  result = [matches objectAtIndex:0];
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"2+2=");
  
  // MARK: SVR_regexForExpressions
  string = @"abc12.32+333RL()222=OR7r7=OR8l8=AND7*7.3-66+22*(((45-67)=2+2-3*8/7(0.123--30.0)+7=PPPPPPP";
  regex = [XPRegularExpression SVR_regexForExpressions];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(2, [string length]-4)];
  XPTestInt([matches count], 5);
  result = [matches objectAtIndex:0];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"12.32+333RL()222=");
  result = [matches objectAtIndex:1];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"7=");
  result = [matches objectAtIndex:2];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"8=");
  result = [matches objectAtIndex:3];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"7*7.3-66+22*(((45-67)=");
  result = [matches objectAtIndex:4];
  XPTestInt([result numberOfRanges], 1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"2+2-3*8/7(0.123--30.0)+7=");
  
  // MARK: SVR_regexForBrackets
  regex = [XPRegularExpression SVR_regexForBrackets];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
  XPTestInt([matches count], 8);
  result = [matches objectAtIndex:0];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 14,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"(");
  result = [matches objectAtIndex:1];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 15,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @")");
  result = [matches objectAtIndex:2];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 47,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"(");
  result = [matches objectAtIndex:3];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 48,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"(");
  result = [matches objectAtIndex:4];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 49,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"(");
  result = [matches objectAtIndex:5];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 55,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @")");
  result = [matches objectAtIndex:6];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 66,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @"(");
  result = [matches objectAtIndex:7];
  XPTestInt([result numberOfRanges], 1);
  XPTestRange([result rangeAtIndex:0], 78,1);
  XPTestString([string substringWithRange:[result rangeAtIndex:0]], @")");

  NSLog(@"%@ Unit Tests: PASSED", self);
}

@end

