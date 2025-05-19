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

-(id)initWithPattern:(NSString *)aPattern options:(int)options error:(id*)error;
{
  // Need to manually find cap count as SLRE no longer does this automatically
  NSString *pattern   =  aPattern;
  NSArray  *capFalse  = [aPattern componentsSeparatedByString:@"\\("];
  NSArray  *capAll    = [aPattern componentsSeparatedByString:@"("];
  XPUInteger capCount  = ([capAll count] - 1) - ([capFalse count] - 1);
  
  // Need to test as SLRE no longer compiles the pattern ahead of time
  struct slre_cap *testCaps;
  NSString *testString = @" ";
  int testStatus = -10;

  // Finally do the init stuff
  self = [super init];
  NSCParameterAssert(self);
  NSCAssert(capCount >= 0, @"Error calculating capture groups");
  
  // Need to add a capture if there is none in the pattern
  // SLRE used to give the results if no capture present
  if (capCount == 0) {
    pattern = [[@"(" stringByAppendingString:aPattern] stringByAppendingString:@")"];
    capCount = 1;
  }
  
  // Need to test as SLRE no longer compiles the pattern ahead of time
  testCaps = malloc(sizeof(struct slre_cap) * (unsigned long)capCount);
  testStatus = slre_match([pattern XP_UTF8String], [testString XP_UTF8String],
                          (int)[testString length], testCaps, (int)capCount, 0);
  free(testCaps);
  if (testStatus < -1) {
    if (error != NULL) {
      *error = [NSString stringWithFormat:@"SLRE Error: %d", testStatus];
    } else {
      XPLogRaise1(@"SLRE Error: %d", testStatus);
    }
    return nil;
  }
  
  // Finally do the init stuff
  _pattern = [pattern copy];
  _options = options;
  _numCaps = (int)capCount;
  
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
  return (XPUInteger)_numCaps;
}

-(NSArray*)matchesInString:(NSString*)string
                   options:(int)options
                     range:(NSRange)range;
{
  NSMutableArray *output = [[NSMutableArray new] autorelease];
  
  NSRange     maxRange  = NSMakeRange(0, [string length]);
  const char *maxBuffer = [string XP_UTF8String];
  const char *buffer    = maxBuffer + range.location;
  
  XPRangePointer  capRanges = NULL;
  struct slre_cap caps[_numCaps];
  int capIdx = 0;
  int status = 0;
  
  NSCAssert1(NSMaxRange(maxRange)>=NSMaxRange(range), @"Invalid Range:%@", NSStringFromRange(range));
  
  while (status >= 0) {
    buffer += status;
    status = slre_match([_pattern XP_UTF8String], buffer,
                        (int)NSMaxRange(range)-(int)(buffer-maxBuffer),
                        caps, _numCaps, 0);
    if (status < 0) { break; }
    capRanges = malloc(sizeof(NSRange) * (unsigned long)_numCaps);
    for (capIdx = 0; capIdx<_numCaps; capIdx++) {
      capRanges[capIdx] = NSMakeRange((XPUInteger)(caps[capIdx].ptr - maxBuffer),
                                      (XPUInteger)caps[capIdx].len);
      XPLogExtra1(@"%@", [string SVR_descriptionHighlightingRange:capRanges[capIdx]]);
    }
    [output addObject:[XPTextCheckingResult regularExpressionCheckingResultWithRanges:capRanges
                                                                                count:(XPUInteger)_numCaps
                                                                    regularExpression:self]];
    free(capRanges);
  }
  
  NSCAssert1(status == -1, @"SLRE Error: %d", status);
  return output;
}

- (void)dealloc
{
  XPLogExtra1(@"%p", self);
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
  XPLogExtra1(@"%p", self);
  [_expression release];
  [_ranges release];
  _expression = nil;
  _ranges = nil;
  [super dealloc];
}

@end
