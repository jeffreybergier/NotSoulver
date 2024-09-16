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
  const char *cPattern;
  self = [super init];
  _pattern = [pattern copy];
  _string = [string copy];
  _cString = [_string cString];
  cPattern = [_pattern cString];
  _rx = re_compile(cPattern, /*REG_EXTENDED*/ 1);
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

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ pattern: `%@` string: `%@`",
                                    [super description], _pattern, _string];
}

-(BOOL)containsMatch;
{
  int output;
  struct regex rx = *_rx;
  output = re_match(_cString, &rx);
  return output;
}

-(NSRange)nextMatch;
{
  int output;
  unsigned int location;
  unsigned int length;
  const char *startPosition;

  // Find starting place
  startPosition = (_rx->end == NULL) ? _cString : _rx->end;

  // Perform Regex
  output = re_match(startPosition, _rx);
  if (output == 0) {
    return NSMakeRange(NSNotFound, 0);
  }

  // Calculate NSRange
  location = _rx->start - _cString;
  length   = _rx->end   - _rx->start;
  
  return NSMakeRange(location, length);
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_pattern release];
  [_string release];
  free(_rx);
  _pattern = nil;
  _string = nil;
  _cString = NULL;
  _rx = NULL;
  [super dealloc];
}

@end

@implementation JSBRegex (Tests)

+(void)executeTests;
{
  NSRange range;
  JSBRegex *regex = [JSBRegex regexWithString:@"this is a verb for other cool verbs" pattern:@"verb"];
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
  NSLog(@"DONE");
  regex = [JSBRegex regexWithString:@"543a567m890)" pattern:@"[[:digit:]]{1,}m[[:digit:]]{1,}"];
  range = [regex nextMatch];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"5m-2"], @"");
}

@end
