//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "TestsUnit.h"

void TestsUnitExecute(void)
{
#if TESTING==1
  [XPLog executeTests];
  [XPRegularExpression executeTests];
  [MATHSolverScanner executeTests];
#ifdef MAC_OS_X_VERSION_10_4
  // TODO: Change to Antifeature flat
//[NSBezierPath saveTestFiles];
  [NSBezierPath executeTests];
#endif
#endif
}

#if TESTING
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
  XPLogAssrt (YES, @"XPLogAssrt");
  XPLogAssrt1(YES, @"XPLogAssrt1: %d", 1);
  XPLogAssrt2(YES, @"XPLogAssrt2: %d, %d", 1, 2);
  XPLogAssrt3(YES, @"XPLogAssrt3: %d, %d, %d", 1, 2, 3);
  XPLogAssrt4(YES, @"XPLogAssrt4: %d, %d, %d, %d", 1, 2, 3, 4);
  /*
  XPLogRaise(@"XPLogRaise");
  XPLogRaise1(@"XPLogRaise1: %d", 1);
  XPLogRaise2(@"XPLogRaise2: %d, %d", 1, 2);
  XPLogRaise3(@"XPLogRaise3: %d, %d, %d", 1, 2, 3);
  XPLogRaise4(@"XPLogRaise4: %d, %d, %d, %d", 1, 2, 3, 4);
  */
  XPLogAlwys (@"TestsUnit-XPLog: Pass");
}

@end

@implementation XPRegularExpression (TestsUnit)

