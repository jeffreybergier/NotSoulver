//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRSolver.h"
#import "JSBRegex.h"

NSString *kSVRSolverSolutionKey   = @"kSVRSolverSolutionKey"; // Store NSDecimalNumber
NSString *kSVRSolverExpressionKey = @"kSVRSolverExpressionKey";
NSString *kSVRSolverBracketsKey   = @"kSVRSolverBracketsKey";
NSString *kSVRSolverOperatorKey   = @"kSVRSolverExponentKey";
NSString *kSVRSolverNumeralKey    = @"kSVRSolverMultDivKey";
NSString *kSVRSolverOtherKey      = @"kSVRSolverAddSubKey";

//NSString *kSVRSolverExpressionSolved    = @"kSVRSolverExpressionSolved";
//NSString *kSVRSolverExpressionNotSolved = @"kSVRSolverExpressionNotSolved";
NSString *kSVRSolverOperatorExponent    = @"kSVRSolverOperatorExponent";
NSString *kSVRSolverOperatorMultDiv     = @"kSVRSolverOperatorMultDiv";
NSString *kSVRSolverOperatorAddSub      = @"kSVRSolverOperatorAddSub";
NSString *kSVRSolverYES                 = @"kSVRSolverYES";

@implementation SVRSolver: NSObject

// MARK: Business Logic
+(void)solveTextStorage:(NSMutableAttributedString*)output;
{
  // Clear existing annotations
  NSRange range = NSMakeRange(0, [output length]);
  [output removeAttribute:kSVRSolverSolutionKey range:range];
  [output removeAttribute:kSVRSolverExpressionKey range:range];
  [output removeAttribute:kSVRSolverBracketsKey range:range];
  [output removeAttribute:kSVRSolverOperatorKey range:range];
  [output removeAttribute:kSVRSolverNumeralKey range:range];
  [output removeAttribute:kSVRSolverOtherKey range:range];
  
  // Restart annotation process
  [self __solve_annotateExpressions:output];
  [self __solve_annotateUnsolvedExpressions:output];
}

+(void)colorTextStorage:(NSMutableAttributedString*)output;
{
  // Remove all font, foreground, and backgorund color attributes
  NSRange range = NSMakeRange(0, [output length]);
  [output removeAttribute:NSFontAttributeName range:range];
  [output removeAttribute:NSForegroundColorAttributeName range:range];
  [output removeAttribute:NSBackgroundColorAttributeName range:range];
  [self __color_colorTextStorage:output];
}

// MARK: Private: solveTextStorage
+(void)__solve_annotateExpressions:(NSMutableAttributedString*)output;
{
  NSRange range;
  NSRange loopRange;
  NSString *loopCheck;
  XPUInteger cursor = 0;
  JSBRegex *regex = [JSBRegex regexWithString:[output string]
                                      pattern:@"\\="];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    loopRange = NSMakeRange(cursor, range.location + range.length - cursor);
    loopCheck = [output attribute:kSVRSolverExpressionKey atIndex:loopRange.location effectiveRange:NULL];
    if (loopCheck == nil) {
      [output addAttribute:kSVRSolverExpressionKey value:kSVRSolverYES range:loopRange];
      [XPLog debug:@"%@ `%@` { loc: %lu, len: %lu }", kSVRSolverExpressionKey, [[output string] substringWithRange:loopRange], loopRange.location, loopRange.length];
    }
    cursor = range.location + range.length;
    range = [regex nextMatch];
  }
}

+(void)__solve_annotateUnsolvedExpressions:(NSMutableAttributedString*)output;
{
  NSString *check;
  XPUInteger index = 0;
  NSRange range = NSMakeRange(NSNotFound, 0);
  while (index < [output length]) {
    check = [output attribute:kSVRSolverExpressionKey atIndex:index effectiveRange:&range];
    if ([kSVRSolverYES isEqualToString:check]) {
      [self __solve_annotateBrackets:output inRange:range];
      index = range.location + range.length;
    } else {
      index += 1;
    }
  }
}

+(void)__solve_annotateBrackets:(NSMutableAttributedString*)output inRange:(NSRange)_range;
{
  NSRange range;
  JSBRegex *regex = [JSBRegex regexWithString:[[output string] substringWithRange:_range]
                                      pattern:@"\\([\\d\\.\\^\\*\\-\\+\\/]+\\)"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    range.location += _range.location;
    [output addAttribute:kSVRSolverBracketsKey value:kSVRSolverYES range:range];
    range = [regex nextMatch];
  }
}

