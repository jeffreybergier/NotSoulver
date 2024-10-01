//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRDocumentStringEnumerator.h"
#import "SVRCrossPlatform.h"

BOOL NSContainsRange(NSRange lhs, NSRange rhs) {
  return (lhs.location <= rhs.location) && (NSMaxRange(lhs) >= NSMaxRange(rhs));
}

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
  NSMutableArray *output = [[NSMutableArray new] autorelease];
  NSRange range = XPNotFoundRange;
  NSValue *rangeV = nil;
  NSDecimalNumber *number = nil;
  SVRLegacyRegex *regex = nil;
  SVRLegacyRegex *n_regex = nil; // for testing negative numbers to make sure they are preceded by an operator

  // Find positive floats
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d+\\.\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    number = [NSDecimalNumber decimalNumberWithString:[_string substringWithRange:range]];
    [XPLog extra:@"<#> '%@' '%@'→'%@'", _string, [number SVR_description], [_string substringWithRange:range]];
    [self __addRange:range toArray:output];
  }
  
  // Find positive integers
  regex = [SVRLegacyRegex regexWithString:_string pattern:@"\\d+"];
  while ((rangeV = [regex nextObject])) {
    range = [rangeV XP_rangeValue];
    number = [NSDecimalNumber decimalNumberWithString:[_string substringWithRange:range]];
    [XPLog extra:@"<#> '%@' '%@'→'%@'", _string, [number SVR_description], [_string substringWithRange:range]];
    [self __addRange:range toArray:output];
  }
  
  _numbers = [[output objectEnumerator] retain];
}

-(void)__addRange:(NSRange)rhs toArray:(NSMutableArray*)array;
{
  BOOL shouldAdd = YES;
  NSEnumerator *e = nil;
  NSValue *next = nil;
  NSRange lhs = XPNotFoundRange;
  [array retain];
  e = [array objectEnumerator];
  while ((next = [e nextObject])) {
    lhs = [next XP_rangeValue];
    shouldAdd = !NSContainsRange(lhs, rhs);
    if (!shouldAdd) { break; }
  }
  if (shouldAdd) {
    [array addObject:[NSValue XP_valueWithRange:rhs]];
  }
  [array autorelease];
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
  [self __executeNumberTests];
}

+(void)__executeNumberTests;
{
  NSString *input = nil;
  NSArray *output = nil;
  NSArray *expected = nil;
  SVRDocumentStringEnumerator *e = nil;
  
  [XPLog alwys:@"SVRDocumentStringEnumerator Tests: NSUnimplemented"];
  
  // MARK: Test 200
  input = @"200";
  expected = [NSArray arrayWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 3)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [[e numberEnumerator] allObjects];
  NSAssert([output count] == 1, @"");
  NSAssert([output isEqualToArray:expected], @"");
  
  // MARK: Test 23.78
  input = @"23.78";
  expected = [NSArray arrayWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 5)]];
  e = [SVRDocumentStringEnumerator enumeratorWithString:input];
  output = [[e numberEnumerator] allObjects];
  NSAssert([output count] == 1, @"");
  NSAssert([output isEqualToArray:expected], @"");
}

@end
