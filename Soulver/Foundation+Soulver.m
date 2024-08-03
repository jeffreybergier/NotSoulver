//
//  NSAttributedString+Soulver.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/08/02.
//

#import "Foundation+Soulver.h"

// MARK: NSAttributedString
@implementation NSAttributedString (Soulver)
+(id)withString:(NSString*)aString;
{
  return [self withString:aString andColor:nil];
}
+(id)withString:(NSString*)aString andColor:(NSColor*)aColor;
{
  NSArray      *keys;
  NSArray      *vals;
  NSFont       *font;
  NSDictionary *attr;

  font = [NSFont userFixedPitchFontOfSize:14];
 
  if (aColor) {
    keys = [NSArray arrayWithObjects:NSBackgroundColorAttributeName, NSFontAttributeName, nil];
    vals = [NSArray arrayWithObjects:aColor, font, nil];
    attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    return [[[NSAttributedString alloc] initWithString:aString attributes:attr] autorelease];
  } else {
    keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
    vals = [NSArray arrayWithObjects:font, nil];
    attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    return [[[NSAttributedString alloc] initWithString:aString attributes:attr] autorelease];
  }
}
@end

@implementation NSMutableAttributedString (Soulver)
+(id)withString:(NSString*)aString;
{
  return [self withString:aString andColor:nil];
}
+(id)withString:(NSString*)aString andColor:(NSColor*)aColor;
{
  NSArray      *keys;
  NSArray      *vals;
  NSFont       *font;
  NSDictionary *attr;

  font = [NSFont userFixedPitchFontOfSize:14];

  if (aColor) {
    keys = [NSArray arrayWithObjects:NSBackgroundColorAttributeName, NSFontAttributeName, nil];
    vals = [NSArray arrayWithObjects:aColor, font, nil];
    attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    return [[[NSMutableAttributedString alloc] initWithString:aString attributes:attr] autorelease];
  } else {
    keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
    vals = [NSArray arrayWithObjects:font, nil];
    attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    return [[[NSMutableAttributedString alloc] initWithString:aString attributes:attr] autorelease];
  }
}
@end

// MARK: Custom Ranges
@implementation SVRBoundingRange
-(NSRange)range;
{
  return _range;
}
-(NSString*)contents;
{
  return _contents;
}
-(id)initWithRange:(NSRange)range contents:(NSString*)contents;
{
  self = [super init];
  _range = range;
  _contents = [contents retain];
  return self;
}
+(id)rangeWithRange:(NSRange)range contents:(NSString*)contents;
{
  return [[[SVRBoundingRange alloc] initWithRange:range
                                            contents:contents] autorelease];
}
- (void)dealloc
{
  [_contents release];
  [super dealloc];
}
@end

@implementation SVRMathRange
-(NSRange)range;
{
  return _range;
}
-(NSString*)lhs;
{
  return _lhs;
}
-(NSString*)rhs;
{
  return _rhs;
}
-(NSString*)operator;
{
  return _operator;
}
-(id)initWithRange:(NSRange)range lhs:(NSString*)lhs rhs:(NSString*)rhs operator:(NSString*)operator;
{
  self = [super init];
  _range = range;
  _lhs = [lhs retain];
  _rhs = [rhs retain];
  _operator = [operator retain];
  return self;
}
+(id)rangeWithRange:(NSRange)range lhs:(NSString*)lhs rhs:(NSString*)rhs operator:(NSString*)operator;
{
  return [[[SVRMathRange alloc] initWithRange:range
                                          lhs:lhs
                                          rhs:rhs
                                     operator:operator] autorelease];
}
- (void)dealloc
{
  [_lhs release];
  [_rhs release];
  [_operator release];
  [super dealloc];
}
@end

// MARK: NSString Custom Range Search
@implementation NSString (Searching)

