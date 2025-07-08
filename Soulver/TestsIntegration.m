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

#import "TestsIntegration.h"
#import "MATHAccessoryWindowsOwner.h"

void TestsIntegrationExecute(void)
{
#if TESTING==1
  // SVRFontManager is configured in applicationWillFinishLaunching
  // However, the RTF implementation calls the sharedFontManager
  // so the configuration is ineffective if tests are run.
  [NSFontManager setFontManagerFactory:[SVRFontManager class]];
  [SVRDocumentModelController executeTests];
//[SVRDocumentModelController saveTestFiles];
#endif
}

#if TESTING==1

@implementation SVRDocumentModelController (TestsIntegration)

+(void)executeTests;
{
  /**
   // MARK: Strategy - There are 4 representations of any given file that
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
   7) [x] As long as RTF files are created on Modern MacOS they now pass on new systems and OpenStep
   */

  
  SVRDocumentModelController *controller = [[[SVRDocumentModelController alloc] init] autorelease];
  NSData *repDiskLHSData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-DiskRep" ofType:@"txt"]];
  NSString *repDiskLHS   = [[[NSString alloc] initWithData:repDiskLHSData encoding:NSUTF8StringEncoding] autorelease];
  NSString *repDiskRHS   = nil;
  NSAttributedString *repDisplayLHS  = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-DisplayRep"  ofType:@"rtf"]] documentAttributes:NULL] autorelease];
  NSAttributedString *repSolvedLHS   = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-SolvedRep"   ofType:@"rtf"]] documentAttributes:NULL] autorelease];
  NSAttributedString *repUnsolvedLHS = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestsIntegration-UnsolvedRep" ofType:@"rtf"]] documentAttributes:NULL] autorelease];
  NSAttributedString *repDisplayRHS  = nil;
  NSAttributedString *repSolvedRHS   = nil;
  NSAttributedString *repUnsolvedRHS = nil;
    
  NSLog(@"%@ Integration Tests: STARTING", self);
  
  XPTestNotNIL(controller);
  XPTestNotNIL(repDiskLHS);
  XPTestNotNIL(repDisplayLHS);
  XPTestNotNIL(repSolvedLHS);
  XPTestNotNIL(repUnsolvedLHS);
  
  // Configure Styles
  controller->__TESTING_stylesForSolution         = [self stylesForSolution];
  controller->__TESTING_stylesForPreviousSolution = [self stylesForPreviousSolution];
  controller->__TESTING_stylesForError            = [self stylesForError];
  controller->__TESTING_stylesForText             = [self stylesForText];
  
  // Configure the controller
  [controller loadDataRepresentation:repDiskLHSData ofType:SVRDocumentModelRepDisk];
  
  // Load all of the representations
  repDiskRHS     = [[[NSString alloc] initWithData:[controller dataRepresentationOfType:SVRDocumentModelRepDisk] encoding:NSUTF8StringEncoding] autorelease];
  repDisplayRHS  = [[[NSAttributedString alloc] initWithRTF:[controller dataRepresentationOfType:SVRDocumentModelRepDisplay ] documentAttributes:NULL] autorelease];
  repSolvedRHS   = [[[NSAttributedString alloc] initWithRTF:[controller dataRepresentationOfType:SVRDocumentModelRepSolved  ] documentAttributes:NULL] autorelease];
  repUnsolvedRHS = [[[NSAttributedString alloc] initWithRTF:[controller dataRepresentationOfType:SVRDocumentModelRepUnsolved] documentAttributes:NULL] autorelease];
  
  XPTestNotNIL(repDiskRHS);
  XPTestNotNIL(repDisplayRHS);
  XPTestNotNIL(repSolvedRHS);
  XPTestNotNIL(repUnsolvedRHS);
  
  // Test On-Disk Versions for breaking changes
  XPTestString(repDiskLHS, repDiskRHS);
  
  // TODO: These tests pass in macOS 15, 10.15, 10.12, 10.2, and OpenStep
  // TODO: Revalidate tests
  // but fail in 10.4 & 10.6, 10.8, 10.10 very strange
  #if !defined(MAC_OS_X_VERSION_10_4) || defined(MAC_OS_X_VERSION_10_12)
  XPTestAttrString(repDisplayLHS, repDisplayRHS);
  XPTestAttrString(repSolvedLHS, repSolvedRHS);
  XPTestAttrString(repUnsolvedLHS, repUnsolvedRHS);
  #endif
  
  // Test Basic Comparison
  XPTestAttrString([[[controller model] copy] autorelease],
                   [[[controller model] copy] autorelease]);
  
  // Test NSArchiving / Unarchiving Comparison
  /* // TODO: Get NSCoding working
  repDisplayLHS = [XPKeyedUnarchiver XP_unarchivedObjectOfClass:[NSAttributedString class] fromData:[XPKeyedArchiver archivedDataWithRootObject:[[[controller model] copy] autorelease]]];
  repDisplayRHS = [XPKeyedUnarchiver XP_unarchivedObjectOfClass:[NSAttributedString class] fromData:[XPKeyedArchiver archivedDataWithRootObject:[[[controller model] copy] autorelease]]];
  XPTestAttrString(repDisplayLHS, repDisplayRHS);
  */
  
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

  [ws selectFile:repDisplayPath inFileViewerRootedAtPath:destDir];
}

