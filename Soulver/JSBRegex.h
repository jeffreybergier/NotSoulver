//
//  JSBRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import <Foundation/Foundation.h>
#import "re.h"

@interface JSBRegex: NSObject
{
  NSString *_pattern;
  NSString *_string;
  const char *_cursor;
  re_t _rx;
  // TODO store last range for just in time calculations
  // Check the REGEX pointer to see if its stores it for me
}

-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;
-(NSString*)string;
-(NSString*)description;
-(BOOL)containsMatch;
/// Returns NSNotFound for location when there are no more matches
-(NSRange)nextMatch;

@end

@interface JSBRegex (Tests)
+(void)executeTests;
@end
