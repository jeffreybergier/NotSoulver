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

-(SVRBoundingRange*)boundingRangeWithLHS:(NSString*)lhs
                                  andRHS:(NSString*)rhs
                                   error:(NSNumber**)error;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorObject *next;
  NSMutableArray *foundLHS;
  SVRStringEnumeratorObject *foundRHS;
  NSRange outputRange;
  NSString *outputContents;
  int balanceCounter;
  
  if (*error != NULL) {
    return nil;
  }
  
  foundLHS = [[NSMutableArray new] autorelease];
  foundRHS = nil;
  e = [SVRStringEnumerator enumeratorWithString:self];
  next = [e nextObject];
  balanceCounter = 0;
  
  while (next) {
    if ([[next substring] isEqualToString:lhs]) {
      balanceCounter = balanceCounter + 1;
      if (foundRHS == nil) {
        [foundLHS addObject:next];
      }
    } else if ([[next substring] isEqualToString:rhs]) {
      balanceCounter = balanceCounter - 1;
      if (foundRHS == nil) {
        foundRHS = next;
      }
    }
    next = [e nextObject];
  }
  
  if (balanceCounter != 0) {
    *error = [NSNumber errorMismatchedBrackets];
    return nil;
  } else if ([foundLHS count] == 0 && foundRHS == nil) {
    return nil;
  } else {
    outputRange = NSMakeRange(0, 0);
    outputRange.location = [[foundLHS lastObject]  range].location;
    outputRange.length   = [foundRHS               range].location
                         - [[foundLHS lastObject]  range].location
                         + 1;
    outputContents = [self substringWithRange:
                        NSMakeRange(outputRange.location + 1,
                                    outputRange.length - 2)
                     ];
    return [SVRBoundingRange rangeWithRange:outputRange contents:outputContents];
  }
}

-(SVRMathRange*)mathRangeByMonitoringSet:(NSSet*)monitorSet
                             ignoringSet:(NSSet*)ignoreSet;
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
  } else {
    return nil;
  }
}
-(BOOL)isValidDouble;
{
  return [self isEqualToString:[NSString stringWithFormat:@"%g", [self doubleValue]]];
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
-(NSString*)description;
{
  return [
    NSString stringWithFormat:
      @"SVRStringEnumeratorObject: Range<location: %d, lenght: %d>: Substring:<%@>",
    [self range].location,
    [self range].length,
    [self substring]
  ];
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
  
  if ([_string length] == 0) {
    return nil;
  }
  
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

// MARK: NSError
// OPENSTEP does not have NSError so I am just using NSNumber
@implementation NSNumber (NSError)
+(NSNumber*)errorInvalidCharacter;
{
  return [NSNumber numberWithInt:-1002];
}
+(NSNumber*)errorMismatchedBrackets;
{
  return [NSNumber numberWithInt:-1003];
}
+(NSNumber*)errorMissingNumberBeforeOrAfterOperator;
{
  return [NSNumber numberWithInt:-1004];
}
+(NSNumber*)errorPatching;
{
  return [NSNumber numberWithInt:-1005];
}
@end

// MARK: NSSetHelper
@implementation NSSet (Soulver)
+(NSSet*)SVROperators;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  [output unionSet:[NSSet SVRPlusMinus]];
  [output unionSet:[NSSet SVRMultDiv]];
  [output unionSet:[NSSet SVRExponent]];
  return [[output copy] autorelease];
}
+(NSSet*)SVRPlusMinus;
{
  return [NSSet setWithObjects:@"a", @"s", nil];
}
+(NSSet*)SVRMultDiv;
{
  return [NSSet setWithObjects:@"d", @"m", nil];
}
+(NSSet*)SVRExponent;
{
  return [NSSet setWithObjects:@"e", nil];
}
+(NSSet*)SVRNumerals;
{
  return [NSSet setWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @".", @"-", nil];
}
+(NSSet*)SVRPatchCheck;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  [output unionSet:[NSSet SVROperators]];
  [output unionSet:[NSSet setWithObjects:@"(", @")", @"=", nil]];
  return [[output copy] autorelease];
}
+(NSSet*)SVRAllowedCharacters;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  [output unionSet:[NSSet SVRPatchCheck]];
  [output unionSet:[NSSet SVRNumerals]];
  return [[output copy] autorelease];
}
@end

// MARK: Logging
@implementation NSString (SVRLog)
/// Replaces newlines from logged strings with \n
-(void)SVRLog;
{
  NSMutableString *output = [[NSMutableString new] autorelease];
  NSArray *components = [self componentsSeparatedByString:@"\n"];
  NSEnumerator *e = [components objectEnumerator];
  NSString *current = [e nextObject];
  NSString *next;
  while (current) {
    [output appendString:current];
    next = [e nextObject];
    if (next) {
      [output appendString:@"\\n"];
    }
    current = next;
  }
  NSLog(@"%@", output);
}
@end
