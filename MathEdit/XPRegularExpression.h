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
-(id)initWithPattern:(NSString*)pattern options:(int)options error:(XPErrorPointer)outError;
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
