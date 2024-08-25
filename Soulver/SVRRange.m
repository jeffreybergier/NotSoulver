//
//  SVRRange.m
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/22.
//

#import "SVRRange.h"
#import "SVRConstants.h"
#import "NSString+Soulver.h"

// MARK: Custom Ranges
@implementation SVRBoundingRange
-(NSRange)range;
{
  return _range;
}
-(NSString*)contents;
{
  return _contents;
}
-(id)initWithRange:(NSRange)range contents:(NSString*)contents;
{
  self = [super init];
  _range = range;
  _contents = [contents retain];
  return self;
}
+(id)rangeWithRange:(NSRange)range contents:(NSString*)contents;
{
  return [[[SVRBoundingRange alloc] initWithRange:range
                                         contents:contents] autorelease];
}
-(NSString*)description;
{
  return [NSString stringWithFormat:@"SVRBoundingRange: \"%@\" {%lu, %lu}",
                                    _contents, _range.location, _range.length];
}
- (void)dealloc
{
  [_contents release];
  [super dealloc];
}
@end

@implementation SVRMathRange
-(NSRange)range;
{
  return _range;
}
-(NSString*)lhs;
{
  return _lhs;
}
-(NSString*)rhs;
{
  return _rhs;
}
-(NSString*)operator;
{
  return _operator;
}
-(id)initWithRange:(NSRange)range lhs:(NSString*)lhs rhs:(NSString*)rhs operator:(NSString*)operator;
{
  self = [super init];
  _range = range;
  _lhs = [lhs retain];
  _rhs = [rhs retain];
  _operator = [operator retain];
  return self;
}
+(id)rangeWithRange:(NSRange)range lhs:(NSString*)lhs rhs:(NSString*)rhs operator:(NSString*)operator;
{
  return [[[SVRMathRange alloc] initWithRange:range
                                          lhs:lhs
                                          rhs:rhs
                                     operator:operator] autorelease];
}
-(NSDecimalNumber*)evaluate;
{
  NSDecimalNumber *lhs = [NSDecimalNumber
                          decimalNumberWithString:[self lhs]
                          locale:[NSDictionary SVR_numberLocale]];
  NSDecimalNumber *rhs = [NSDecimalNumber
                          decimalNumberWithString:[self rhs]
                          locale:[NSDictionary SVR_numberLocale]];
  NSString *operator = [self operator];
  
  if ([operator isEqualToString:@"d"]) {
    return [lhs decimalNumberByDividingBy:rhs];
  } else if ([operator isEqualToString:@"m"]) {
    return [lhs decimalNumberByMultiplyingBy:rhs];
  } else if ([operator isEqualToString:@"a"]) {
    return [lhs decimalNumberByAdding:rhs];
  } else if ([operator isEqualToString:@"s"]) {
    return [lhs decimalNumberBySubtracting:rhs];
  } else if ([operator isEqualToString:@"e"]) {
    if ([rhs intValue] < 0) {
      return [[NSDecimalNumber decimalNumberWithString:@"1"]
              decimalNumberByDividingBy:
                [lhs decimalNumberByRaisingToPower:labs([rhs longValue])]];
    } else {
      return [lhs decimalNumberByRaisingToPower:[rhs unsignedIntValue]];
    }
  } else {
    [NSException raise:@"InvalidArgumentException" format:@"Unsupported Operator: %@", operator];
    return nil;
  }
}
-(NSString*)description;
{
  return [NSString stringWithFormat:@"SVRMathRange: <%@><%@><%@> {%lu, %lu}",
                                    _lhs, _operator, _rhs, _range.location, _range.length];
}
- (void)dealloc
{
  [_lhs release];
  [_rhs release];
  [_operator release];
  [super dealloc];
}
@end

// MARK: NSString Custom Range Search
@implementation NSString (Searching)

-(SVRBoundingRange*)SVR_searchRangeBoundedByLHS:(NSString*)lhs
                                            rhs:(NSString*)rhs
                                          error:(NSNumber**)error;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorRange *next;
  NSMutableArray *foundLHS;
  SVRStringEnumeratorRange *foundRHS;
  NSRange outputRange;
  NSString *outputContents;
  int balanceCounter;
  
  if (*error) { return nil; }
  
  foundLHS = [[NSMutableArray new] autorelease];
  foundRHS = nil;
  e = [SVRStringEnumerator enumeratorWithString:self];
  balanceCounter = 0;
  
  while ((next = [e nextObject])) {
    if ([[next substring] isEqualToString:lhs]) {
      balanceCounter = balanceCounter + 1;
      if (foundRHS == nil) {
        [foundLHS addObject:next];
      }
    } else if ([[next substring] isEqualToString:rhs]) {
      balanceCounter = balanceCounter - 1;
      if (foundRHS == nil) {
        foundRHS = next;
      }
    }
  }
  
  if (balanceCounter != 0) {
    *error = [NSNumber SVR_errorMismatchedBrackets];
    return nil;
  } else if ([foundLHS count] == 0 && foundRHS == nil) {
    return nil;
  } else {
    outputRange = NSMakeRange(0, 0);
    outputRange.location = [[foundLHS lastObject]  range].location;
    outputRange.length   = [foundRHS               range].location
    - [[foundLHS lastObject]  range].location
    + 1;
    outputContents = [self substringWithRange:
                        NSMakeRange(outputRange.location + 1,
                                    outputRange.length - 2)
    ];
    return [SVRBoundingRange rangeWithRange:outputRange contents:outputContents];
  }
}

-(SVRMathRange*)SVR_searchMathRangeForOperators:(NSSet*)including
                           allPossibleOperators:(NSSet*)ignoring
                            allPossibleNumerals:(NSSet*)numerals;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorRange *next;
  NSRange outputRange;
  NSMutableString *lhs;
  NSMutableString *rhs;
  NSString *operator;
  
  e = [SVRStringEnumerator enumeratorWithString:self];
  
  outputRange = NSMakeRange(0, 0);
  lhs = [[NSMutableString new] autorelease];
  rhs = [[NSMutableString new] autorelease];
  operator = nil;

  while ((next = [e nextObject])) {
    if        (operator == nil && [numerals  member:[next substring]]) {
      [lhs appendString:[next substring]];
      outputRange.length += 1;
    } else if (operator != nil && [numerals  member:[next substring]]) {
      [rhs appendString:[next substring]];
      outputRange.length += 1;
    } else if (operator == nil && [including member:[next substring]]) {
      operator = [next substring];
      outputRange.length += 1;
    } else if (operator == nil && [ignoring  member:[next substring]]) {
      lhs = [[NSMutableString new] autorelease];
      outputRange.location = [next range].location + 1;
      outputRange.length = 0;
    } else if (operator != nil && [ignoring  member:[next substring]]) {
      break;
    } else { // invalid character, bail
      return nil;
    }
  }
  
  if ([lhs length] > 0 && [rhs length] > 0 && [operator length] > 0) {
    return [SVRMathRange rangeWithRange:outputRange lhs:lhs rhs:rhs operator:operator];
  } else {
    return nil;
  }
}
@end