+(void)executeTests;
{
  XPRegularExpression *regex = nil;
  NSArray *matches = nil;
  XPTextCheckingResult *match;
  NSString *string = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // MARK: MATH_regexForNumbers
  string = @"this isA1,B2,C3,D1.1,E2.2,F3.3,g10.10,h20.20JI30.30,O-1, -2, -3,M-1.1, -2.2, -3.3, -10.10, -20.20, -30.30END";
  regex = [XPRegularExpression MATH_regexForNumbers];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(3, [string length] - 3)];
  XPTestInt([matches count], 18);
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"1");
  match = [matches objectAtIndex:1];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"2");
  match = [matches objectAtIndex:2];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"3");
  match = [matches objectAtIndex:3];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"1.1");
  match = [matches objectAtIndex:4];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"2.2");
  match = [matches objectAtIndex:5];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"3.3");
  match = [matches objectAtIndex:6];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"10.10");
  match = [matches objectAtIndex:7];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"20.20");
  match = [matches objectAtIndex:8];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"30.30");
  match = [matches objectAtIndex:9];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-1");
  match = [matches objectAtIndex:10];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-2");
  match = [matches objectAtIndex:11];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-3");
  match = [matches objectAtIndex:12];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-1.1");
  match = [matches objectAtIndex:13];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-2.2");
  match = [matches objectAtIndex:14];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-3.3");
  match = [matches objectAtIndex:15];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-10.10");
  match = [matches objectAtIndex:16];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-20.20");
  match = [matches objectAtIndex:17];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-30.30");
  
  // MARK: MATH_regexForOperators - MegaSimple
  string = @"a2+2=";
  regex = [XPRegularExpression MATH_regexForOperators];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(1, [string length]-2)];
  XPTestInt([matches count], 1);
  match = [matches objectAtIndex:0];
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"+");
  
  // MARK: MATH_regexForOperators
  string = @"___15+15 and 40-400 and 6.3*6.0 and 7/07 and 8^8 and 9R9 and 9r9 and 10l10 and 10L100_______";
  regex = [XPRegularExpression MATH_regexForOperators];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(3, [string length]-6)];
  XPTestInt([matches count], 7);
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"+");
  match = [matches objectAtIndex:1];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-");
  match = [matches objectAtIndex:2];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"*");
  match = [matches objectAtIndex:3];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"/");
  match = [matches objectAtIndex:4];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"^");
  match = [matches objectAtIndex:5];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"R");
  match = [matches objectAtIndex:6];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"L");
  
  // MARK: MATH_regexForExpressions - MegaSimple
  string = @"2+2=";
  regex = [XPRegularExpression MATH_regexForExpressions];
  matches = [regex matchesInString:string];
  XPTestInt([matches count], 1);
  match = [matches objectAtIndex:0];
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"2+2=");
  
  // MARK: MATH_regexForExpressions
  string = @"abc12.32+333RL()222=OR7r7=OR8l8=AND7*7.3-66+22*(((45-67)=2+2-3*8/7(0.123--30.0)+7=PPPPPPP";
  regex = [XPRegularExpression MATH_regexForExpressions];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(2, [string length]-4)];
  XPTestInt([matches count], 5);
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"12.32+333RL()222=");
  match = [matches objectAtIndex:1];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"7=");
  match = [matches objectAtIndex:2];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"8=");
  match = [matches objectAtIndex:3];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"7*7.3-66+22*(((45-67)=");
  match = [matches objectAtIndex:4];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"2+2-3*8/7(0.123--30.0)+7=");
  
  // MARK: MATH_regexForBrackets
  regex = [XPRegularExpression MATH_regexForBrackets];
  matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
  XPTestInt([matches count], 8);
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 14,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"(");
  match = [matches objectAtIndex:1];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 15,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @")");
  match = [matches objectAtIndex:2];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 47,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"(");
  match = [matches objectAtIndex:3];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 48,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"(");
  match = [matches objectAtIndex:4];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 49,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"(");
  match = [matches objectAtIndex:5];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 55,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @")");
  match = [matches objectAtIndex:6];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 66,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"(");
  match = [matches objectAtIndex:7];
  XPTestInt([match numberOfRanges], 1);
  XPTestRange([match rangeAtIndex:0], 78,1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @")");
  
  // MARK: Legacy SLRE Operator Finding Tests
  regex = [XPRegularExpression MATH_regexForOperators];
  string = @"and (1+2)^(6*7)-3*4*(7) and 9-(4) and";
  matches = [regex matchesInString:string];
  XPTestInt([matches count], 7);
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"+");
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"+");
  match = [matches objectAtIndex:1];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"^");
  match = [matches objectAtIndex:2];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"*");
  match = [matches objectAtIndex:3];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-");
  match = [matches objectAtIndex:4];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"*");
  match = [matches objectAtIndex:5];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"*");
  match = [matches objectAtIndex:6];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-");
  
  // MARK: Legacy SLRE Number Finding Tests
  regex = [XPRegularExpression MATH_regexForNumbers];
  string = @"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888) and -9-(400) and";
  matches = [regex matchesInString:string];
  XPTestInt([matches count], 10);
  match = [matches objectAtIndex:0];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-102.34");
  match = [matches objectAtIndex:1];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"243.333");
  match = [matches objectAtIndex:2];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"666");
  match = [matches objectAtIndex:3];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-700");
  match = [matches objectAtIndex:4];
  XPTestInt([match numberOfRanges], 1);
  // Known issue where negative number is detected
  // even though its next to bracket (meaning its a minus operator)
  // this is corrected in -[MATHSolverScanner populateNumbers:]
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-33.44");
  match = [matches objectAtIndex:5];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-4.444");
  match = [matches objectAtIndex:6];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"7");
  match = [matches objectAtIndex:7];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"888");
  match = [matches objectAtIndex:8];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"-9");
  match = [matches objectAtIndex:9];
  XPTestInt([match numberOfRanges], 1);
  XPTestString([string substringWithRange:[match rangeAtIndex:0]], @"400");
  
  NSLog(@"%@ Unit Tests: PASSED", self);
}

@end

@implementation MATHSolverScanner (TestsUnit)

