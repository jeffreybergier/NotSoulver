//
//  JSBRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import "JSBRegex.h"

@implementation JSBRegex

// MARK: Initialization
-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
{
  return [self initWithString:string pattern:pattern forceIteration:NO];
}

-(id)initWithString:(NSString*)string pattern:(NSString*)pattern forceIteration:(BOOL)forceIteration;
{
  self = [super init];
  _forceIteration = forceIteration;
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

+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern forceIteration:(BOOL)forceIteration;
{
  return [[[JSBRegex alloc] initWithString:string pattern:pattern forceIteration:forceIteration] autorelease];
}

// MARK: Core Functionality
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
  int lastLength = _forceIteration ? 1 : _last.length;
  
  // Perform Regex
  location = re_matchp(_rx, _cursor, &length);
  
  // Check for NotFound
  if (location == -1) {
    _last = NSMakeRange(NSNotFound, 0);
    return _last;
  }

  // Calculate the range and update ivar
  _last.location = (_last.location == NSNotFound)
                 ? location
                 : location + _last.location + lastLength;
  _last.length   = length;

  // Update cursor for next iteration
  if (_forceIteration) {
    _cursor += location + 1;
  } else {
    _cursor += location + length;
  }

  return _last;
}

// MARK: NSEnumerator
-(NSArray*)allObjects;
{
  NSLog(@"JSBRegex does not implement -allObjects");
  return nil;
}

-(NSValue*)nextObject;
{
  NSRange range = [self nextMatch];
  if (range.location == NSNotFound) {
    return nil;
  } else {
    return [NSValue valueWithBytes:&range objCType:@encode(NSRange)];
  }
}

// MARK: Convenience Properties
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

-(BOOL)forceIteration;
{
  return _forceIteration;
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ string: `%@` pattern: `%@`",
                                    [super description], _string, _pattern];
}

// MARK: Dealloc
-(void)dealloc;
{
  [_pattern release];
  [_string  release];
  _pattern = nil;
  _string  = nil;
  _cursor  = NULL;
  _rx      = NULL;
  [super dealloc];
}

@end

@implementation JSBRegex (Tests)

+(void)executeTests;
{
  NSLog(@"%@ Unit Tests: STARTING", self);
  [self __executeTests_ranges];
  [self __executeTests_values];
  NSLog(@"%@ Unit Tests: PASSED", self);
}

+(void)__executeTests_ranges;
{
  NSRange range;
  JSBRegex *regex;
  
  // MARK: Test basic string matching
  regex = [JSBRegex regexWithString:@"this is a verb for other cool verbs" pattern:@"verb"];
  NSAssert(regex, @"");
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 10, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"verb"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 30, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"verb"], @"");
  
  // MARK: Test simple numbers
  regex = [JSBRegex regexWithString:@"12.34a5678m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 5, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"12.34"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 6, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"5678"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 11, @"");
  NSAssert(range.length == 6, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"-90.12"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 18, @"");
  NSAssert(range.length == 5, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"-3456"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  NSAssert(range.length == 0, @"");
  
  // MARK: Test expression finding
  regex = [JSBRegex regexWithString:@"12.34a5678m999m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+[ma]-?\\d+\\.?\\d+"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 10, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"12.34a5678"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 11, @"");
  NSAssert(range.length == 10, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"999m-90.12"], @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  NSAssert(range.length == 0, @"");
  
  // MARK: Test expressions with bad numbers
  regex = [JSBRegex regexWithString:@"12.m56...78m--90.12" pattern:@"-?\\d+\\.?\\d+m-?\\d+\\.?\\d+"];
  NSAssert(![regex containsMatch], @"");
  
  // MARK: Test Multiple Operators
  regex = [JSBRegex regexWithString:@"5+7+3" pattern:@"[\\d\\)][\\*\\-\\+\\/\\^][\\-\\d\\(]" forceIteration:YES];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 3, @"");
  range = [regex nextMatch];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  
  // MARK: Test finding exponent
  regex = [JSBRegex regexWithString:@"3*5^2+7" pattern:@"\\d\\^\\d"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
  regex = [JSBRegex regexWithString:@"3*5/2+7" pattern:@"\\d\\^\\d"];
  NSAssert(![regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  NSAssert(range.length == 0, @"");
  regex = [JSBRegex regexWithString:@"3*5^2" pattern:@"\\d[\\^\\*]\\d" forceIteration:YES];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 3, @"");
  range = [regex nextMatch];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
}

+(void)__executeTests_values;
{
  NSRange range;
  NSValue *value;
  JSBRegex *regex;
  
  // MARK: Test basic string matching
  regex = [JSBRegex regexWithString:@"this is a verb for other cool verbs" pattern:@"verb"];
  NSAssert(regex, @"");
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 10, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"verb"], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 30, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"verb"], @"");
  
  // MARK: Test simple numbers
  regex = [JSBRegex regexWithString:@"12.34a5678m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+"];
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 5, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"12.34"], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 6, @"");
  NSAssert(range.length == 4, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"5678"], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 11, @"");
  NSAssert(range.length == 6, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"-90.12"], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 18, @"");
  NSAssert(range.length == 5, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"-3456"], @"");
  value = [regex nextObject];
  NSAssert(!value, @"");
  
  // MARK: Test expression finding
  regex = [JSBRegex regexWithString:@"12.34a5678m999m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+[ma]-?\\d+\\.?\\d+"];
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 10, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"12.34a5678"], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 11, @"");
  NSAssert(range.length == 10, @"");
  NSAssert([[[regex string] substringWithRange:range] isEqualToString:@"999m-90.12"], @"");
  value = [regex nextObject];
  NSAssert(!value, @"");
  
  // MARK: Test expressions with bad numbers
  regex = [JSBRegex regexWithString:@"12.m56...78m--90.12" pattern:@"-?\\d+\\.?\\d+m-?\\d+\\.?\\d+"];
  NSAssert(![regex containsMatch], @"");
  
  // MARK: Test finding exponent
  regex = [JSBRegex regexWithString:@"3*5^2+7" pattern:@"\\d\\^\\d"];
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
  regex = [JSBRegex regexWithString:@"3*5/2+7" pattern:@"\\d\\^\\d"];
  NSAssert(![regex containsMatch], @"");
  value = [regex nextObject];
  NSAssert(!value, @"");
  regex = [JSBRegex regexWithString:@"3*5^2" pattern:@"\\d[\\^\\*]\\d" forceIteration:YES];
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 0, @"");
  NSAssert(range.length == 3, @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
}

@end
