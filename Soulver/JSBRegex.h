//
//  JSBRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import <Foundation/Foundation.h>
#import "re.h"

@interface JSBRegex: NSEnumerator
{
  NSString *_pattern;
  NSString *_string;
  NSRange _last;
  const char *_cursor;
  re_t _rx;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;

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
-(NSString*)description;

@end

@interface JSBRegex (Tests)
+(void)executeTests;
+(void)__executeTests_ranges;
+(void)__executeTests_values;
@end
