//
//  JSBRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import <Foundation/Foundation.h>
#import <regex.h>

@interface JSBRegex: NSObject
{
  NSString *_pattern;
  NSString *_string;
  const char *_cString;
  struct regex *_rx;
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
