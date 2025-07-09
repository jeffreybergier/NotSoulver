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

void TestsUnitExecute(void);

#if TESTING==1

#import "XPCrossPlatform.h"
#import "XPRegularExpression.h"
#import "MATHSolverScanner.h"

@interface XPLog (TestsUnit)
+(void)executeTests;
@end

@interface XPRegularExpression (TestsUnit)
+(void)executeTests;
@end

@interface MATHSolverScanner (TestsUnit)
+(void)executeTests;
@end

#ifdef MAC_OS_X_VERSION_10_4
// TODO: For fundamental Core Graphics reasons, 10.2 and OpenStep
// cannot draw into a context without a window. It would be possible
// to rewrite this test to run after NSApplicationMain
// and create and clean up a window. But it would be a ton of work.
@interface NSBezierPath (TestsUnit)
+(void)executeTests;
+(void)saveTestFiles;
+(NSData*)createTIFFWithSelector:(SEL)selector;
@end
#endif

@interface NSValue (TestUnitComparison)
-(NSComparisonResult)TEST_compare:(NSValue*)other;
@end

#endif


