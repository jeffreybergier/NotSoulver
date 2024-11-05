#import <AppKit/AppKit.h>
#import "NSUserDefaults+Soulver.h"
#import "XPCrossPlatform.h"
#import "SVRSolver.h"
#import "SLRERegex.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
int main(int argc, const char *argv[]) {
#pragma clang diagnostic pop
  
  // MARK: Boot Sequence
  // And document support CFLAGS
  
  // 1. Create temporary autorelease pool before NSApplication loads
  NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
  
  // 2. Execute Unit Tests if Needed
#ifdef TESTING
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  [XPLog alwys:@"<Main> Unit Tests: STARTING"];
  [XPLog executeUnitTests];
  [CrossPlatform executeUnitTests];
  [SVRSolver executeTests];
  [SLRERegex executeTests];
  [XPLog alwys:@"<Main> Unit Tests: PASSED"];
#else
  [XPLog alwys:@"<Main> Unit Tests: SKIPPED"];
#endif
  
  // 3. Release pool
  [pool release];
  pool = nil;
  
  // 4. Load NSApplication
#ifdef __MAC_10_0
  return 0;
#else
  return NSApplicationMain(argc, argv);
#endif
}
