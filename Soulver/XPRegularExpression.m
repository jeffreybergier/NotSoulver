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
  if (!isCompiled) { return nil; }
  
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
  NSMutableArray *output = [[NSMutableArray new] autorelease];
  NSRange maxRange = NSMakeRange(0, [string length]);
  NSRange matchRange = range; // length is serving double duty as matchfound variable
  const char* buffer = [string XP_UTF8String];
  unsigned long capCount = (unsigned long)_engine.num_caps + 1; // according to documentation in slre.h
  int capIndex = 0;
  struct cap caps[capCount];
  XPRangePointer ranges = NULL;
  
  NSAssert2(NSEqualRanges(NSUnionRange(range, maxRange), maxRange),
           @"String Range %@ does not fully contain argument range %@", NSStringFromRange(maxRange), NSStringFromRange(range));
  
  matchRange.length = (XPUInteger)slre_match(&_engine,
                                             buffer + matchRange.location,
                                             (int)range.length - ((int)matchRange.location - (int)range.location),
                                             caps);
  XPLogExtra3(@"Found: %d, Scanned:%@, Pattern:%@",
              (int)matchRange.length,
              [string SVR_descriptionHighlightingRange:NSMakeRange(matchRange.location, range.length - (matchRange.location - range.location))],
              _pattern);
  
  while (matchRange.length > 0) {
    ranges = (XPRangePointer)malloc(sizeof(NSRange) * capCount);
    for (capIndex = 0; capIndex < capCount; capIndex++) {
      // This if statement is needed if the capCount value is too large
      if (caps[capIndex].ptr >= buffer + range.location
          && caps[capIndex].ptr + caps[capIndex].len <= buffer + range.location + range.length)
      {
        matchRange.location = (XPUInteger)(caps[capIndex].ptr - buffer);
        matchRange.length = (XPUInteger)caps[capIndex].len;
        ranges[capIndex] = matchRange;
        XPLogExtra2(@"index:%d, match:'%@'", capIndex, [string SVR_descriptionHighlightingRange:matchRange]);
      } else {
        ranges[capIndex] = XPNotFoundRange;
      }
    }
    [output addObject:[XPTextCheckingResult regularExpressionCheckingResultWithRanges:ranges
                                                                                count:capCount
                                                                    regularExpression:self]];
    free(ranges);
    matchRange.location = NSMaxRange(matchRange);
    matchRange.length = (XPUInteger)slre_match(&_engine,
                                               buffer + matchRange.location,
                                               (int)range.length - ((int)matchRange.location - (int)range.location),
                                               caps);
    XPLogExtra3(@"Found: %d, Scanned:%@, Pattern:%@",
                (int)matchRange.length,
                [string SVR_descriptionHighlightingRange:NSMakeRange(matchRange.location, range.length - (matchRange.location - range.location))],
                _pattern);
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

@implementation XPRegularExpression (Extras)

-(NSArray*)matchesInString:(NSString*)string;
{
  return [self matchesInString:string options:0 range:NSMakeRange(0, [string length])];
}

+(XPRegularExpression*)regularExpressionWithPattern:(NSString*)pattern;
{
  return [self regularExpressionWithPattern:pattern options:0 error:NULL];
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
  NSRange range = XPNotFoundRange;
  if (count == 0) { return nil; }
  self = [super init];
  _expression = [regularExpression retain];
  _ranges = [[NSMutableArray alloc] initWithCapacity:count];
  for (index = 0; index < count; index++) {
    range = ranges[index];
    if (XPIsNotFoundRange(range)) { break; }
    [_ranges addObject:[NSValue XP_valueWithRange:range]];
  }
  if ([_ranges count] == 0) { return nil; }
  return self;
}

+(XPTextCheckingResult*)regularExpressionCheckingResultWithRanges:(XPRangePointer)ranges
                                                            count:(XPUInteger)count
                                                regularExpression:(XPRegularExpression*)regularExpression;
{
  // TODO: Figure out memory leak in static analyzer
  return [[[XPTextCheckingResult alloc] initWithRanges:ranges
                                                 count:count
                                     regularExpression:regularExpression] autorelease];
}

-(NSString*)debugDescription;
{
  return [_ranges debugDescription];
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
