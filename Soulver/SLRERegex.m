//
//  SVRLegacyRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/16.
//

#import "SLRERegex.h"

@implementation SLRERegex

// MARK: Initialization

-(id)initWithString:(NSString*)string
            pattern:(NSString*)pattern
         groupCount:(int)groupCount;
{
  BOOL isCompiled = NO;
  self = [super init];
  _pattern = [pattern copy];
  _string = [string copy];
  _groupCount = groupCount + 1; // according to documentation in slre.h
  _bufferIndex = 0;
  _bufferLength = (int)[string length];
  isCompiled = slre_compile(&_engine, [_pattern XP_UTF8String]);
  NSAssert2(isCompiled, @"%@ Failed to compile pattern: %@", self, pattern);
  return self;
}

-(id)initWithString:(NSString*)string
            pattern:(NSString*)pattern;
{
  return [self initWithString:string
                      pattern:pattern
                   groupCount:0];
}

+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern
          groupCount:(int)groupCount;
{
  return [[[SLRERegex alloc] initWithString:string
                                    pattern:pattern
                                 groupCount:groupCount] autorelease];
}

+(id)regexWithString:(NSString*)string pattern:(NSString*)pattern;
{
  return [self regexWithString:string
                       pattern:pattern
                    groupCount:0];
}

// MARK: Core Functionality
-(BOOL)containsMatch;
{
  BOOL containsMatch = NO;
  const char* buffer = [_string XP_UTF8String];
  struct cap captures[_groupCount];
  containsMatch = slre_match(&_engine,
                             buffer + _bufferIndex,
                             _bufferLength - _bufferIndex,
                             captures);
  return containsMatch;
}

-(SLRERegexMatch*)nextObject;
{
  NSRange matchRange = XPNotFoundRange;
  NSRange groupRange = XPNotFoundRange;
  NSMutableArray *groupRanges = [[NSMutableArray new] autorelease];
  BOOL containsMatch = NO;
  const char* buffer = [_string XP_UTF8String];
  struct cap captures[_groupCount];
  int idx;
  
  containsMatch = slre_match(&_engine,
                             buffer + _bufferIndex,
                             _bufferLength - _bufferIndex,
                             captures);
  
  if (!containsMatch) { return nil; }
  
  for (idx = 0; idx<_groupCount; idx++) {
    // pull out the full range and update the bufferIndex for next iteration
    if (idx == 0) {
      matchRange.location = (XPUInteger)(captures[idx].ptr - buffer);
      matchRange.length = (XPUInteger)captures[idx].len;
      NSLog(@"%@",[_string SVR_descriptionHighlightingRange:matchRange]);
      _bufferIndex = (int)NSMaxRange(matchRange);
    } else {
      groupRange.location = (XPUInteger)(captures[idx].ptr - buffer);
      groupRange.length = (XPUInteger)captures[idx].len;
      NSLog(@"%@",[_string SVR_descriptionHighlightingRange:groupRange]);
      [groupRanges addObject:[NSValue XP_valueWithRange:groupRange]];
    }
  }
  
  return [SLRERegexMatch matchWithRange:matchRange
                            groupRanges:[[groupRanges copy] autorelease]];
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

@implementation SLRERegexMatch

// MARK: Properties

-(NSRange)range;
{
  return _range;
}
-(NSArray*)groupRanges;
{
  return [[_groupRanges retain] autorelease];
}

// MARK: Init

-(id)initWithRange:(NSRange)matchRange
       groupRanges:(NSArray*)groupRanges;
{
  self = [super init];
  _range = matchRange;
  _groupRanges = [groupRanges retain];
  return self;
}

+(id)matchWithRange:(NSRange)matchRange
        groupRanges:(NSArray*)groupRanges;
{
  return [[[SLRERegexMatch alloc] initWithRange:matchRange
                                    groupRanges:groupRanges] autorelease];
}

// MARK: Convenient Methods
-(NSRange)groupRangeAtIndex:(XPUInteger)index;
{
  return [[[self groupRanges] objectAtIndex:index] XP_rangeValue];
}

- (void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_groupRanges release];
  _groupRanges = nil;
  [super dealloc];
}

@end

@implementation SLRERegex (Tests)

+(void)executeTests;
{
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // MARK: Test Capture Groups
  regex = [SLRERegex regexWithString:@"and 5+5 and 4-4 and 6*6 and 7/6 and 8^8 and"
                             pattern:@"\\d(\\+|\\-|\\/|\\*|\\^)\\d"
                          groupCount:1];
  NSAssert([regex containsMatch], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"5+5"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"+"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"4-4"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"-"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"6*6"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"7/6"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"/"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"8^8"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"^"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  
  NSLog(@"%@ Unit Tests: PASSED", self);
}
  
  /*
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

*/
@end
