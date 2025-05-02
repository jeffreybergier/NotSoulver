//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
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

#import <AppKit/AppKit.h>
#import "NSUserDefaults+Soulver.h"
#import "TestsIntegration.h"
#import "TestsUnit.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
int main(int argc, const char *argv[]) {
#pragma clang diagnostic pop
    
  // MARK: Boot Sequence
  // 1. Warn when build includes features that should not be in release build
#if TESTING==1
  int WARN_TESTING_ENABLED = TESTING;
#endif
#if LOGLEVEL >= LOGLEVELDEBUG
  int WARN_HEAVY_LOGGING_ENABLED = LOGLEVEL;
#endif
  
  // 2. Log the environment
  [XPLog logCheckedPoundDefines];
  
  // 3. Execute Unit Tests
  TestsUnitExecute();
  TestsIntegrationExecute();
  
  // 4. Load NSApplication
#ifdef MAC_OS_X_VERSION_10_8
  XPLogAlwys(@"<Main> Exiting due to unsupported system");
  return 0;
#else
  return NSApplicationMain(argc, argv);
#endif
}
