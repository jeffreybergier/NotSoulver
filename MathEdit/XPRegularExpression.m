//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
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
  XPParameterRaise(self);
  XPLogAssrt(capCount >= 0, @"Error calculating capture groups");
  
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
  
  XPLogAssrt1(NSMaxRange(maxRange)>=NSMaxRange(range), @"Invalid Range:%@", NSStringFromRange(range));
  
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
      XPLogExtra1(@"%@", [string MATH_descriptionHighlightingRange:capRanges[capIdx]]);
    }
    [output addObject:[XPTextCheckingResult regularExpressionCheckingResultWithRanges:capRanges
                                                                                count:(XPUInteger)_numCaps
                                                                    regularExpression:self]];
    free(capRanges);
  }
  
  XPLogAssrt1(status == -1, @"SLRE Error: %d", status);
  return output;
}

- (void)dealloc
{
  XPLogExtra1(@"<%@>", XPPointerString(self));
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
  XPParameterRaise(self);
  
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
  XPLogExtra1(@"<%@>", XPPointerString(self));
  [_expression release];
  [_ranges release];
  _expression = nil;
  _ranges = nil;
  [super dealloc];
}

@end
