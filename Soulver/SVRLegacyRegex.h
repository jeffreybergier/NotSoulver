//
//  SVRLegacyRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"
#import "re.h"

@interface SVRLegacyRegex: NSEnumerator
{
  mm_copy NSString *_pattern;
  mm_copy NSString *_string;
  
  NSRange _last;
  BOOL _forceIteration;
  const char *_cursor;
  re_t _rx;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
-(id)initWithString:(NSString*)string pattern:(NSString*)pattern forceIteration:(BOOL)forceIteration;
+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;
+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern forceIteration:(BOOL)forceIteration;

// MARK: Core Functionality
/// Returns NSNotFound for location when there are no more matches
-(BOOL)containsMatch;
-(NSRange)nextMatch;

// MARK: NSEnumerator
-(NSArray*)allObjects;
-(NSValue*)nextObject;

// MARK: Convenience Properties
-(NSString*)string;
-(NSString*)pattern;
-(NSRange)lastMatch;
-(BOOL)forceIteration;
-(NSString*)description;

@end

@interface SVRLegacyRegex (Tests)
+(void)executeTests;
+(void)__executeTests_ranges;
+(void)__executeTests_values;
@end
