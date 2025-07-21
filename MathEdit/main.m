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

#import <AppKit/AppKit.h>
#import "MATHAppDelegate.h"
#import "TestsIntegration.h"
#import "TestsUnit.h"

int main(int argc, const char *argv[]) {
  
  // Warn when build includes features that should not be in release build
#if TESTING==1
  int WARN_TESTING_ENABLED = TESTING;
#endif
#if LOGLEVEL >= LOGLEVELDEBUG
  int WARN_HEAVY_LOGGING_ENABLED = LOGLEVEL;
#endif
  
  // MARK: Boot Sequence
  // 1. Get necessary references
#ifdef AFF_NSApplicationMainRequiresNIB
  NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
#endif
  NSApplication *app = [NSApplication sharedApplication];
  XPCParameterRaise(app);
  
  // 2. Log the environment
  [XPLog logCheckedPoundDefines];
  
  // 3. Execute Unit Tests
  TestsUnitExecute();
  TestsIntegrationExecute();
  
  // 4. Load NSApplication
  [app setDelegate:[MATHAppDelegate sharedDelegate]];
#ifdef AFF_NSApplicationMainRequiresNIB
  [app run];
  [pool release];
  return 0;
#else
  return NSApplicationMain(argc, argv);
#endif
}
