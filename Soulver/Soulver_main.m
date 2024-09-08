#import <AppKit/AppKit.h>
#import "SVRCrossPlatform.h"
#import "SVRMathString+Tests.h"
#import "SVRDocumentViewController+Tests.h"

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
  [XPLog alwys:@"TESTS: Starting..."];
  [SVRMathString executeTests];
  [SVRDocumentViewController executeTests];
  [XPLog alwys:@"TESTS: Completed"];
#else
  [XPLog alwys:@"TESTS: Skipped"];
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