// MARK: Private: colorTextStorage
+(void)__color_colorTextStorage:(NSMutableAttributedString*)output;
{
  NSString *check;
  XPUInteger index = 0;
  NSRange range = NSMakeRange(0, [output length]);
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  // Add font and other text attributes
  [output addAttribute:NSFontAttributeName value:[ud SVR_fontForText] range:range];
  [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForText] range:range];
  
  while (index < [output length]) {
    check = [output attribute:kSVRSolverBracketsKey atIndex:index effectiveRange:&range];
    if (check) {
      [output addAttribute:NSForegroundColorAttributeName value:[ud SVR_colorForBrackets] range:range];
    }
    index += 1;
  }
}


@end

@implementation SVRSolver (Testing)

+(void)executeTests;
{
  NSString *_string = @"(5+5)+(4+4)=3+4+(2+2)=";
  NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:_string] autorelease];
  [XPLog alwys:@"<%@> Unit Tests: STARTING", self];
  [SVRSolver solveTextStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver colorTextStorage:string];
  [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
  [SVRSolver solveTextStorage:string];
  [XPLog pause:@"%@", string];
  [SVRSolver colorTextStorage:string];
  [XPLog pause:@"%@", string];
  [XPLog alwys:@"<%@> Unit Tests: PASSED", self];
}

@end

/*
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
  // _encodedExpressionString = [[self __encodedExpressionString] retain];
  return _encodedExpressionString;
}

-(NSAttributedString*)coloredExpressionString;
{
  if (_coloredExpressionString) { return _coloredExpressionString; }
  // _coloredExpressionString = [[self __colorExpressionString] retain];
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
+(NSString*)__encodeExpressionString:(NSString*)expressionString;
{
  NSRange range;
  JSBRegex *regex = nil;
  NSMutableString *output = [[expressionString mutableCopy] autorelease];
  
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

+(void)__colorExpressionString:(NSMutableAttributedString*)attrstr;
{
  NSRange range;
  JSBRegex *regex = nil;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *expression = [attrstr string];
  NSString *encodedExpression = [self __encodeExpressionString:expression];
  [self __resetAttributes:attrstr];
  
  // Color Operators
  regex = [JSBRegex regexWithString:expression pattern:@"[\\+\\-\\*\\/\\^]"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [XPLog extra:@"Color: Operator: %@", [expression substringWithRange:range]];
    [attrstr setAttributes:[NSDictionary dictionaryWithObject:[ud SVR_colorForOperator]
                                                       forKey:NSForegroundColorAttributeName] range:range];
    range = [regex nextMatch];
  }
  
  // Find numbers - numbers with decimals
  regex = [JSBRegex regexWithString:encodedExpression pattern:@"\\-?\\d+\\.\\d+"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [XPLog extra:@"Color: Numeral: `%@`", [expression substringWithRange:range]];
    [attrstr setAttributes:[NSDictionary dictionaryWithObject:[ud SVR_colorForNumeral]
                                                       forKey:NSForegroundColorAttributeName] range:range];
    range = [regex nextMatch];
  }
  // Find numbers - numbers without decimals
  regex = [JSBRegex regexWithString:encodedExpression pattern:@"\\-?\\d+"];
  range = [regex nextMatch];
  while (range.location != NSNotFound) {
    [XPLog extra:@"Color: Numeral: %@", [expression substringWithRange:range]];
    [attrstr setAttributes:[NSDictionary dictionaryWithObject:[ud SVR_colorForNumeral]
                                                       forKey:NSForegroundColorAttributeName] range:range];
    range = [regex nextMatch];
  }
}

+(void)__resetAttributes:(NSMutableAttributedString*)attrstr;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSRange range = NSMakeRange(0, [attrstr length]);
  [attrstr removeAttribute:NSForegroundColorAttributeName range:range];
  [attrstr removeAttribute:NSBackgroundColorAttributeName range:range];
  [attrstr removeAttribute:NSFontAttributeName range:range];
  
  [attrstr setAttributes:
   [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                        [ud SVR_colorForText],
                                        [NSFont userFixedPitchFontOfSize:14],
                                        nil]
                               forKeys:[NSArray arrayWithObjects:
                                        NSForegroundColorAttributeName,
                                        NSFontAttributeName,
                                        nil]]
                   range:range];
}

// MARK: Stateless Methods
+(void)updateStorage:(NSMutableAttributedString*)attrstr;
{
  [self __resetAttributes:attrstr];
  [self __colorExpressionString:attrstr];
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

*/
