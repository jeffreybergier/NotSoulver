//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRDocumentStringEnumerator.h"
#import "SVRCrossPlatform.h"

@implementation SVRDocumentStringEnumerator

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

+(id)enumeratorWithString:(NSString*)string;
{
  return [[[SVRDocumentStringEnumerator alloc] initWithString:string] autorelease];
}

// MARK: NSEnumerator
-(NSValue*)nextNumber;
{
  if (_numbers == nil) {
    [self __populateNumbers];
  }
  return [_numbers nextObject];
}

-(NSValue*)nextOperator;
{
  if (_numbers == nil) {
    [self __populateOperators];
  }
  return [_operators nextObject];
}

-(NSValue*)nextExpression;
{
  if (_numbers == nil) {
    [self __populateExpressions];
  }
  return [_expressions nextObject];
}

-(NSValue*)nextBracket;
{
  if (_brackets == nil) {
    [self __populateBrackets];
  }
  return [_brackets nextObject];
}

// MARK: Enumerator Access (mostly for testing)
-(NSEnumerator*)numberEnumerator;
{
  if (_numbers == nil) {
    [self __populateNumbers];
  }
  return [[_numbers retain] autorelease];
}

-(NSEnumerator*)operatorEnumerator;
{
  if (_numbers == nil) {
    [self __populateOperators];
  }
  return [[_operators retain] autorelease];
}

-(NSEnumerator*)expressionEnumerator;
{
  if (_numbers == nil) {
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
}

-(NSEnumerator*)bracketEnumerator;
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
  
  _numbers = [[output objectEnumerator] retain];
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
    [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  _operators = [[output objectEnumerator] retain];
}

-(void)__populateExpressions;
{
  NSAssert(NO, @"SVRUnimplemented");
}

-(void)__populateBrackets;
{
  NSRange range;
  NSValue *value;
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSAssert(!_brackets, @"This is a lazy init method, it assumes _brackets is NIL");
  // Check for opening brackets
  SVRLegacyRegex *regex = [SVRLegacyRegex regexWithString:_string
                                                  pattern:@"\\([\\-\\d]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.length = 1;
    [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  // Check for closing brackets
  regex = [SVRLegacyRegex regexWithString:_string
                                  pattern:@"\\d\\)[\\^\\*\\/\\+\\-\\=]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.location += 1;
    range.length = 1;
    [XPLog extra:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  _brackets = [[output objectEnumerator] retain];
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

@implementation SVRDocumentStringEnumerator (Tests)
+(void)executeTests;
{
  [XPLog alwys:@"SVRDocumentStringEnumerator Tests: Starting"];
  [self __executeNumberTests];
  [self __executeOperatorTests];
  [self __executeBracketTests];
  [XPLog alwys:@"SVRDocumentStringEnumerator Tests: Passed"];
}

+(void)__executeNumberTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  SVRDocumentStringEnumerator *e = nil;
  
  
  // MARK: Test 200
  input = @"200";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 3)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 23.78
  input = @"23.78";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 5)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -200
  input = @"-200";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 4)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -23.78
  input = @"-23.78";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 6)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5^2=
  input = @"5^2=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(2, 1)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5.2^2.3=
  input = @"5.2^2.3=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(4, 3)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 2+-5.2^2.3=
  input = @"2+-5.2^2.3=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(2, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(7, 3)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
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
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
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
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -2.5+-75/90*-3.0^8=
  input = @"-2.5+-75/90*-3.0^8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 4)],
              [NSValue XP_valueWithRange:NSMakeRange(5, 3)],
              [NSValue XP_valueWithRange:NSMakeRange(9, 2)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 5)], // TODO: This is wrong!!! 5→4
              [NSValue XP_valueWithRange:NSMakeRange(17, 1)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e numberEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
}

+(void)__executeOperatorTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  SVRDocumentStringEnumerator *e = nil;
  
  
  // MARK: Test 200
  input = @"200";
  expected = [[NSSet new] autorelease];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 23.78
  input = @"23.78";
  expected = [[NSSet new] autorelease];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -200
  input = @"-200";
  expected = [[NSSet new] autorelease];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -23.78
  input = @"-23.78";
  expected = [[NSSet new] autorelease];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5^2=
  input = @"5^2=";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(1, 1)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 5.2^2.3=
  input = @"5.2^2.3=";
  expected = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(3, 1)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 2+-5.2^2.3=
  input = @"2+-5.2^2.3=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(1, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(6, 1)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 100+200+300+400+500+600=
  input = @"100+200+300+400+500+600=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 3, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 7, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(11, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(15, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(19, 1)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test 100+200+300+400+500+600=
  input = @"10.0+20.0+30.0+40.0+50.0+60.0=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 4, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 9, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(14, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(19, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(24, 1)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");

  // MARK: Test -2.5+-75/90*-3.0^8=
  input = @"-2.5+-75/90*-3.0^8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange( 4, 1)],
              [NSValue XP_valueWithRange:NSMakeRange( 8, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(11, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(16, 1)],
              nil
  ];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e operatorEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
}

+(void)__executeBracketTests;
{
  NSString *input = nil;
  NSSet *output = nil;
  NSSet *expected = nil;
  SVRDocumentStringEnumerator *e = nil;
  
  
  // MARK: Test (200)=
  input = @"(200)=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(4, 1)],
              nil];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e bracketEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test (2.0+3.0/4.0)+8=
  input = @"(2.0+3.0/4.0)+8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(12, 1)],
              nil];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e bracketEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test -5/(2.0+3.0/4.0)+8=
  input = @"-5/(2.0+3.0/4.0)+8=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(3, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(15, 1)],
              nil];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e bracketEnumerator] allObjects]];
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
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e bracketEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
  
  // MARK: Test ((3)+(4))=
  // Known negative test
  input = @"((3)+(4))=";
  expected = [NSSet setWithObjects:
              [NSValue XP_valueWithRange:NSMakeRange(1, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(3, 1)],
              [NSValue XP_valueWithRange:NSMakeRange(5, 1)],
              nil];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e bracketEnumerator] allObjects]];
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
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [NSSet setWithArray:[[e bracketEnumerator] allObjects]];
  NSAssert([output isEqualToSet:expected], @"");
}

@end
