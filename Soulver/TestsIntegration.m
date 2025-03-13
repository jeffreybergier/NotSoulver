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

#import "TestsIntegration.h"

void TestsIntegrationExecute(void)
{
#if TESTING==1
  NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
  [SVRDocumentModelController executeTests];
//[SVRDocumentModelController saveTestFiles];
  [pool release];
#endif
}

#if TESTING==1

@implementation SVRDocumentModelController (TestsIntegration)

+(void)executeTests;
{
  /**
   TODO: Strategy - There are 4 representations of any given file that
   are managed by SVRDocumentModelController. The testing strategy to is to bundle 4 files
   and then compare the code paths to the bundled version.
   
   1) Disk: The "data" version that is saved on disk - [controller dataRepresentationOfType:@"solv"]
      - This should match the exact version of the data on disk
   2) Display: The "real" version that is shown in the TextView - this version is [controller model]
      - This version has all attributes and all the answers embedded as text attachments
   3) Unsolved: The unsolved version [ViewController copyUnsolved] (needs to be moved to the model controller)
      - This version has all the attributes but it has equals signs rather than answers embedded as text attachments
   4) Solved: The solved version [ViewController copySolved] (this needs to be moved to the model controller)
      - This version has all the attributes but it has equal signs and solutions embedded in the text
   
   ToDo List
   1) [x] Fix NSUserDefaults so that during testing it always uses default settings
   2) [x] Move the copyUnsolved and copySolved to the model controller
   3) [x] Make the 4 versions of the file and bundle them
   4) [x] Do the comparisons in the method below
   5) [x] Remake the files in OpenStep as this test passes on the mac but fails in OpenStep
          Perhaps if they are made in OpenStep, it will pass on both platforms.
   6) [x] Files created in OpenStep are different, so tests pass on OS4.2 but fail on Mac
          Need to convert them to NSAttributedString and then compare. Hopefully that will make it platform agnostic
   7) [ ] Add NSParagraphStyle Left to the attributed string. Remove color profile information from NSColor
          A diff of the NSAttributedString output shows that there is implicit NSParagraphStyle "natural" on modern macOS and Left on OpenStep
          A diff of the NSAttributedString output shows that there is a color profile of "sRGB IEC61966-2.1" on modern macOS and "NSCalibratedRGBColorSpace" on OpenStep
          Or create a custom compare function that analyzes the RGB values but ignores the color space
   */

  
  SVRDocumentModelController *controller = [[[SVRDocumentModelController alloc] init] autorelease];
  NSData *repDiskLHSData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-DiskRep" ofType:@"txt"]];
  NSString *repDiskLHS   = [[NSString alloc] initWithData:repDiskLHSData encoding:NSUTF8StringEncoding];
  NSString *repDiskRHS   = nil;
  NSAttributedString *repDisplayLHS  = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-DisplayRep"  ofType:@"rtf"]] documentAttributes:NULL] autorelease];
  NSAttributedString *repSolvedLHS   = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-SolvedRep"   ofType:@"rtf"]] documentAttributes:NULL] autorelease];
  NSAttributedString *repUnsolvedLHS = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-UnsolvedRep" ofType:@"rtf"]] documentAttributes:NULL] autorelease];
  NSAttributedString *repDisplayRHS  = nil;
  NSAttributedString *repSolvedRHS   = nil;
  NSAttributedString *repUnsolvedRHS = nil;
    
  NSLog(@"%@ Integration Tests: STARTING", self);
  
  // MARK: Initialization
  XPTestNotNIL(controller);
  XPTestNotNIL(repDiskLHS);
  XPTestNotNIL(repDisplayLHS);
  XPTestNotNIL(repSolvedLHS);
  XPTestNotNIL(repUnsolvedLHS);
  
  // TODO: Come up with styles for tests
  controller->__TESTING_stylesForSolution         = [self stylesForSolution];
  controller->__TESTING_stylesForPreviousSolution = [self stylesForPreviousSolution];
  controller->__TESTING_stylesForError            = [self stylesForError];
  controller->__TESTING_stylesForText             = [self stylesForText];
  [controller loadDataRepresentation:repDiskLHSData ofType:SVRDocumentModelRepDisk];
  
  // Load all of the representations
  repDiskRHS     = [[NSString alloc] initWithData:[controller dataRepresentationOfType:SVRDocumentModelRepDisk] encoding:NSUTF8StringEncoding];
  repDisplayRHS  = [[[NSAttributedString alloc] initWithRTF:[controller dataRepresentationOfType:SVRDocumentModelRepDisplay ] documentAttributes:NULL] autorelease];
  repSolvedRHS   = [[[NSAttributedString alloc] initWithRTF:[controller dataRepresentationOfType:SVRDocumentModelRepSolved  ] documentAttributes:NULL] autorelease];
  repUnsolvedRHS = [[[NSAttributedString alloc] initWithRTF:[controller dataRepresentationOfType:SVRDocumentModelRepUnsolved] documentAttributes:NULL] autorelease];
  
  XPTestNotNIL(repDiskRHS);
  XPTestNotNIL(repDisplayRHS);
  XPTestNotNIL(repSolvedRHS);
  XPTestNotNIL(repUnsolvedRHS);
  
  // MARK: Compare Representations
//  XPTestString(repDiskLHS,   repDiskRHS);
//  XPTestBool([repDisplayLHS  TEST_isEqualToAttributedString:repDisplayRHS ]);
//  XPTestBool([repSolvedLHS   TEST_isEqualToAttributedString:repSolvedRHS  ]);
//  XPTestBool([repUnsolvedLHS TEST_isEqualToAttributedString:repUnsolvedRHS]);
  
  XPTestString(repDiskLHS,         repDiskRHS);
  XPTestAttrString(repDisplayLHS,  repDisplayRHS);
  XPTestAttrString(repSolvedLHS,   repSolvedRHS);
  XPTestAttrString(repUnsolvedLHS, repUnsolvedRHS);
  
  NSLog(@"%@ Integration Tests: PASSED", self);
}

