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
  
  isCompiled = slre_compile(&_engine, [pattern XP_UTF8String]);
  NSAssert2(isCompiled, @"%@ Failed to compile pattern: %@", self, pattern);
  if (!isCompiled) { return nil; }
  
  _pattern = [pattern copy];
  _cache = [NSMutableDictionary new];
  _options = options;
  
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
  NSArray *matches = [_cache objectForKey:string];
  if (matches) { return matches; }
  matches = [self __matchesInString:string options:options range:range];
  [_cache setObject:matches forKey:string];
  return matches;
}

-(XPUInteger)numberOfMatchesInString:(NSString*)string
                             options:(int)options
                               range:(NSRange)range;
{
  NSArray *matches = [_cache objectForKey:string];
  if (matches) { return [matches count]; }
  matches = [self __matchesInString:string options:options range:range];
  [_cache setObject:matches forKey:string];
  return [matches count];
}

-(NSArray*)__matchesInString:(NSString*)string
                     options:(int)options
                       range:(NSRange)range;
{
  NSRange matchRange = XPNotFoundRange;
  const char* buffer = [string XP_UTF8String];
  
  BOOL containsMatch = NO;
  int index = 0;
  int length = [string length];
  
  int capIndex = 0;
  int capCount = _engine.num_caps + 1; // according to documentation in slre.h
  struct cap caps[capCount];
  
  containsMatch = slre_match(&_engine,
                             buffer + index,
                             length - index,
                             caps);
  
  while (containsMatch) {
    for (capIndex = 0; capIndex < capCount; capIndex++) {
      // pull out the full range and update the bufferIndex for next iteration
      matchRange.location = (XPUInteger)(caps[capIndex].ptr - buffer);
      matchRange.length = (XPUInteger)caps[capIndex].len;
      XPLogDebug1(@"%@", NSStringFromRange(matchRange));
      NSLog(@"");
      // TODO: Do something with this result
    }
    capIndex = 0;
    index += 1;
    length -= 1;
    containsMatch = slre_match(&_engine,
                               buffer + index,
                               length - index,
                               caps);
  }
  return nil;
}

- (void)dealloc
{
  [_pattern release];
  [_cache release];
  _pattern = nil;
  _cache = nil;
  [super dealloc];
}

@end
