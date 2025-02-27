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

#import "XPRegularExpression.h"

@implementation XPRegularExpression

-(id)initWithPattern:(NSString *)pattern options:(int)options error:(id*)error;
{
  BOOL isCompiled = NO;
  self = [super init];
  
  _pattern = [pattern copy];
  _options = options;
  
  isCompiled = slre_compile(&_engine, [_pattern XP_UTF8String]);
  NSAssert2(isCompiled, @"%@ Failed to compile pattern: %@", self, pattern);
  if (!isCompiled) {
    [_pattern release];
    return nil;
  }
  
  return self;
}

+(XPRegularExpression*)regularExpressionWithPattern:(NSString*)pattern
                                            options:(int)options
                                              error:(id*)error;
{
  return [[[XPRegularExpression alloc] initWithPattern:pattern
                                               options:options
                                                 error:error] autorelease];
}

-(NSString*)pattern;
{
  return [[_pattern retain] autorelease];
}
-(int)options;
{
  return _options;
}
-(XPUInteger)numberOfCaptureGroups;
{
  return (XPUInteger)_engine.num_caps;
}

-(NSArray*)matchesInString:(NSString*)string
                   options:(int)options
                     range:(NSRange)range;
{
  NSRange matchRange = range;
  const char* buffer = [string XP_UTF8String];
  unsigned long capCount = (unsigned long)_engine.num_caps + 1; // according to documentation in slre.h
  NSMutableArray *output = [[NSMutableArray new] autorelease];
  
  // Variables for loop
  int capIndex = 0;
  struct cap caps[capCount];
  XPRangePointer ranges = NULL;
  
  slre_match(&_engine,
             buffer + matchRange.location,
             (int)matchRange.length,
             caps);
  
  while (!XPIsNotFoundRange(matchRange)) {
    ranges = (XPRangePointer)malloc(sizeof(NSRange) * capCount);
    for (capIndex = 0; capIndex < capCount; capIndex++) {
      matchRange.location = (XPUInteger)(caps[capIndex].ptr - buffer);
      matchRange.length = (XPUInteger)caps[capIndex].len;
      ranges[capIndex] = matchRange;
      XPLogExtra3(@"index:%d, range:%@ match:%@", capIndex, NSStringFromRange(matchRange), [string substringWithRange:matchRange]);
    }
    [output addObject:[XPTextCheckingResult regularExpressionCheckingResultWithRanges:ranges
                                                                                count:capCount
                                                                    regularExpression:self]];
    free(ranges);
    matchRange.location = NSMaxRange(matchRange);
    matchRange.length = range.length - matchRange.location;
    if (NSMaxRange(matchRange) < NSMaxRange(range)) {
      slre_match(&_engine,
                 buffer + matchRange.location,
                 (int)matchRange.length,
                 caps);
    } else {
      matchRange = XPNotFoundRange;
    }
  }
  return output;
}

- (void)dealloc
{
  [_pattern release];
  _pattern = nil;
  [super dealloc];
}

@end

@implementation XPTextCheckingResult

-(XPUInteger)numberOfRanges;
{
  return [_ranges count];
}
-(NSRange)range;
{
  return [[_ranges objectAtIndex:0] XP_rangeValue];
}
-(NSRange)rangeAtIndex:(XPUInteger)idx;
{
  return [[_ranges objectAtIndex:idx] XP_rangeValue];
}
-(XPRegularExpression*)regularExpression;
{
  return [[_expression retain] autorelease];
}

-(id)initWithRanges:(XPRangePointer)ranges
              count:(XPUInteger)count
  regularExpression:(XPRegularExpression*)regularExpression;
{
  XPUInteger index = 0;
  if (count == 0) { return nil; }
  self = [super init];
  _expression = [regularExpression retain];
  _ranges = [[NSMutableArray alloc] initWithCapacity:count];
  for (index = 0; index < count; index++) {
    [_ranges addObject:[NSValue XP_valueWithRange:ranges[index]]];
  }
  
  return self;
}

+(XPTextCheckingResult*)regularExpressionCheckingResultWithRanges:(XPRangePointer)ranges
                                                            count:(XPUInteger)count
                                                regularExpression:(XPRegularExpression*)regularExpression;
{
  return [[[XPTextCheckingResult alloc] initWithRanges:ranges
                                                 count:count
                                     regularExpression:regularExpression] autorelease];
}

-(void)dealloc
{
  [_expression release];
  [_ranges release];
  _expression = nil;
  _ranges = nil;
  [super dealloc];
}

@end
