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
  NSRange _last;
  const char *_cursor;
  re_t _rx;
}

-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;
-(NSString*)string;
-(NSString*)pattern;
-(NSRange)lastMatch;
-(BOOL)containsMatch;
/// Returns NSNotFound for location when there are no more matches
-(NSRange)nextMatch;
-(NSString*)description;

@end

@interface JSBRegex (Tests)
+(void)executeTests;
@end
