#import <AppKit/AppKit.h>
#import "SVRCrossPlatform.h"
#import "SVRMathString+Tests.h"
#import "SVRDocumentViewController+Tests.h"
#import "SVRSolver.h"
#import "SVRLegacyRegex.h"
#import "SVRSolverSolutionTagger.h"
#import "SVRSolverScanner.h"
#import "SVRSolverSolutionInserter.h"
#import "SVRSolverExpressionTagger.h"
#import "SVRSolverStyler.h"

int main(int argc, const char *argv[]) {
  
  // MARK: Boot Sequence
  // And document support CFLAGS
  
  // 0. Create temporary autorelease pool before NSApplication loads
  NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
  
  // 1. Check Basic Logging IFDEFS
  [XPLog alwys:@"ALWYS"];
  [XPLog debug:@"DEBUG"]; // #DEBUG || EXTRA
  [XPLog extra:@"EXTRA"]; // #DEBUG && EXTRA
//[XPLog pause:@"PAUSE"];
//[XPLog error:@"ERROR"];
  
  // 2. Execute Unit Tests if Needed
#ifdef TESTING
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  [XPLog alwys:@"<Main> Unit Tests: STARTING"];
  [SVRSolver executeTests];
  [SVRSolverStyler executeTests];
  [SVRSolverScanner executeTests];
  [SVRSolverSolutionInserter executeTests];
  [SVRSolverSolutionTagger executeTests];
  [SVRSolverExpressionTagger executeTests];
  [SVRLegacyRegex executeTests];
  [SVRMathString executeTests];
  [SVRDocumentViewController executeTests];
  [XPLog alwys:@"<Main> Unit Tests: PASSED"];
#else
  [XPLog alwys:@"<Main> Unit Tests: SKIPPED"];
#endif
  
  // 3. Release pool
  [pool release];
  pool = nil;
  
  // 4. Load NSApplication
#ifdef OS_OPENSTEP
  return NSApplicationMain(argc, argv);
#else
  return 0;
#endif
}
