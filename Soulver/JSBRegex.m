//
//  JSBRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import "JSBRegex.h"

@implementation JSBRegex

-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
{
  self = [super init];
  _last = NSMakeRange(NSNotFound, 0);
  _pattern = [pattern copy];
  _string = [string copy];
  _cursor = [_string cString];
  _rx = re_compile([_pattern cString]);
  NSAssert2(_rx != NULL, @"%@ Failed to compile pattern: %@", self, pattern);

  return self;
}

+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;
{
  return [[[JSBRegex alloc] initWithString:string pattern:pattern] autorelease];
}

-(NSString*)string;
{
  return [[_string retain] autorelease];
}

-(NSString*)pattern;
{
  return [[_pattern retain] autorelease];
}

-(NSRange)lastMatch;
{
  return _last;
}

-(BOOL)containsMatch;
{
  int location = NSNotFound;
  int length = 0;
  location = re_matchp(_rx, _cursor, &length);
  return location == -1 ? NO : YES;
}

-(NSRange)nextMatch;
{
  int location = NSNotFound;
  int length = 0;
  
  // Perform Regex
  location = re_matchp(_rx, _cursor, &length);
  if (location == -1) {
    _last = NSMakeRange(NSNotFound, 0);
    return _last;
  }

  // Update _last
  if (_last.location != NSNotFound) {
    _last.location += _last.length + location;
    _last.length = length;
  } else {
    _last.location = location;
    _last.length = length;
  }

  // Update cursor for next iteration
  _cursor += location + length;

  return _last;
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ pattern: `%@` string: `%@`",
                                    [super description], _pattern, _string];
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_pattern release];
  [_string release];
  _pattern = nil;
  _string = nil;
  _cursor = NULL;
  _rx = NULL;
  [super dealloc];
}

@end

@implementation JSBRegex (Tests)

+(void)executeTests;
{
  NSRange range;
  JSBRegex *regex;
  NSLog(@"%@ Unit Tests: STARTING", self);
  /*
  regex = [JSBRegex regexWithString:@"this is a verb for other cool verbs" pattern:@"verb"];
  NSAssert(regex, @"");
  NSLog(@"%@", regex);
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 10, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"verb"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 30, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"verb"], @"");
  */
  regex = [JSBRegex regexWithString:@"12.34a56.78m-90.12)" pattern:@"-?\\d+\\.*\\d+"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 5, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"12.34"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 6, @"");
  NSAssert(range.length == 5, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"56.78"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 12, @"");
  NSAssert(range.length == 6, @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  NSAssert(range.length == 0, @"");
  NSLog(@"%@ Unit Tests: PASSED", self);
}

@end
