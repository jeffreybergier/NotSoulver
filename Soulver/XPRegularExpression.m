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
  self = [super init];
  NSCParameterAssert(self);
  
  _pattern = [pattern copy];
  _options = options;
  _numCaps = 1;
  
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
-(int)numberOfCaptureGroups;
{
  return 1;
}
-(void)setNumberOfCaptureGroups:(int)newValue;
{
  _numCaps = newValue;
}

-(NSArray*)matchesInString:(NSString*)string
                   options:(int)options
                     range:(NSRange)range;
{
  NSMutableArray *output = [[NSMutableArray new] autorelease];
  NSRange maxRange = NSMakeRange(0, [string length]);
  NSRange matchRange = range;
  const char* buffer = [string XP_UTF8String];
  int capCount = [self numberOfCaptureGroups];
  int capIndex = 0;
  struct slre_cap caps[capCount];
  int result = -1;
  XPRangePointer ranges = NULL;
  
  NSAssert2(NSEqualRanges(NSUnionRange(range, maxRange), maxRange),
           @"String Range %@ does not fully contain argument range %@", NSStringFromRange(maxRange), NSStringFromRange(range));
  
  result = slre_match([_pattern XP_UTF8String],
                      buffer + matchRange.location,
                      (int)range.length - ((int)matchRange.location - (int)range.location),
                      caps, capCount, 0);
  XPLogExtra3(@"Found: %d, Scanned:%@, Pattern:%@",
              (int)matchRange.length,
              [string SVR_descriptionHighlightingRange:NSMakeRange(matchRange.location, range.length - (matchRange.location - range.location))],
              _pattern);
  
  while (result >= 0) {
    ranges = (XPRangePointer)malloc(sizeof(NSRange) * (unsigned long)capCount);
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
                                                                                count:(XPUInteger)capCount
                                                                    regularExpression:self]];
    free(ranges);
    matchRange.location = NSMaxRange(matchRange);
    result = slre_match([_pattern XP_UTF8String],
                        buffer + matchRange.location,
                        (int)range.length - ((int)matchRange.location - (int)range.location),
                        caps, capCount, 0);
    XPLogExtra3(@"Found: %d, Scanned:%@, Pattern:%@",
                (int)matchRange.length,
                [string SVR_descriptionHighlightingRange:NSMakeRange(matchRange.location, range.length - (matchRange.location - range.location))],
                _pattern);
  }
  return output;
}

- (void)dealloc
{
  XPLogExtra1(@"DEALLOC: %@", self);
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
  
  self = [super init];
  NSCParameterAssert(self);
  
  _expression = [regularExpression retain];
  _ranges = [[NSMutableArray alloc] initWithCapacity:count];
  for (index = 0; index < count; index++) {
    range = ranges[index];
    if (XPIsNotFoundRange(range)) { break; }
    [_ranges addObject:[NSValue XP_valueWithRange:range]];
  }
  
  if ([_ranges count] == 0) { [self release]; return nil; }
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

-(NSString*)description;
{
  return [[super description] stringByAppendingString:[_ranges description]];
}

-(void)dealloc
{
  XPLogExtra1(@"DEALLOC: %@", self);
  [_expression release];
  [_ranges release];
  _expression = nil;
  _ranges = nil;
  [super dealloc];
}

@end