+(void)saveTestFiles;
{
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  SVRDocumentModelController *controller = [[[SVRDocumentModelController alloc] init] autorelease];
  NSString *destDir          = NSTemporaryDirectory();
  NSString *repDisplayPath   = [destDir stringByAppendingPathComponent:@"TestsIntegration-DisplayRep.rtf"];
  NSString *repSolvedPath    = [destDir stringByAppendingPathComponent:@"TestsIntegration-SolvedRep.rtf"];
  NSString *repUnsolvedPath  = [destDir stringByAppendingPathComponent:@"TestsIntegration-UnsolvedRep.rtf"];
  NSData *repDisk     = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-DiskRep" ofType:@"txt"]];
  NSData *repDisplay  = nil;
  NSData *repSolved   = nil;
  NSData *repUnsolved = nil;
  
  XPTestNotNIL(controller);
  XPTestNotNIL(repDisk);
  XPTestNotNIL(repDisplayPath);
  XPTestNotNIL(repSolvedPath);
  XPTestNotNIL(repUnsolvedPath);
  
  // TODO: Come up with styles for tests
  controller->__TESTING_stylesForSolution         = [self stylesForSolution];
  controller->__TESTING_stylesForPreviousSolution = [self stylesForPreviousSolution];
  controller->__TESTING_stylesForError            = [self stylesForError];
  controller->__TESTING_stylesForText             = [self stylesForText];
  [controller loadDataRepresentation:repDisk ofType:SVRDocumentModelRepDisk];
  
  // Load all of the representations
  repDisplay  = [controller dataRepresentationOfType:SVRDocumentModelRepDisplay];
  repSolved   = [controller dataRepresentationOfType:SVRDocumentModelRepSolved];
  repUnsolved = [controller dataRepresentationOfType:SVRDocumentModelRepUnsolved];
  
  XPTestNotNIL(repDisplay);
  XPTestNotNIL(repSolved);
  XPTestNotNIL(repUnsolved);
  
  XPTestBool([repDisplay  writeToFile:repDisplayPath  atomically:YES]);
  XPTestBool([repSolved   writeToFile:repSolvedPath   atomically:YES]);
  XPTestBool([repUnsolved writeToFile:repUnsolvedPath atomically:YES]);

  [ws XP_openFile:destDir];
  [ws XP_openFile:repDisplayPath];
  [ws XP_openFile:repSolvedPath];
  [ws XP_openFile:repUnsolvedPath];
}

