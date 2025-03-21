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

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"
#import "slre.h"

@interface XPRegularExpression: NSObject
{
  mm_copy NSString *_pattern;
  int _options;
  int _numCaps;
}

/// Options and Error are ignored
-(id)initWithPattern:(NSString*)pattern options:(int)options error:(id*)error;
/// Options and Error are ignored
+(XPRegularExpression*)regularExpressionWithPattern:(NSString*)pattern
                                            options:(int)options
                                              error:(id*)error;

-(NSString*)pattern;
-(int)options;
-(XPUInteger)numberOfCaptureGroups;

/// Options are ignored
-(NSArray*)matchesInString:(NSString*)string
                   options:(int)options
                     range:(NSRange)range;

@end

@interface XPRegularExpression (Extras)

-(NSArray*)matchesInString:(NSString*)string;
+(XPRegularExpression*)regularExpressionWithPattern:(NSString*)pattern;

@end

@interface XPTextCheckingResult: NSObject
{
  mm_retain XPRegularExpression *_expression;
  mm_new NSMutableArray *_ranges;
}
/**
 A result must have at least one range, but may optionally have more (for example, to represent regular expression capture groups).
 Passing rangeAtIndex: the value 0 always returns the value of the the range property. Additional ranges, if any, will have indexes from 1 to numberOfRanges-1.
*/
-(XPUInteger)numberOfRanges;
-(NSRange)range;
-(NSRange)rangeAtIndex:(XPUInteger)idx;
-(XPRegularExpression*)regularExpression;
-(id)initWithRanges:(XPRangePointer)ranges
              count:(XPUInteger)count
  regularExpression:(XPRegularExpression*)regularExpression;
+(XPTextCheckingResult*)regularExpressionCheckingResultWithRanges:(XPRangePointer)ranges
                                                            count:(XPUInteger)count
                                                regularExpression:(XPRegularExpression*)regularExpression;
-(NSString*)description;

@end
