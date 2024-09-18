//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathString2.h"
#import "JSBRegex.h"

@implementation SVRMathString2

-(NSString*)expressionString;
{
  return [[_expressionString retain] autorelease];
}

-(void)setExpressionString:(NSString*)expressionString;
{
  if ([expressionString isEqualToString:_expressionString]) { return; }

  // Clear all the caches
  [_coloredSolvedString release];
  [_coloredExpressionString release];
  [_encodedExpressionString release];
  [_expressionString release];
  _coloredSolvedString = nil;
  _coloredExpressionString = nil;
  _encodedExpressionString = nil;

  // Store the new value
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
  _coloredExpressionString = [[self __colorExpressionString] retain];
  return _coloredExpressionString;
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
  NSRange range;
  JSBRegex *regex = nil;
  NSMutableString *output = [[[self expressionString] mutableCopy] autorelease];
  
  // Find negative numbers - Replace with tilde - First number is negative number
  regex = [JSBRegex regexWithString:output pattern:@"^\\-\\d"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.length -= 1;
    [output replaceCharactersInRange:range withString:@"~"];
    range = [regex nextMatch];
  }
  
  // Find negative numbers - Replace with tilde - Negative number found after operator
  regex = [JSBRegex regexWithString:output pattern:@"[\\+\\-\\*\\/\\^\\(]\\-\\d"];
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
    [output replaceCharactersInRange:range withString:[[[NSUserDefaults standardUserDefaults] SVR_operatorEncodeMap] objectForKey:[output substringWithRange:range]]];
    range = [regex nextMatch];
  }
  
  // Find the tilde - Put back the negative sign to restore negative numbers
  regex = [JSBRegex regexWithString:output pattern:@"\\~\\d"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.length -= 1;
    [output replaceCharactersInRange:range withString:@"-"];
    range = [regex nextMatch];
  }
  return [[output copy] autorelease];
}

-(NSAttributedString*)__colorExpressionString;
{
  NSRange range;
  JSBRegex *regex = nil;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *encodedExpression = [self encodedExpressionString];
  NSString *expression = [self expressionString];
  NSMutableAttributedString *output = [
    [[NSMutableAttributedString alloc] initWithString:expression attributes:
       [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                            [ud SVR_colorForText],
                                            [NSFont userFixedPitchFontOfSize:14],
                                            nil]
                                   forKeys:[NSArray arrayWithObjects:
                                            NSForegroundColorAttributeName,
                                            NSFontAttributeName,
                                            nil]]
    ] autorelease];
  
  // Color Operators
  regex = [JSBRegex regexWithString:expression pattern:@"[\\+\\-\\*\\/\\^]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [XPLog extra:@"Color: Operator: %@", [expression substringWithRange:range]];
    [output setAttributes:[NSDictionary dictionaryWithObject:[ud SVR_colorForOperator]
                                                      forKey:NSForegroundColorAttributeName] range:range];
    range = [regex nextMatch];
  }
  
  // Find numbers - numbers with decimals
  regex = [JSBRegex regexWithString:encodedExpression pattern:@"\\-?\\d+\\.\\d+"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [XPLog extra:@"Color: Numeral: `%@`", [expression substringWithRange:range]];
    [output setAttributes:[NSDictionary dictionaryWithObject:[ud SVR_colorForNumeral]
                                                      forKey:NSForegroundColorAttributeName] range:range];
    range = [regex nextMatch];
  }
  // Find numbers - numbers without decimals
  regex = [JSBRegex regexWithString:encodedExpression pattern:@"\\-?\\d+"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [XPLog extra:@"Color: Numeral: %@", [expression substringWithRange:range]];
    [output setAttributes:[NSDictionary dictionaryWithObject:[ud SVR_colorForNumeral]
                                                      forKey:NSForegroundColorAttributeName] range:range];
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
  
  // MARK: Test Encoding
  SVRMathString2 *math;
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  math = [SVRMathString2 mathStringWithExpressionString:   @"-4(-2.35+2.2)-3*5-(50/-2)^2"];
  NSAssert([[math expressionString] isEqualToString:       @"-4(-2.35+2.2)-3*5-(50/-2)^2"], @"");
  NSAssert([[math encodedExpressionString] isEqualToString:@"-4(-2.35a2.2)s3m5s(50d-2)e2"], @"");
  
  // MARK: Test Coloring
  NSAssert([[[math coloredExpressionString] string] isEqualToString:@"-4(-2.35+2.2)-3*5-(50/-2)^2"], @"");
  // TODO: Test for the actual attributes
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
}
@end
