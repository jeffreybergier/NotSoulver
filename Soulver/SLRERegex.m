//
//  SVRLegacyRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import "SLRERegex.h"

@implementation SLRERegex

// MARK: Initialization

-(id)initWithString:(NSString*)string pattern:(NSString*)pattern;
{
  BOOL isCompiled = NO;
  self = [super init];
  _pattern = [pattern copy];
  _string = [string copy];
  _bufferIndex = 0;
  _bufferLength = (int)[string length];
  isCompiled = slre_compile(&_engine, [_pattern XP_UTF8String]);
  NSAssert2(isCompiled, @"%@ Failed to compile pattern: %@", self, pattern);
  return self;
}

+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;
{
  return [[[SLRERegex alloc] initWithString:string pattern:pattern] autorelease];
}

// MARK: Core Functionality
-(BOOL)containsMatch;
{
  BOOL containsMatch = NO;
  const char* buffer = [_string XP_UTF8String];
  containsMatch = slre_match(&_engine,
                             buffer + _bufferIndex,
                             _bufferLength - _bufferIndex,
                             NULL);
  return containsMatch;
}

-(NSRange)nextMatch;
{
  NSRange output = XPNotFoundRange;
  BOOL containsMatch = NO;
  const char* buffer = [_string XP_UTF8String];
  struct cap capture;
  
  containsMatch = slre_match(&_engine,
                             buffer + _bufferIndex,
                             _bufferLength - _bufferIndex,
                             &capture);
  
  if (!containsMatch) { return output; }
  
  output.location = (XPUInteger)(capture.ptr - buffer);
  output.length = (XPUInteger)capture.len;
  _bufferIndex = (int)NSMaxRange(output);
    
  return output;
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
  if (XPIsNotFoundRange(range)) {
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

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@`%@`->`%@`",
          [super description], _pattern, _string];
}

// MARK: Dealloc
-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_pattern release];
  [_string  release];
  _pattern = nil;
  _string  = nil;
  [super dealloc];
}

@end

@implementation SLRERegex (Tests)

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
  SLRERegex *regex;
  
  // MARK: Test basic string matching
  regex = [SLRERegex regexWithString:@"this is a verb for other cool verbs" pattern:@"verb"];
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
  regex = [SLRERegex regexWithString:@"12.34a5678m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+"];
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
  regex = [SLRERegex regexWithString:@"12.34a5678m999m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+[ma]-?\\d+\\.?\\d+"];
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
  regex = [SLRERegex regexWithString:@"12.m56...78m--90.12" pattern:@"-?\\d+\\.?\\d+m-?\\d+\\.?\\d+"];
  NSAssert(![regex containsMatch], @"");
  
  // MARK: Test Multiple Operators
  regex = [SLRERegex regexWithString:@"5+7+3" pattern:@"[\\*\\-\\+\\/\\^]"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 1, @"");
  NSAssert(range.length == 1, @"");
  range = [regex nextMatch];
  NSAssert(range.location == 3, @"");
  NSAssert(range.length == 1, @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  
  // MARK: Test finding exponent
  regex = [SLRERegex regexWithString:@"3*5^2+7" pattern:@"\\d\\^\\d"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
  regex = [SLRERegex regexWithString:@"3*5/2+7" pattern:@"\\d\\^\\d"];
  NSAssert(![regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == NSNotFound, @"");
  NSAssert(range.length == 0, @"");
  regex = [SLRERegex regexWithString:@"3*5^2" pattern:@"[\\^\\*]"];
  NSAssert([regex containsMatch], @"");
  range = [regex nextMatch];
  NSAssert(range.location == 1, @"");
  NSAssert(range.length == 1, @"");
  range = [regex nextMatch];
  NSAssert(range.location == 3, @"");
  NSAssert(range.length == 1, @"");
}

+(void)__executeTests_values;
{
  NSRange range = XPNotFoundRange;
  NSValue *value = nil;
  SLRERegex *regex = nil;
  
  // MARK: Test basic string matching
  regex = [SLRERegex regexWithString:@"this is a verb for other cool verbs" pattern:@"verb"];
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
  regex = [SLRERegex regexWithString:@"12.34a5678m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+"];
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
  regex = [SLRERegex regexWithString:@"12.34a5678m999m-90.12s-3456" pattern:@"-?\\d+\\.?\\d+[ma]-?\\d+\\.?\\d+"];
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
  regex = [SLRERegex regexWithString:@"12.m56...78m--90.12" pattern:@"-?\\d+\\.?\\d+m-?\\d+\\.?\\d+"];
  NSAssert(![regex containsMatch], @"");
  
  // MARK: Test finding exponent
  regex = [SLRERegex regexWithString:@"3*5^2+7" pattern:@"\\d\\^\\d"];
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 2, @"");
  NSAssert(range.length == 3, @"");
  regex = [SLRERegex regexWithString:@"3*5/2+7" pattern:@"\\d\\^\\d"];
  NSAssert(![regex containsMatch], @"");
  value = [regex nextObject];
  NSAssert(!value, @"");
  regex = [SLRERegex regexWithString:@"3*5^2" pattern:@"[\\^\\*]"];
  NSAssert([regex containsMatch], @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 1, @"");
  NSAssert(range.length == 1, @"");
  value = [regex nextObject];
  [value getValue:&range];
  NSAssert(range.location == 3, @"");
  NSAssert(range.length == 1, @"");
}

@end
