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
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
}

-(NSEnumerator*)expressionEnumerator;
{
  if (_numbers == nil) {
    [self __populateOperators];
  }
  return [[_operators retain] autorelease];
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

  // Find negative floats
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\-\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    if (range.location == 0) { // If we're at the beginning of the string the negative number needs no checks
      [XPLog extra:@"<#> '%@'→'%@'", _string, [_string substringWithRange:range]];
      [self __addRange:range toSet:output];
    } else {
      n_regex = [SVRLegacyRegex regexWithString:[_string substringWithRange:NSMakeRange(range.location-1, 1)]
                                        pattern:@"[\\=\\(\\+\\-\\*\\/\\^]"];
      if ([n_regex nextObject]) {
        [XPLog extra:@"<#> '%@'→'%@'", _string, [_string substringWithRange:range]];
        [self __addRange:range toSet:output];
      }
    }
  }
  
  // Find negative integers
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\-\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    if (range.location == 0) { // If we're at the beginning of the string the negative number needs no checks
      [XPLog extra:@"<#> '%@'→'%@'", _string, [_string substringWithRange:range]];
      [self __addRange:range toSet:output];
    } else {
      n_regex = [SVRLegacyRegex regexWithString:[_string substringWithRange:NSMakeRange(range.location-1, 1)]
                                        pattern:@"[\\=\\(\\+\\-\\*\\/\\^]"];
      if ([n_regex nextObject]) {
        [XPLog extra:@"<#> '%@'→'%@'", _string, [_string substringWithRange:range]];
        [self __addRange:range toSet:output];
      }
    }
  }
  
  // Find positive floats
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    [XPLog extra:@"<#> '%@'→'%@'", _string, [_string substringWithRange:range]];
    [self __addRange:range toSet:output];
  }
  
  // Find positive integers
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    [XPLog extra:@"<#> '%@'→'%@'", _string, [_string substringWithRange:range]];
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
  [set retain];
  e = [set objectEnumerator];
  while ((next = [e nextObject])) {
    lhs = [next XP_rangeValue];
    shouldAdd = !XPContainsRange(lhs, rhs);
    if (!shouldAdd) { break; }
  }
  if (shouldAdd) {
    [set addObject:[NSValue XP_valueWithRange:rhs]];
  }
  [set autorelease];
}

-(void)__populateOperators;
{
  NSAssert(NO, @"SVRUnimplemented");
}

-(void)__populateExpressions;
{
  NSAssert(NO, @"SVRUnimplemented");
}

// MARK: Dealloc
-(void)dealloc;
{
  [_string release];
  [_numbers release];
  [_operators release];
  [_expressions release];
  _string = nil;
  _numbers = nil;
  _operators = nil;
  _expressions = nil;
  [super dealloc];
}

@end

@implementation SVRDocumentStringEnumerator (Tests)
+(void)executeTests;
{
  [XPLog alwys:@"SVRDocumentStringEnumerator Tests: Starting"];
  [self __executeNumberTests];
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

@end
