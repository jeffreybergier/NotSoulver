//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverScanner.h"
#import "SVRCrossPlatform.h"
#import "SVRLegacyRegex.h"

@implementation SVRSolverScanner

// MARK: Initialization
-(id)initWithString:(NSString*)string;
{
  self = [super init];
  _string = [string copy];
  _numbers = nil;
  _operators = nil;
  _operators = nil;
  _expressions = nil;
  _brackets = nil;
  return self;
}

+(id)scannerWithString:(NSString*)string;
{
  return [[[SVRSolverScanner alloc] initWithString:string] autorelease];
}

// MARK: Enumerator Access (mostly for testing)
-(NSSet*)numberRanges;
{
  if (_numbers == nil) {
    [self __populateNumbers];
  }
  return [[_numbers retain] autorelease];
}

-(NSSet*)operatorRanges;
{
  if (_numbers == nil) {
    [self __populateOperators];
  }
  return [[_operators retain] autorelease];
}

-(NSSet*)expressionRanges;
{
  if (_numbers == nil) {
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
}

-(NSSet*)bracketRanges;
{
  if (_brackets == nil) {
    [self __populateBrackets];
  }
  return [[_brackets retain] autorelease];
}

// MARK: Convenience Properties
-(NSString*)string;
{
  return [[_string retain] autorelease];
}
-(NSString*)description;
{
  return [super description];
}

// MARK: Private
-(void)__populateNumbers;
{
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSRange range = XPNotFoundRange;
  NSValue *rangeV = nil;
  SVRLegacyRegex *regex = nil;
  SVRLegacyRegex *n_regex = nil; // for testing negative numbers to make sure they are preceded by an operator

  NSAssert(!_numbers, @"This is a lazy init method, it assumes _numbers is NIL");
  
  // Find negative floats
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\-\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    if (range.location == 0) { // If we're at the beginning of the string the negative number needs no checks
      [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
      [self __addRange:range toSet:output];
    } else {
      n_regex = [SVRLegacyRegex regexWithString:[_string substringWithRange:NSMakeRange(range.location-1, 1)]
                                        pattern:@"[\\=\\(\\+\\-\\*\\/\\^]"];
      if ([n_regex nextObject]) {
        [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
        [self __addRange:range toSet:output];
      }
    }
  }
  
  // Find negative integers
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\-\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    if (range.location == 0) { // If we're at the beginning of the string the negative number needs no checks
      [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
      [self __addRange:range toSet:output];
    } else {
      n_regex = [SVRLegacyRegex regexWithString:[_string substringWithRange:NSMakeRange(range.location-1, 1)]
                                        pattern:@"[\\=\\(\\+\\-\\*\\/\\^]"];
      if ([n_regex nextObject]) {
        [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
        [self __addRange:range toSet:output];
      }
    }
  }
  
  // Find positive floats
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
    [self __addRange:range toSet:output];
  }
  
  // Find positive integers
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
    [self __addRange:range toSet:output];
  }
  
  _numbers = [output copy];
}

-(void)__addRange:(NSRange)rhs toSet:(NSMutableSet*)set;
{
  BOOL shouldAdd = YES;
  NSEnumerator *e = nil;
  NSValue *next = nil;
  NSRange lhs = XPNotFoundRange;
  e = [set objectEnumerator];
  while ((next = [e nextObject])) {
    lhs = [next XP_rangeValue];
    shouldAdd = !XPContainsRange(lhs, rhs);
    if (!shouldAdd) { break; }
  }
  if (shouldAdd) {
    [set addObject:[NSValue XP_valueWithRange:rhs]];
  }
}

-(void)__populateOperators;
{
  NSRange range;
  NSValue *value;
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  SVRLegacyRegex *regex = [SVRLegacyRegex regexWithString:_string
                                                  pattern:@"[\\d\\)][\\*\\-\\+\\/\\^][\\-\\d\\(]"
                                           forceIteration:YES];
  NSAssert(!_operators, @"This is a lazy init method, it assumes _operators is NIL");
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.location += 1;
    range.length = 1;
    [XPLog extra:@"<+*> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  _operators = [output copy];
}

-(void)__populateExpressions;
{
  NSValue *value;
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  SVRLegacyRegex *regex = [SVRLegacyRegex regexWithString:_string
                                                  pattern:@"[\\d\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
  NSAssert(!_expressions, @"This is a lazy init method, it assumes _expressions is NIL");
  while ((value = [regex nextObject])) {
    [XPLog extra:@"<=> %@", [_string SVR_descriptionHighlightingRange:[value XP_rangeValue]]];
    [output addObject:value];
  }
  _expressions = [output copy];
}

-(void)__populateBrackets;
{
  NSRange range;
  NSValue *value;
  SVRLegacyRegex *regex = nil;
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSAssert(!_brackets, @"This is a lazy init method, it assumes _brackets is NIL");

  // Check for opening brackets
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\([\\-\\d]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.length = 1;
    [XPLog extra:@"<(> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  // Check for closing brackets
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d\\)[\\^\\*\\/\\+\\-\\=]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.location += 1;
    range.length = 1;
    [XPLog extra:@"<)> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  _brackets = [output copy];
}

// MARK: Dealloc
-(void)dealloc;
{
  [_string release];
  [_numbers release];
  [_operators release];
  [_expressions release];
  [_brackets release];
  _string = nil;
  _numbers = nil;
  _operators = nil;
  _expressions = nil;
  _brackets = nil;
  [super dealloc];
}

@end

@implementation SVRSolverScanner (Tests)
+(void)executeTests;
{
  [XPLog alwys:@"SVRSolverScanner Tests: Starting"];
  [self __executeNumberTests];
  [self __executeOperatorTests];
  [self __executeExpressionTests];
  [self __executeBracketTests];
  [XPLog alwys:@"SVRSolverScanner Tests: Passed"];
}

+(void)__executeNumberTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  
  // MARK: Test 200
  input = @"200";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 3)]];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 23.78
  input = @"23.78";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 5)]];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -200
  input = @"-200";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 4)]];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -23.78
  input = @"-23.78";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 6)]];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5^2=
  input = @"5^2=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(2, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5.2^2.3=
  input = @"5.2^2.3=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(4, 3)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 2+-5.2^2.3=
  input = @"2+-5.2^2.3=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(2, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(7, 3)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 100+200+300+400+500+600=
  input = @"100+200+300+400+500+600=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(4, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(8, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(16, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(20, 3)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 100+200+300+400+500+600=
  input = @"10.0+20.0+30.0+40.0+50.0+60.0=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(5, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(10, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(15, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(20, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(25, 4)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -2.5+-75/90*-3.0^8=
  input = @"-2.5+-75/90*-3.0^8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(5, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(9, 2)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 5)], // TODO: This is wrong!!! 5→4
              [NSValue XP_valueWithRange:NSMakeRange(17, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] numberRanges];
  NSAssert([output isEqualToSet:expected], @"");
}

