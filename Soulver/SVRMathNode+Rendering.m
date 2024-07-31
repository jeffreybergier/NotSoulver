//
//  SVRMathNode+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathNode+Rendering.h"

@implementation SVRMathNode (Rendering)

-(BOOL)isStructureValid;
{
  NSSet *equals;
  NSSet *operators;
  NSSet *decimals;
  NSString *lhs;
  NSString *rhs;
  SVRMathNode *next;

  equals = [self __equals];[[[self __operators] mutableCopy] autorelease];
  operators = [self __operators];
  decimals = [self __decimals];
  lhs = [self value];
  if ([equals member:lhs] || [operators member:lhs]) {
    return NO;
  }
  next = [self nextNode];
  while (next) {
    rhs = [next value];
    if ([operators member:lhs] && [equals member:rhs]) {
      return NO;
    }
    if ([equals member:lhs] && [equals member:rhs]) {
      return NO;
    }
    if ([operators member:lhs] && [operators member:rhs]) {
      return NO;
    }
    if ([decimals member:lhs] && [decimals member:rhs]) {
      return NO;
    }
    lhs = [next value];
    rhs = nil;
    next = [next nextNode];
  }
  return YES;
}

-(NSString*)render;
{
  return [self isStructureValid]
       ? [self __PRIVATE_renderValid]
       : [self __PRIVATE_renderNaive];
}

-(NSString*)__PRIVATE_renderValid;
{
  NSSet *operators;
  NSSet *numerals;
  NSSet *equals;
  NSMutableString *output;
  NSMutableString *lhs;
  NSMutableString *rhs;
  NSString *operator1;
  SVRMathNode *next;
  NSString *nextValue;
  NSString *nextNextValue;
  NSString *mathString;

  operators = [self __operators];
  numerals = [self __numerals];
  equals = [self __equals];
  output = [[[self value] mutableCopy] autorelease];
  lhs = [[[self value] mutableCopy] autorelease];
  rhs = [NSMutableString new];
  operator1 = nil;
  next = [self nextNode];
  while (next) {
    nextValue = [next value];
    [output appendString:nextValue];
    if ([numerals member:nextValue] && !operator1) {
      // 1. Build the left hand side numbers
      [lhs appendString:nextValue];
    } else if ([numerals member:nextValue] && operator1) {
      // 2. Build the right hand side numbers
      [rhs appendString:nextValue];
    } else if ([operators member:nextValue] && !operator1) {
      // 3. Configure the operator
      operator1 = nextValue;
    } else if ([operators member:nextValue] && operator1) {
      // 4. 2nd operator found: Do the calculation
      // But don't change the output of the rendering
      lhs = [NSMutableString stringWithFormat:@"%f", [self __PRIVATE_doMathWithOperator:operator1 lhs:lhs rhs:rhs]];
      rhs = [NSMutableString new];
      operator1 = nextValue;
    } else if ([equals member:nextValue] && operator1) {
      // 4. 2nd operator found: Do the calculation
      // But do add the result into the output of the rendering
      mathString = [NSString stringWithFormat:@"%f", [self __PRIVATE_doMathWithOperator:operator1 lhs:lhs rhs:rhs]];
      [output appendString:[NSString stringWithFormat:@"%@\n", mathString]];
      // 4.1 Check the next next value and see if it is an operator
      nextNextValue = [[next nextNode] value];
      if ([operators member:nextNextValue]) {
        // If it is an operator, then prepare to continue doing math
        [output appendString:[NSString stringWithFormat:@"<%@>", mathString]];
        lhs = [[mathString mutableCopy] autorelease];
        rhs = [NSMutableString new];
        operator1 = nil;
        nextNextValue = nil;
        mathString = nil;
      } else {
        // If not an operator, set up math as new
        lhs = [NSMutableString new];
        rhs = [NSMutableString new];
        operator1 = nil;
        nextNextValue = nil;
        mathString = nil;
      }
    } else {
      NSAssert(NO, @"The else statement should never be hit");
    }
    next = [next nextNode];
  }
  return [[output copy] autorelease];
}
-(NSString*)__PRIVATE_renderNaive;
{
  // If Structure is Invalid, just print everything in a dumb way
  NSMutableString *output = [[self value] mutableCopy];
  SVRMathNode *next = [[self nextNode] retain];
  while (next) {
    [output appendString:[next value]];
    next = [[[next autorelease] nextNode] retain];
  }
  return [NSString stringWithFormat:@"%@<Invalid>", [output autorelease]];
}

-(double)__PRIVATE_doMathWithOperator:(NSString*)operator lhs:(NSString*)lhs rhs:(NSString*)rhs;
{
  if ([operator isEqualToString:@"/"]) {
    return [lhs doubleValue] / [rhs doubleValue];
  } else if ([operator isEqualToString:@"*"]) {
    return [lhs doubleValue] * [rhs doubleValue];
  } else if ([operator isEqualToString:@"+"]) {
    return [lhs doubleValue] + [rhs doubleValue];
  } else if ([operator isEqualToString:@"-"]) {
    return [lhs doubleValue] - [rhs doubleValue];
  } else {
    NSAssert(NO, @"The else statement should never be hit");
    return -1;
  }
}

// MARK: Rendering Checks
-(NSSet*)__numerals;
{
  return [NSSet setWithObjects:@"0", @"1", @"2", @"3", @"4", @"5",
          @"6", @"7", @"8", @"9", @".", nil];
}
-(NSSet*)__operators;
{
  return [NSSet setWithObjects:@"/", @"*", @"+", @"-", nil];
}
-(NSSet*)__equals;
{
  return [NSSet setWithObjects:@"=", nil];
}
-(NSSet*)__decimals;
{
  return [NSSet setWithObjects:@".", nil];
}

@end
