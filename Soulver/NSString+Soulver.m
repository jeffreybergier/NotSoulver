//
//  NSAttributedString+Soulver.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/08/02.
//

#import "NSString+Soulver.h"
#import "SVRConstants.h"

// MARK: NSAttributedString
@implementation NSAttributedString (Soulver)
+(id)SVR_stringWithString:(NSString*)aString;
{
  return [self SVR_stringWithString:aString color:nil];
}
+(id)SVR_stringWithString:(NSString*)aString color:(NSColor*)aColor;
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

// MARK: NSString
@implementation NSString (Soulver)
-(BOOL)SVR_containsOnlyCharactersInSet:(NSSet*)set;
{
  SVRStringEnumeratorRange *next;
  NSEnumerator *e = [SVRStringEnumerator enumeratorWithString:self];
  
  while (next = [e nextObject]) {
    if ([set member:[next substring]]) { continue; }
    return NO;
  }
  
  return YES;
}
-(BOOL)SVR_beginsWithCharacterInSet:(NSSet*)set;
{
  if ([self length] == 0) { return NO; }
  NSString *check = [self substringWithRange:NSMakeRange(0, 1)];
  return [set member:check];
}
-(NSString*)SVR_stringByMappingCharactersInDictionary:(NSDictionary*)map;
{
  SVRStringEnumeratorRange *next = nil;
  NSEnumerator *e = [SVRStringEnumerator enumeratorWithString:self];
  NSMutableString *output = [[NSMutableString new] autorelease];
  NSString *toAppend = nil;
  while (next = [e nextObject]) {
    toAppend = [map objectForKey:[next substring]];
    if (!toAppend) { toAppend = [next substring]; }
    [output appendString:toAppend];
  }
  return [[output copy] autorelease];
}
@end

// MARK: NSMutableString
@implementation NSMutableString (Soulver)
-(void)SVR_insertSolution:(NSString*)solution
                  atRange:(NSRange)range
                    error:(NSNumber**)error;
{
  BOOL issueFound = NO;
  BOOL canCheckLeft = NO;
  BOOL canCheckRight = NO;
  NSRange checkRange = NSMakeRange(0,0);
  
  if (*error != NULL) {
    return;
  }
  
  canCheckLeft = range.location > 0;
  canCheckRight = range.location + range.length < [self length];
  
  // Perform Checks to the left and right to make sure
  // there are operators outside of where we are patching.
  if (canCheckLeft) {
    checkRange.location = range.location - 1;
    checkRange.length = 1;
    issueFound = [[NSSet SVR_solutionInsertCheck] member:[self substringWithRange:checkRange]] == nil;
  }
  
  if (issueFound) {
    *error = [NSNumber SVR_errorPatching];
    return;
  }
  
  if (canCheckRight) {
    checkRange.location = range.location + range.length;
    checkRange.length = 1;
    issueFound = [[NSSet SVR_solutionInsertCheck] member:[self substringWithRange:checkRange]] == nil;
  }
  
  if (issueFound) {
    *error = [NSNumber SVR_errorPatching];
    return;
  }
  
  [self replaceCharactersInRange:range withString:solution];
  return;
}
@end


@implementation SVRStringEnumeratorRange
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
    NSString stringWithFormat:@"SVREnumeratorRange: '%@' {%d, %d}",
                              _substring, _range.location, _range.length];
}
-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
{
  self = [super init];
  _range = range;
  _substring = [substring retain];
  return self;
}
+(id)rangeWithRange:(NSRange)range substring:(NSString*)substring;
{
  return [[[SVRStringEnumeratorRange alloc] initWithRange:range substring:substring] autorelease];
}
- (void)dealloc
{
  [_substring release];
  [super dealloc];
}
@end

@implementation SVRStringEnumerator
-(SVRStringEnumeratorRange*)nextObject;
{
  SVRStringEnumeratorRange *output;
  NSString *substring;
  
  if ([_string length] == 0) {
    return nil;
  }
  
  if (_range.location > [_string length] - _range.length) {
    return nil;
  }
  
  substring = [_string substringWithRange:_range];
  output = [SVRStringEnumeratorRange rangeWithRange:_range substring:substring];
  
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
