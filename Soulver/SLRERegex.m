//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "SLRERegex.h"

@implementation SLRERegex

// MARK: Initialization

-(id)initWithString:(NSString*)string
            pattern:(NSString*)pattern
               mode:(SLRERegexAdvanceMode)mode;
{
  BOOL isCompiled = NO;
  self = [super init];
  _pattern = [pattern copy];
  _string = [string copy];
  _mode = mode;
  _bufferIndex = 0;
  _bufferLength = (int)[string length];
  isCompiled = slre_compile(&_engine, [_pattern XP_UTF8String]);
  NSAssert2(isCompiled, @"%@ Failed to compile pattern: %@", self, pattern);
  return self;
}

+(id)regexWithString:(NSString*)string
             pattern:(NSString*)pattern
                mode:(SLRERegexAdvanceMode)mode;
{
  return [[[SLRERegex alloc] initWithString:string
                                    pattern:pattern
                                       mode:mode] autorelease];
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

-(SLRERegexMatch*)nextObject;
{
  NSRange matchRange = XPNotFoundRange;
  NSRange groupRange = XPNotFoundRange;
  NSMutableArray *groupRanges = [[NSMutableArray new] autorelease];
  BOOL containsMatch = NO;
  const char* buffer = [_string XP_UTF8String];
  int captureCount = _engine.num_caps + 1; // according to documentation in slre.h
  struct cap captures[captureCount];
  int idx;
  
  containsMatch = slre_match(&_engine,
                             buffer + _bufferIndex,
                             _bufferLength - _bufferIndex,
                             captures);
  
  if (!containsMatch) { return nil; }
  
  for (idx = 0; idx < captureCount; idx++) {
    // pull out the full range and update the bufferIndex for next iteration
    if (idx == 0) {
      matchRange.location = (XPUInteger)(captures[idx].ptr - buffer);
      matchRange.length = (XPUInteger)captures[idx].len;
      XPLogExtra3(@"%@ Pattern:`%@` Match[0]:`%@`",
       [super description], _pattern, [_string SVR_descriptionHighlightingRange:matchRange]);
    } else {
      groupRange.location = (XPUInteger)(captures[idx].ptr - buffer);
      groupRange.length = (XPUInteger)captures[idx].len;
      if (NSMaxRange(groupRange) >= [_string length]) { continue; }
      [groupRanges addObject:[NSValue XP_valueWithRange:groupRange]];
      XPLogExtra4(@"%@ Pattern:`%@` Group[%d]:`%@`",
       [super description], _pattern, idx, [_string SVR_descriptionHighlightingRange:groupRange]);
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
  XPLogExtra1(@"DEALLOC: %@", self);
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
  XPLogExtra1(@"DEALLOC: %@", self);
  [_groupRanges release];
  _groupRanges = nil;
  [super dealloc];
}

@end
