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

@interface SLRERegex: NSEnumerator
{
  mm_copy NSString *_pattern;
  mm_copy NSString *_string;
  
  int _groupCount;
  int _bufferIndex;
  int _bufferLength;
  struct slre _engine;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string
            pattern:(NSString*)pattern
         groupCount:(int)groupCount;
-(id)initWithString:(NSString*)string
            pattern:(NSString*)pattern;
+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern
          groupCount:(int)groupCount;
+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern;

// MARK: Core Functionality
-(BOOL)containsMatch;

// MARK: NSEnumerator
// TODO: Change this type to SLRERegexMatch
-(id)nextObject;

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
