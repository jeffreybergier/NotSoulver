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
  NSAssert(NO, @"SVRUnimplemented");
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
  NSAssert([output count] > 0, @"");
  NSAssert([output isEqualToArray:expected], @"");
}

@end
