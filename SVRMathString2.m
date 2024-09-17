//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathString2.h"
#import "SVRMathString.h"
#import "JSBRegex.h"

@implementation SVRMathString2

-(NSString*)expressionString;
{
  return [[_expressionString retain] autorelease];
}

-(void)setExpressionString:(NSString*)expressionString;
{
  if ([expressionString isEqualToString:_expressionString]) { return; }
  [_coloredSolvedString release];
  [_coloredExpressionString release];
  [_encodedExpressionString release];
  [_expressionString release];
  _coloredSolvedString = nil;
  _coloredExpressionString = nil;
  _encodedExpressionString = nil;
  
  _expressionString = [expressionString copy];
}

-(NSString*)encodedExpressionString;
{
  if (_encodedExpressionString) { return _encodedExpressionString; }
  _encodedExpressionString = [[self __encodedExpressionString] retain];
  return _encodedExpressionString;
}

-(NSAttributedString*)coloredExpressionString;
{
  if (_coloredExpressionString) { return _coloredExpressionString; }
  return nil; // TODO: Implement Solcing
}

-(NSAttributedString*)coloredSolvedString;
{
  if (_coloredSolvedString) { return _coloredSolvedString; }
  return nil; // TODO: Implement solving
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ `%@`", [super description], _expressionString];
}

// MARK Private
-(NSString*)__encodedExpressionString;
{
  // TODO: Find negative numbers first
  JSBRegex *regex;
  NSRange range;
  NSMutableString *output = [[[self expressionString] mutableCopy] autorelease];
  
  // Find negative numbers - Replace with tilde - First number is negative number
  regex = [JSBRegex regexWithString:output pattern:@"^\\-\\d"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.length -= 1;
    [output replaceCharactersInRange:range withString:@"~"];
    range = [regex nextMatch];
  }
  
  // Find negative numbers - Replace with tilde - Negative number is found after operator
  regex = [JSBRegex regexWithString:output pattern:@"[\\(\\+\\-\\*\\/\\^\\(]\\-\\d"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.location += 1;
    range.length -= 2;
    [output replaceCharactersInRange:range withString:@"~"];
    range = [regex nextMatch];
  }
  
  // Find operators and encode them
  regex = [JSBRegex regexWithString:output pattern:@"[\\+\\-\\*\\/\\^]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [output replaceCharactersInRange:range withString:[[SVRMathString operatorEncodeMap] objectForKey:[output substringWithRange:range]]];
    range = [regex nextMatch];
  }
  
  // Put back the negative numbers
  regex = [JSBRegex regexWithString:output pattern:@"[\\~]\\d"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.length -= 1;
    [output replaceCharactersInRange:range withString:@"-"];
    range = [regex nextMatch];
  }
  return [[output copy] autorelease];
}

// MARK: Dealloc
-(void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_coloredSolvedString release];
  [_coloredExpressionString release];
  [_encodedExpressionString release];
  [_expressionString release];
  _coloredSolvedString = nil;
  _coloredExpressionString = nil;
  _encodedExpressionString = nil;
  _expressionString = nil;
  [super dealloc];
}

@end

// MARK: Init
@implementation SVRMathString2 (Creating)

-(id)init;
{
 self = [super init];
  _coloredSolvedString = nil;
  _coloredExpressionString = nil;
  _encodedExpressionString = nil;
  _expressionString = nil;
 return self;
}

-(id)initWithExpressionString:(NSString*)expressionString;
{
 self = [self init];
  _expressionString = [expressionString copy];
 return self;
}

+(id)mathStringWithExpressionString:(NSString*)expressionString;
{
  return [[[SVRMathString2 alloc] initWithExpressionString:expressionString] autorelease];
}

@end

@implementation SVRMathString2 (Copying)

-(id)copyWithZone:(NSZone*)zone;
{
  return [[SVRMathString2 alloc] initWithExpressionString:_expressionString];
}

@end

@implementation SVRMathString2 (Archiving)

-(BOOL)writeToFilename:(NSString*)filename;
{
  NSData *data = [_expressionString dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) { return NO; }
  return [data writeToFile:filename atomically:YES];
}

+(id)mathStringWithFilename:(NSString*)filename;
{
  NSString *expression;
  NSData *data = [NSData dataWithContentsOfFile:filename];
  if (!data) { return nil; }
  expression = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  if (!expression) { return nil; }
  return [SVRMathString2 mathStringWithExpressionString:expression];
}

@end

@implementation SVRMathString2 (NSObjectProtocol)

-(BOOL)isEqual:(id)object;
{
  SVRMathString2 *lhs = self;
  SVRMathString2 *rhs = ([object isKindOfClass:[SVRMathString2 class]]) ? object : nil;
  if (rhs) {
    return [lhs->_expressionString isEqualToString:rhs->_expressionString];
  } else {
    return NO;
  }
}

-(XPUInteger)hash;
{
  return [_expressionString hash];
}

@end

// MARK: Testing
@implementation SVRMathString2 (Testing)
+(void)executeUnitTests;
{
  SVRMathString2 *string;
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  string = [SVRMathString2 mathStringWithExpressionString:   @"-4(-2+2)-3*5-(5/-2)^2"];
  NSAssert([[string expressionString] isEqualToString:       @"-4(-2+2)-3*5-(5/-2)^2"], @"");
  NSAssert([[string encodedExpressionString] isEqualToString:@"-4(-2a2)s3m5s(5d-2)e2"], @"");
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
}
@end