+(void)executeTests;
{
  NSString *string = @"/*This is a basic formula */\n"
                     @"(1.1+2.2))-3.3*4.4/5.5^2=\n"
                     @"/* This is all negative numbers */\n"
                     @"-1.1+-2.2-(-3.3*-4.4)/-5.5^-2=\n"
                     @"10l1000=\n" // purposefully wrong operators
                     @"2r64=\n"    // purposefully wrong operators
                     @"10L1000=\n"
                     @"(2R64)=\n";
  MATHSolverScanner *scanner = [MATHSolverScanner scannerWithString:string];
  NSArray *ranges = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  ranges = [[[scanner numberRanges] allObjects] sortedArrayUsingSelector:@selector(TEST_compare:)];
  XPTestInt([ranges count], 18);
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 0] XP_rangeValue]], @"1.1");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 1] XP_rangeValue]], @"2.2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 2] XP_rangeValue]], @"3.3");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 3] XP_rangeValue]], @"4.4");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 4] XP_rangeValue]], @"5.5");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 5] XP_rangeValue]], @"2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 6] XP_rangeValue]], @"-1.1");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 7] XP_rangeValue]], @"-2.2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 8] XP_rangeValue]], @"-3.3");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 9] XP_rangeValue]], @"-4.4");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:10] XP_rangeValue]], @"-5.5");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:11] XP_rangeValue]], @"-2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:12] XP_rangeValue]], @"1000");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:13] XP_rangeValue]], @"64");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:14] XP_rangeValue]], @"10");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:15] XP_rangeValue]], @"1000");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:16] XP_rangeValue]], @"2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:17] XP_rangeValue]], @"64");

  ranges = [[[scanner operatorRanges] allObjects] sortedArrayUsingSelector:@selector(TEST_compare:)];
  XPTestInt([ranges count], 14);
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 0] XP_rangeValue]], @"+");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 1] XP_rangeValue]], @"-");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 2] XP_rangeValue]], @"*");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 3] XP_rangeValue]], @"/");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 4] XP_rangeValue]], @"^");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 5] XP_rangeValue]], @"-"); // These ranges mistakenly catch - symbols for negative numbers
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 6] XP_rangeValue]], @"+"); // ?
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 7] XP_rangeValue]], @"-"); // ?
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 8] XP_rangeValue]], @"-");
  XPTestString([string substringWithRange:[[ranges objectAtIndex: 9] XP_rangeValue]], @"*");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:10] XP_rangeValue]], @"/");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:11] XP_rangeValue]], @"^");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:12] XP_rangeValue]], @"L");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:13] XP_rangeValue]], @"R");
  
  ranges = [[[scanner bracketRanges] allObjects] sortedArrayUsingSelector:@selector(TEST_compare:)];
  XPTestInt([ranges count], 7);
  XPTestRange([[ranges objectAtIndex:0] XP_rangeValue], 29,  1);
  XPTestRange([[ranges objectAtIndex:1] XP_rangeValue], 37,  1);
  XPTestRange([[ranges objectAtIndex:2] XP_rangeValue], 38,  1);
  XPTestRange([[ranges objectAtIndex:3] XP_rangeValue], 100, 1);
  XPTestRange([[ranges objectAtIndex:4] XP_rangeValue], 110, 1);
  XPTestRange([[ranges objectAtIndex:5] XP_rangeValue], 145, 1);
  XPTestRange([[ranges objectAtIndex:6] XP_rangeValue], 150, 1);
  XPTestString([string substringWithRange:[[ranges objectAtIndex:0] XP_rangeValue]], @"(");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:1] XP_rangeValue]], @")");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:2] XP_rangeValue]], @")");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:3] XP_rangeValue]], @"(");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:4] XP_rangeValue]], @")");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:5] XP_rangeValue]], @"(");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:6] XP_rangeValue]], @")");
  
  ranges = [[[scanner expressionRanges] allObjects] sortedArrayUsingSelector:@selector(TEST_compare:)];
  XPTestInt([ranges count], 6);
  XPTestString([string substringWithRange:[[ranges objectAtIndex:0] XP_rangeValue]], @"(1.1+2.2))-3.3*4.4/5.5^2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:1] XP_rangeValue]], @"-1.1+-2.2-(-3.3*-4.4)/-5.5^-2");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:2] XP_rangeValue]], @"1000");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:3] XP_rangeValue]], @"64");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:4] XP_rangeValue]], @"10L1000");
  XPTestString([string substringWithRange:[[ranges objectAtIndex:5] XP_rangeValue]], @"(2R64)");
  
  NSLog(@"%@ Unit Tests: PASSED", self);
}

@end

#ifdef MAC_OS_X_VERSION_10_4

