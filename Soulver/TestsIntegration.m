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
   2) [ ] Move the copyUnsolved and copySolved to the model controller
   3) [ ] Make the 4 versions of the file and bundle them
   4) [ ] Do the comparisons in the method below
   */

  
  SVRDocumentModelController *controller = [[[SVRDocumentModelController alloc] init] autorelease];
  NSData *repDiskLHS     = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-Disk" ofType:@"solv"]];
  NSData *repDisplayLHS  = nil;
  NSData *repSolvedLHS   = nil;
  NSData *repUnsolvedLHS = nil;
  NSData *repDiskRHS     = nil;
  NSData *repDisplayRHS  = nil;
  NSData *repSolvedRHS   = nil;
  NSData *repUnsolvedRHS = nil;
    
  NSLog(@"%@ Integration Tests: STARTING", self);
  
  // MARK: Initialization
  XPTestNotNIL(controller);
  XPTestNotNIL(repDiskLHS);
  // XPTestNotNIL(repDisplayLHS);
  // XPTestNotNIL(repSolvedLHS);
  // XPTestNotNIL(repUnsolvedLHS);
  
  // TODO: Come up with styles for tests
  controller->__TESTING_stylesForSolution         = [self stylesForSolution];
  controller->__TESTING_stylesForPreviousSolution = [self stylesForPreviousSolution];
  controller->__TESTING_stylesForError            = [self stylesForError];
  controller->__TESTING_stylesForText             = [self stylesForText];
  [controller loadDataRepresentation:repDiskLHS ofType:SVRDocumentModelRepDisk];
  
  // Load all of the representations
  repDiskRHS     = [controller dataRepresentationOfType:SVRDocumentModelRepDisk];
  repDisplayRHS  = [controller dataRepresentationOfType:SVRDocumentModelRepDisplay];
  repSolvedRHS   = [controller dataRepresentationOfType:SVRDocumentModelRepSolved];
  repUnsolvedRHS = [controller dataRepresentationOfType:SVRDocumentModelRepUnsolved];
  
  XPTestNotNIL(repDiskRHS);
  // XPTestNotNIL(repDisplayRHS);
  // XPTestNotNIL(repSolvedRHS);
  // XPTestNotNIL(repUnsolvedRHS);
  
  // MARK: Compare Representations
  XPTestObject(repDiskLHS,     repDiskRHS);
  // XPTestObject(repDisplayLHS,  repDisplayRHS);
  // XPTestObject(repSolvedLHS,   repSolvedRHS);
  // XPTestObject(repUnsolvedLHS, repUnsolvedRHS);
  
  NSLog(@"%@ Integration Tests: PASSED", self);
}

+(SVRSolverTextAttachmentStyles)stylesForSolution;
{
  NSFont  *toDrawFont   = [NSFont fontWithName:@"Courier" size:12];
  NSColor *toDrawColor  = [NSColor blueColor];
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
  NSColor *toDrawColor  = [NSColor greenColor];
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
  NSColor *toDrawColor  = [NSColor redColor];
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
  NSColor *otherTextColor = [NSColor grayColor];
  NSColor *operandColor   = [NSColor yellowColor];
  NSColor *operatorColor  = [NSColor blueColor];
  NSColor *bracketColor   = [NSColor yellowColor];
  
  return [NSDictionary __SVR_stylesWithMathFont:mathFont
                                   neighborFont:otherTextFont
                                 otherTextColor:otherTextColor
                                   operandColor:operandColor
                                  operatorColor:operatorColor
                                   bracketColor:bracketColor];
}

@end

#endif
