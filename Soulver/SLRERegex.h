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

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"
#import "slre.h"

@class SLRERegexMatch;

typedef enum {
  /// Default regex advance mode. Once a match is found,
  /// it advances the search to after that match.
  SLRERegexAdvanceAfterMatch,
  /// This advances the next search to after the last capture group.
  SLRERegexAdvanceAfterGroup,
  /// This advances one character at a time.
  /// Note that this can cause many repeated matches.
  SLRERegexAdvanceAfterChar,
} SLRERegexAdvanceMode;

@interface SLRERegex: NSEnumerator
{
  mm_copy NSString *_pattern;
  mm_copy NSString *_string;
  
  SLRERegexAdvanceMode _mode;
  int _bufferIndex;
  int _bufferLength;
  struct slre _engine;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string
            pattern:(NSString*)pattern
               mode:(SLRERegexAdvanceMode)mode;

+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern
                mode:(SLRERegexAdvanceMode)mode;

// MARK: Core Functionality
-(BOOL)containsMatch;

// MARK: NSEnumerator
-(SLRERegexMatch*)nextObject;

// MARK: Convenience Properties
-(NSString*)string;
-(NSString*)pattern;
-(NSString*)description;

@end

@interface SLRERegexMatch: NSObject
{
  mm_retain NSArray *_groupRanges;
  NSRange _range;
}

// MARK: Properties
-(NSRange)range;
-(NSArray*)groupRanges;

// MARK: Init
-(id)initWithRange:(NSRange)matchRange
       groupRanges:(NSArray*)groupRanges;
+(id)matchWithRange:(NSRange)matchRange
        groupRanges:(NSArray*)groupRanges;

// MARK: Convenient Methods
-(NSRange)groupRangeAtIndex:(XPUInteger)index;

@end
