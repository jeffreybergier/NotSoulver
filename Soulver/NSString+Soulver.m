//
//  NSAttributedString+Soulver.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/08/02.
//

#import "NSString+Soulver.h"

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
    NSString stringWithFormat:@"SVRStringEnumeratorObject: Range<location: %d, lenght: %d>: Substring:<%@>",
                              _range.location, _range.length, _substring];
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