-(SVRBoundingRange*)boundingRangeWithLHS:(NSString*)lhs andRHS:(NSString*)rhs;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorObject *next;
  NSRange outputRange;
  NSString *outputContents;
  
  e = [SVRStringEnumerator enumeratorWithString:self];
  next = [e nextObject];
  outputRange = NSMakeRange(0, 0);
  
  // TODO: have to make this keep track of how many nestings there are
  while (next) {
    if ([[next substring] isEqualToString:lhs]) {
      outputRange.location = [next range].location;
    } else if ([[next substring] isEqualToString:rhs]) {
      outputRange.length = [next range].location - outputRange.location + [next range].length;
    }
    if (outputRange.length >= 1) {
      if (outputRange.length >= 3) {
        outputContents = [self substringWithRange:NSMakeRange(outputRange.location + 1, outputRange.length - 2)];
        return [SVRBoundingRange rangeWithRange:outputRange contents:outputContents];
      } else {
        return [SVRBoundingRange rangeWithRange:outputRange contents:nil];
      }
    }
    next = [e nextObject];
  }
  return nil;
}

-(SVRMathRange*)mathRangeByMonitoringSet:(NSSet*)monitorSet ignoringSet:(NSSet*)ignoreSet;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorObject *next;
  NSRange outputRange;
  NSMutableString *lhs;
  NSMutableString *rhs;
  NSString *operator;
  
  e = [SVRStringEnumerator enumeratorWithString:self];
  next = [e nextObject];
  
  outputRange = NSMakeRange(0, 1);
  lhs = [[NSMutableString new] autorelease];
  rhs = [[NSMutableString new] autorelease];
  operator = nil;
  
  while (next) {
    if (operator && [ignoreSet member:[next substring]]) {
      outputRange.length = [next range].location - 1 - outputRange.location + [next range].length;
      return [SVRMathRange rangeWithRange:outputRange lhs:lhs rhs:rhs operator:operator];
    } else if (operator == nil && [ignoreSet member:[next substring]] && [monitorSet member:[next substring]]) {
      operator = [next substring];
    } else if (operator == nil && [ignoreSet member:[next substring]]) {
      lhs = [[NSMutableString new] autorelease];
      outputRange.location = [next range].location + 1;
    } else if (operator == nil) {
      [lhs appendString:[next substring]];
    } else {
      [rhs appendString:[next substring]];
    }
    next = [e nextObject];
  }
  // If we made it this far we finished the string
  // but there could still be valid data to return
  if ([lhs length] > 0 && [rhs length] > 0 && [operator length] > 0) {
    outputRange.length = [self length] - outputRange.location;
    return [SVRMathRange rangeWithRange:outputRange lhs:lhs rhs:rhs operator:operator];
  }
  return nil;
}
@end

@implementation SVRStringEnumeratorObject
-(NSRange)range;
{
  return _range;
}
-(NSString*)substring;
{
  return _substring;
}
-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
{
  self = [super init];
  _range = range;
  _substring = [substring retain];
  return self;
}
+(id)objectWithRange:(NSRange)range substring:(NSString*)substring;
{
  return [[[SVRStringEnumeratorObject alloc] initWithRange:range substring:substring] autorelease];
}
- (void)dealloc
{
  [_substring release];
  [super dealloc];
}
@end

@implementation SVRStringEnumerator
-(SVRStringEnumeratorObject*)nextObject;
{
  SVRStringEnumeratorObject *output;
  NSString *substring;
  
  if (_range.location > [_string length] - _range.length) {
    return nil;
  }
  
  substring = [_string substringWithRange:_range];
  output = [SVRStringEnumeratorObject objectWithRange:_range substring:substring];
  
  _range.location += 1;
  return output;
}
-(id)initWithString:(NSString*)string;
{
  self = [super init];
  _string = [string retain];
  _range = NSMakeRange(0,1);
  return self;
}
+(id)enumeratorWithString:(NSString*)string;
{
  return [[[SVRStringEnumerator alloc] initWithString:string] autorelease];
}
- (void)dealloc
{
  [_string release];
  [super dealloc];
}
@end