@implementation NSBezierPath (TestsUnit)
+(void)executeTests;
{
  // TODO: Revalidate tests
  #if __MAC_OS_X_VERSION_MAX_ALLOWED >= 120000
  // Prepare variables
  NSData  *dataRHS = nil;
  NSData  *dataLHS = nil;

  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // Compare REAL BezierPath
  dataRHS = [self createTIFFWithSelector:@selector(__REAL_bezierPathWithRoundedRect:xRadius:yRadius:)];
  dataLHS = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestUnitBezierPath-REAL"
                                                                           ofType:@"tiff"]];
  XPTestNotNIL(dataRHS);
  XPTestNotNIL(dataLHS);
  XPTestObject(dataLHS, dataRHS);
  
  // Compare Manual BezierPath
  dataRHS = [self createTIFFWithSelector:@selector(__MANUAL_bezierPathWithRoundedRect:xRadius:yRadius:)];
  dataLHS = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestUnitBezierPath-MANUAL"
                                                                           ofType:@"tiff"]];
  XPTestNotNIL(dataRHS);
  XPTestNotNIL(dataLHS);
  XPTestObject(dataLHS, dataRHS);
  
  NSLog(@"%@ Unit Tests: PASSED", self);
  #else
	NSLog(@"%@ Unit Tests: Skipped due to unsupported system", self);
  #endif
}

+(void)saveTestFiles;
{
  #ifdef MAC_OS_X_VERSION_10_6
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSString *destDir = NSTemporaryDirectory();
	NSString *manualPath = nil;
	
  NSString *realPath = [destDir stringByAppendingPathComponent:@"TestUnitBezierPath-REAL.tiff"];
  [[self createTIFFWithSelector:@selector(__REAL_bezierPathWithRoundedRect:xRadius:yRadius:)] writeToFile:realPath atomically:YES];
	
	manualPath = [destDir stringByAppendingPathComponent:@"TestUnitBezierPath-MANUAL.tiff"];
  [[self createTIFFWithSelector:@selector(__MANUAL_bezierPathWithRoundedRect:xRadius:yRadius:)] writeToFile:manualPath atomically:YES];
	
  [ws selectFile:manualPath inFileViewerRootedAtPath:destDir];
  #else
	XPTestBool(NO);
  #endif
}

+(NSData*)createTIFFWithSelector:(SEL)selector;
{
  NSGraphicsContext *context = nil;
  NSBitmapImageRep *bitmap = nil;
  NSData *tiffData = nil;
  NSRect rect = NSMakeRect(0, 0, 300, 100);
  XPFloat radius = 50;
  NSColor *color = [NSColor colorWithCalibratedRed:40/255.0
                                             green:92/255.0
                                              blue:246/255.0
                                             alpha:1.0];
  // Prepare Path
  NSBezierPath *path = nil;
  if (selector == @selector(__REAL_bezierPathWithRoundedRect:xRadius:yRadius:)) {
    path = [NSBezierPath __REAL_bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
  } else if (selector == @selector(__MANUAL_bezierPathWithRoundedRect:xRadius:yRadius:)) {
    path = [NSBezierPath __MANUAL_bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
  }
  XPTestNotNIL(path);
  
  // Prepare drawing context
  bitmap = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                   pixelsWide:(XPInteger)rect.size.width
                                                   pixelsHigh:(XPInteger)rect.size.height
                                                bitsPerSample:8
                                              samplesPerPixel:4
                                                     hasAlpha:YES
                                                     isPlanar:NO
                                               colorSpaceName:NSCalibratedRGBColorSpace
                                                  bytesPerRow:0
                                                 bitsPerPixel:0] autorelease];
  
  context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
  XPTestNotNIL(bitmap);
  XPTestNotNIL(context);
  
  // Draw
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:context];
  [color setFill];
  [path fill];
  [NSGraphicsContext restoreGraphicsState];
  
  // Get TIFF Data
  tiffData = [bitmap representationUsingType:XPBitmapImageFileTypeTIFF
                                  properties:
                [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber XP_numberWithInteger:NSTIFFCompressionNone], [NSData data], nil]
                                            forKeys:[NSArray arrayWithObjects:NSImageCompressionMethod, NSImageColorSyncProfileData, nil]]
  ];
  XPTestNotNIL(tiffData);
  return tiffData;
}

@end

#endif

@implementation NSValue (TestUnitComparison)
-(NSComparisonResult)TEST_compare:(NSValue*)other;
{
  NSRange lhs = [self  XP_rangeValue];
  NSRange rhs = [other XP_rangeValue];
  if (lhs.location < rhs.location) {
    return NSOrderedAscending;
  } else if (lhs.location > rhs.location) {
    return NSOrderedDescending;
  } else {
    // If locations are the same, compare lengths
    if (lhs.length < rhs.length) {
      return NSOrderedAscending;
    } else if (lhs.length > rhs.length) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }
}
@end

#endif