+(void)__executeOperatorTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  
  // MARK: Test 200
  input = @"200";
  expected = [[NSSet new] autorelease];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 23.78
  input = @"23.78";
  expected = [[NSSet new] autorelease];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -200
  input = @"-200";
  expected = [[NSSet new] autorelease];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -23.78
  input = @"-23.78";
  expected = [[NSSet new] autorelease];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5^2=
  input = @"5^2=";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(1, 1)]];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5.2^2.3=
  input = @"5.2^2.3=";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(3, 1)]];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 2+-5.2^2.3=
  input = @"2+-5.2^2.3=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(1, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(6, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 100+200+300+400+500+600=
  input = @"100+200+300+400+500+600=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 3, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 7, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(11, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(15, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(19, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 100+200+300+400+500+600=
  input = @"10.0+20.0+30.0+40.0+50.0+60.0=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 4, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 9, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(14, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(19, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(24, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -2.5+-75/90*-3.0^8=
  input = @"-2.5+-75/90*-3.0^8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 4, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 8, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(11, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(16, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] operatorRanges];
  NSAssert([output isEqualToSet:expected], @"");
}

+(void)__executeExpressionTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  
  // MARK: Test 1
  input = @"200=";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 4)]];
  output = [[SVRSolverScanner scannerWithString:input] expressionRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 2
  input = @"200=400=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(4, 4)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] expressionRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 3
  input = @"1+2-3*4/5^6=7^8/9*10-11+12=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 12)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 15)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] expressionRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 4
  input = @"/*This*/2+3=/*That*/4+5=/*Other*/6+7=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(6, 6)],
              [NSValue XP_valueWithRange:NSMakeRange(18, 6)],
              [NSValue XP_valueWithRange:NSMakeRange(31, 6)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] expressionRanges];
  NSAssert([output isEqualToSet:expected], @"");
}

+(void)__executeBracketTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  
  // MARK: Test (200)=
  input = @"(200)=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(4, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] bracketRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test (2.0+3.0/4.0)+8=
  input = @"(2.0+3.0/4.0)+8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] bracketRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test -5/(2.0+3.0/4.0)+8=
  input = @"-5/(2.0+3.0/4.0)+8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(3, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(15, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] bracketRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test (500)+(200)-(300)/(400)^(2)=
  input = @"(500)+(200)-(300)/(400)^(2)=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 4, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 6, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(10, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(16, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(18, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(22, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(24, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(26, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] bracketRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test ((3)+(4))=
  // Known negative test
  input = @"((3)+(4))=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(1, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(3, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(5, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] bracketRanges];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test (5+3+(7+8)-3)=
  // Known negative test
  input = @"(5+3+(7+8)-3)=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 5, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 9, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 1)],
              nil];
  output = [[SVRSolverScanner scannerWithString:input] bracketRanges];
  NSAssert([output isEqualToSet:expected], @"");
}

@end