+(SVRSolverTextAttachmentStyles)stylesForSolution;
{
  NSFont *font = [NSFont fontWithName:@"Courier" size:12];
  NSColor *foregroundColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
  NSColor *backgroundColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0.7 alpha:1];
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundLegacyBoxStroke;
  return [NSDictionary __SVR_stylesWithFont:font
                            foregroundColor:foregroundColor
                            backgroundColor:backgroundColor
                                   mixColor:[NSColor blackColor]
                                 background:background];
}

+(SVRSolverTextAttachmentStyles)stylesForPreviousSolution;
{
  NSFont *font = [NSFont fontWithName:@"Courier" size:14];
  NSColor *foregroundColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
  NSColor *backgroundColor = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0 alpha:1];
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundLegacyBoxStroke;
  return [NSDictionary __SVR_stylesWithFont:font
                            foregroundColor:foregroundColor
                            backgroundColor:backgroundColor
                                   mixColor:[NSColor blackColor]
                                 background:background];
}
+(SVRSolverTextAttachmentStyles)stylesForError;
{
  NSFont *font = [NSFont fontWithName:@"Helvetica" size:10];
  NSColor *foregroundColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
  NSColor *backgroundColor = [NSColor colorWithCalibratedRed:0.7 green:0 blue:0 alpha:1];
  SVRSolverTextAttachmentBackground background = SVRSolverTextAttachmentBackgroundLegacyBoxStroke;
  return [NSDictionary __SVR_stylesWithFont:font
                            foregroundColor:foregroundColor
                            backgroundColor:backgroundColor
                                   mixColor:[NSColor blackColor]
                                 background:background];
}
+(SVRSolverTextStyles)stylesForText;
{
  NSFont  *mathFont       = [NSFont fontWithName:@"Courier"   size:14];
  NSFont  *otherTextFont  = [NSFont fontWithName:@"Helvetica" size:12];
  NSColor *otherTextColor = [NSColor colorWithCalibratedRed:0.3 green:0.3 blue:0.3 alpha:1];
  NSColor *operandColor   = [NSColor colorWithCalibratedRed:0.7 green:0 blue:0.7 alpha:1];
  NSColor *operatorColor  = [NSColor colorWithCalibratedRed:0 green:0.7 blue:0.7 alpha:1];
  NSColor *previousColor  = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0 alpha:1];
  
  return [NSDictionary __SVR_stylesWithMathFont:mathFont
                                   neighborFont:otherTextFont
                                 otherTextColor:otherTextColor
                                   operandColor:operandColor
                                  operatorColor:operatorColor
                                  previousColor:previousColor];
}

@end

#endif
