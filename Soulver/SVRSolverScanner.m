//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverScanner.h"
#import "TinyRegex.h"

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
  if (!_numbers) {
    [self __populateNumbers];
  }
  return [[_numbers retain] autorelease];
}

-(NSSet*)operatorRanges;
{
  if (!_operators) {
    [self __populateOperators];
  }
  return [[_operators retain] autorelease];
}

-(NSSet*)expressionRanges;
{
  if (!_expressions) {
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
}

-(NSSet*)bracketRanges;
{
  if (!_brackets) {
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
  SLRERegex *regex = nil;
  SLRERegexMatch *match = nil;

  NSAssert(!_numbers, @"This is a lazy init method, it assumes _numbers is NIL");
  
  // Find negative floats
  regex = [SLRERegex SVR_regexForNumbersInString:_string];
  while ((match = [regex nextObject])) {
    range = [match range];
    // TODO: Check for the case of )-400 counting as negative 400
    [XPLog debug:@"<#> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
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
  TinyRegex *regex = [TinyRegex regexWithString:_string
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
  // TODO: Why isn't this being called?
  NSRange range = XPNotFoundRange;
  NSValue *value = nil;
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  TinyRegex *regex = [TinyRegex regexWithString:_string
                                                  pattern:@"[\\d\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
  NSAssert(!_expressions, @"This is a lazy init method, it assumes _expressions is NIL");
  while ((value = [regex nextObject])) {
    // Trim the = sign off
    range = [value XP_rangeValue];
    range.length -= 1;
    [XPLog extra:@"<=> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  _expressions = [output copy];
}

-(void)__populateBrackets;
{
  NSRange range;
  NSValue *value;
  TinyRegex *regex = nil;
  NSMutableSet *output = [[NSMutableSet new] autorelease];
  NSAssert(!_brackets, @"This is a lazy init method, it assumes _brackets is NIL");

  // Check for opening brackets
  regex = [TinyRegex regexWithString:_string pattern:@"\\([\\-\\d]"];
  while ((value = [regex nextObject])) {
    range = [value XP_rangeValue];
    range.length = 1;
    [XPLog extra:@"<(> %@", [_string SVR_descriptionHighlightingRange:range]];
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  
  // Check for closing brackets
  regex = [TinyRegex regexWithString:_string pattern:@"\\d\\)[\\^\\*\\/\\+\\-\\=]"];
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
  [XPLog extra:@"DEALLOC: %@", self];
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

@implementation SLRERegex (Soulver)

+(id)SVR_regexForNumbersInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"\\-?\\d+(\\.\\d+)*"];
}
+(id)SVR_regexForOperatorsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"[\\)0123456789](\\+|\\-|\\/|\\*|\\^)[\\(0123456789]"
                    groupCount:1
                          mode:SLRERegexAdvanceAfterGroup];
}

+(id)SVR_regexForExpressionsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"[0123456789\\.\\^\\*\\-\\+\\/\\(\\)]+\\="];
}

+(id)SVR_regexForLeftBracketsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"(\\()[\\-0123456789]"
                    groupCount:1
                          mode:SLRERegexAdvanceAfterGroup];
}

+(id)SVR_regexForRightBracketsInString:(NSString*)string;
{
  return [self regexWithString:string
                       pattern:@"\\d(\\))"
                    groupCount:1
                          mode:SLRERegexAdvanceAfterGroup];
}

@end