+(SVRSolverTextAttachmentStyles)stylesForSolution;
{
  NSFont  *toDrawFont   = [NSFont fontWithName:@"Courier" size:12];
  NSColor *toDrawColor  = [NSColor colorWithCalibratedRed:0 green:0 blue:1 alpha:1];
  NSFont  *neighborFont = [NSFont fontWithName:@"Courier" size:12];
  SVRSolverTextAttachmentBorderStyle borderStyle = SVRSolverTextAttachmentBorderStyleRecessedWhite;
  
  return [NSDictionary __SVR_stylesWithToDrawFont:toDrawFont
                                     neighborFont:neighborFont
                                      toDrawColor:toDrawColor
                                      borderStyle:borderStyle];
}
+(SVRSolverTextAttachmentStyles)stylesForPreviousSolution;
{
  NSFont  *toDrawFont   = [NSFont fontWithName:@"Courier" size:8];
  NSColor *toDrawColor  = [NSColor colorWithCalibratedRed:0 green:1 blue:0 alpha:1];
  NSFont  *neighborFont = [NSFont fontWithName:@"Helvetica" size:14];
  SVRSolverTextAttachmentBorderStyle borderStyle = SVRSolverTextAttachmentBorderStyleColored;
  
  return [NSDictionary __SVR_stylesWithToDrawFont:toDrawFont
                                     neighborFont:neighborFont
                                      toDrawColor:toDrawColor
                                      borderStyle:borderStyle];
}
+(SVRSolverTextAttachmentStyles)stylesForError;
{
  NSFont  *toDrawFont   = [NSFont fontWithName:@"Helvetica" size:10];
  NSColor *toDrawColor  = [NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:1];
  NSFont  *neighborFont = [NSFont fontWithName:@"Courier" size:12];
  SVRSolverTextAttachmentBorderStyle borderStyle = SVRSolverTextAttachmentBorderStyleColored;
  
  return [NSDictionary __SVR_stylesWithToDrawFont:toDrawFont
                                     neighborFont:neighborFont
                                      toDrawColor:toDrawColor
                                      borderStyle:borderStyle];
}
+(SVRSolverTextStyles)stylesForText;
{
  NSFont  *mathFont       = [NSFont fontWithName:@"Courier"   size:14];
  NSFont  *otherTextFont  = [NSFont fontWithName:@"Helvetica" size:12];
  NSColor *otherTextColor = [NSColor colorWithCalibratedRed:0.3 green:0.3 blue:0.3 alpha:1];
  NSColor *operandColor   = [NSColor colorWithCalibratedRed:1 green:0 blue:1 alpha:1];
  NSColor *operatorColor  = [NSColor colorWithCalibratedRed:0 green:0 blue:1 alpha:1];
  NSColor *bracketColor   = [NSColor colorWithCalibratedRed:1 green:1 blue:0 alpha:0];
  
  return [NSDictionary __SVR_stylesWithMathFont:mathFont
                                   neighborFont:otherTextFont
                                 otherTextColor:otherTextColor
                                   operandColor:operandColor
                                  operatorColor:operatorColor
                                   bracketColor:bracketColor];
}

@end

@implementation NSAttributedString (TestsIntegration)
-(BOOL)TEST_isEqualToAttributedString:(NSAttributedString*)rhs;
{
  NSDictionary *lhsDict = nil;
  NSDictionary *rhsDict = nil;
  XPUInteger idx = 0;
  
  if (![rhs isKindOfClass:[NSAttributedString class]]) {
    return NO;
  }
  if (![[self string] isEqualToString:[rhs string]]) {
    return NO;
  }
  
  for (idx = 0; idx < [self length]; idx++) {
    lhsDict = [self attributesAtIndex:0 effectiveRange:NULL];
    rhsDict = [rhs attributesAtIndex:0  effectiveRange:NULL];
    if ([lhsDict count] != [rhsDict count]) {
      return NO;
    }
    if (![lhsDict TEST_NSForegroundColorIsEqual:rhsDict]) {
      return NO;
    }
    
  }
  
  return YES;
}

@end

@implementation NSDictionary (TestsIntegration)
-(BOOL)TEST_NSForegroundColorIsEqual:(NSDictionary*)rhsDict;
{
  NSColor *lhs = [self objectForKey:NSForegroundColorAttributeName];
  NSColor *rhs = [rhsDict objectForKey:NSForegroundColorAttributeName];
  if (lhs == nil && rhs == nil) { return YES; }
  return [lhs redComponent]   == [rhs redComponent]
      && [lhs greenComponent] == [rhs greenComponent]
      && [lhs blueComponent]  == [rhs blueComponent];
}

@end

#endif
