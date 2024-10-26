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
         groupCount:(int)groupCount
               mode:(SLRERegexAdvanceMode)mode;
{
  BOOL isCompiled = NO;
  self = [super init];
  _pattern = [pattern copy];
  _string = [string copy];
  _mode = mode;
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
                   groupCount:0
                         mode:SLRERegexAdvanceAfterMatch];
}

+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern
          groupCount:(int)groupCount
                mode:(SLRERegexAdvanceMode)mode;
{
  return [[[SLRERegex alloc] initWithString:string
                                    pattern:pattern
                                 groupCount:groupCount
                                       mode:mode] autorelease];
}

+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern;
{
  return [self regexWithString:string
                       pattern:pattern
                    groupCount:0
                          mode:SLRERegexAdvanceAfterMatch];
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
      [XPLog extra:@"%@ Pattern:`%@` Match[0]:`%@`",
       [super description], _pattern, [_string SVR_descriptionHighlightingRange:matchRange]];
    } else {
      groupRange.location = (XPUInteger)(captures[idx].ptr - buffer);
      groupRange.length = (XPUInteger)captures[idx].len;
      [groupRanges addObject:[NSValue XP_valueWithRange:groupRange]];
      [XPLog extra:@"%@ Pattern:`%@` Group[%d]:`%@`",
       [super description], _pattern, idx, [_string SVR_descriptionHighlightingRange:groupRange]];
    }
  }
  
  switch (_mode) {
    case SLRERegexAdvanceAfterMatch:
      _bufferIndex = (int)NSMaxRange(matchRange);
      break;
    case SLRERegexAdvanceAfterChar:
      _bufferIndex += 1;
      break;
    case SLRERegexAdvanceAfterGroup:
      _bufferIndex = (int)NSMaxRange(groupRange);
      break;
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

// A little unorthodox, but importing this just for testing.
// This ensures I test the patterns that the App Uses
#import "SVRSolverScanner.h"

@implementation SLRERegex (Tests)

+(void)executeTests;
{
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;
  
  NSLog(@"%@ Unit Tests: STARTING", self);
  
  // Super basic operator finding
  regex = [SLRERegex regexWithString:@"and 5+5 and 4-4 and 6*6 and 7/6 and 8^8 and"
                             pattern:@"\\d(\\+|\\-|\\/|\\*|\\^)\\d"
                          groupCount:1
                                mode:SLRERegexAdvanceAfterMatch];
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
  
  // More complete operator finding
  // TODO: For some reason \d is not working in place of digits
  regex = [SLRERegex SVR_regexForOperatorsInString:@"and (1+2)^(6*7)-3*4*(7) and 9-(4) and"];
  NSAssert([regex containsMatch], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"1+2"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"+"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@")^("], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"^"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"6*7"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@")-3"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"-"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"3*4"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"4*("], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"*"], @"");
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"9-("], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"-"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  // Number finding
  regex = [SLRERegex SVR_regexForNumbersInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888) and -9-(400) and"];
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 0, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-102.34"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"243.333"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"666"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-700"], @"");
  match = [regex nextObject];
  // This is a known issue that is adjusted for in -[SVRSolverScanner SVR_regexForNumbersInString:]
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-33.44"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-4.444"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"7"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"888"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-9"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"400"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  
  // Left Bracket Finding
  regex = [SLRERegex SVR_regexForLeftBracketsInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888) and -9-(400) and"];
  match = [regex nextObject];
   NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"(-"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"(6"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"(7"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"(4"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@"("], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  // Right Bracket Finding
  regex = [SLRERegex SVR_regexForRightBracketsInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888)= and -9-(400) and"];
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 1, @"");
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"3)"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"0)"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"8)"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"0)"], @"");
  NSAssert([[[regex string] substringWithRange:[match groupRangeAtIndex:0]] isEqualToString:@")"], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  // Expression Finding
  regex = [SLRERegex SVR_regexForExpressionsInString:@"and (-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888)= and -9-(400)= and"];
  match = [regex nextObject];
  NSAssert([[match groupRanges] count] == 0, @"");
  NSAssert([[[regex string] substringWithRange:[match range]]
            isEqualToString:@"(-102.34+243.333)^(666*-700)-33.44*-4.444*(7...888)="], @"");
  match = [regex nextObject];
  NSAssert([[[regex string] substringWithRange:[match range]] isEqualToString:@"-9-(400)="], @"");
  match = [regex nextObject];
  NSAssert(match == nil, @"");
  
  NSLog(@"%@ Unit Tests: PASSED", self);
}
@end
