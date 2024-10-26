//
//  SVRLegacyRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
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

@interface SLRERegex (Tests)
+(void)executeTests;
@end
