//
//  SVRMathString+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathString+Rendering.h"
#import "Foundation+Soulver.h"

@implementation SVRMathString (Rendering)

-(NSAttributedString*)render;
{
  return [self __preparePEMDASLines];
}

-(NSAttributedString*)renderRaw;
{
  NSRange scanRange;
  unsigned int scanMax;
  NSMutableAttributedString *output;
  NSString *scanString;
  
  scanRange = NSMakeRange(0,1);
  scanMax = [_string length];
  output = [[NSMutableAttributedString new] autorelease];
  
  while (scanRange.location < scanMax) {
    scanString = [_string substringWithRange:scanRange];
    [output appendAttributedString:[NSAttributedString withString:scanString]];
    scanRange.location += 1;
  }
  [output appendAttributedString: [NSAttributedString withString:@"<NAIVE>"
                                                        andColor: [NSColor orangeColor]]];
  return [[output copy] autorelease];
}

-(NSAttributedString*)__preparePEMDASLines;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorObject *next;
  NSMutableString *lineBuilder;
  NSMutableAttributedString *output;

  if (_string == nil || [_string length] == 0) {
    return [[NSAttributedString new] autorelease];
  }
  
  e = [SVRStringEnumerator enumeratorWithString:_string];
  next = [e nextObject];
  
  lineBuilder = [[NSMutableString new] autorelease];
  output = [[NSMutableAttributedString new] autorelease];
  
  while (next) {
    [output appendAttributedString:[NSAttributedString withString:[next substring]]];
    if ([[next substring] isEqualToString:@"="]) {
      NSString *_solution = [self __solvePEMDASLine:[[lineBuilder copy] autorelease]];
      NSAttributedString *toAppend = [NSAttributedString withString:[NSString stringWithFormat:@"%@", _solution]
                                                           andColor:[NSColor cyanColor]];
      [output appendAttributedString:toAppend];
      [output appendAttributedString:[NSAttributedString withString:@"\n"]];
      lineBuilder = [[NSMutableString new] autorelease];
      next = [e nextObject];
      if ([[self __operators] member:[next substring]]) {
        // The next line has an operator so I need to put this line's answer first
        [lineBuilder appendString:_solution];
        [output appendAttributedString:toAppend];
      }
    } else {
      [lineBuilder appendString:[next substring]];
      next = [e nextObject];
    }
  }
  
  return [[output copy] autorelease];
}

-(NSString*)__solvePEMDASLine:(NSString*)input;
{  
  SVRBoundingRange *parenRange;
  SVRMathRange *mathRange;
  NSString *analyzedSolution;
  NSMutableString *output;

  if (input == nil || [input length] == 0) { 
    return @""; 
  }
  NSLog(@"Analyzing: %@", input);
  output = [[input mutableCopy] autorelease];
  // PEMDAS
  // Parantheses
  parenRange = [output boundingRangeWithLHS:@"(" andRHS:@")"];
  while (parenRange) {
    analyzedSolution = [self __solvePEMDASLine:[parenRange contents]];
    [output replaceCharactersInRange:[parenRange range] withString:analyzedSolution];
    NSLog(@"Patch (): %@", output);
    parenRange = [output boundingRangeWithLHS:@"(" andRHS:@")"];
  }
  
  // Exponents
  mathRange = [output mathRangeByMonitoringSet:[self __exponent] ignoringSet:[self __operators]];
  while (mathRange) {
    analyzedSolution = [NSString stringWithFormat:@"%g", [self __performCalculationWithRange:mathRange]];
    [output replaceCharactersInRange:[mathRange range] withString:analyzedSolution];
    NSLog(@"Patch ^^: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[self __exponent] ignoringSet:[self __operators]];
  }
  
  // Multiply and Divide
  mathRange = [output mathRangeByMonitoringSet:[self __multdiv] ignoringSet:[self __operators]];
  while (mathRange) {
    analyzedSolution = [NSString stringWithFormat:@"%g", [self __performCalculationWithRange:mathRange]];
    [output replaceCharactersInRange:[mathRange range] withString:analyzedSolution];
    NSLog(@"Patch */: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[self __multdiv] ignoringSet:[self __operators]];
  }
  
  // Add and Subtract
  mathRange = [output mathRangeByMonitoringSet:[self __plusminus] ignoringSet:[self __operators]];
  while (mathRange) {
    analyzedSolution = [NSString stringWithFormat:@"%g", [self __performCalculationWithRange:mathRange]];
    [output replaceCharactersInRange:[mathRange range] withString:analyzedSolution];
    NSLog(@"Patch +-: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[self __plusminus] ignoringSet:[self __operators]];
  }
  
  NSLog(@"Finished: %@", output);
  return [[output copy] autorelease];
}

-(double)__performCalculationWithRange:(SVRMathRange*)range;
{
  NSString *lhs = [range lhs];
  NSString *rhs = [range rhs];
  NSString *operator = [range operator];
  
  if ([operator isEqualToString:@"/"]) {
    return [lhs doubleValue] / [rhs doubleValue];
  } else if ([operator isEqualToString:@"*"]) {
    return [lhs doubleValue] * [rhs doubleValue];
  } else if ([operator isEqualToString:@"+"]) {
    return [lhs doubleValue] + [rhs doubleValue];
  } else if ([operator isEqualToString:@"-"]) {
    return [lhs doubleValue] - [rhs doubleValue];
  } else if ([operator isEqualToString:@"^"]) {
    return pow([lhs doubleValue],[rhs doubleValue]);
  } else {
    NSAssert(NO, @"The else statement should never be hit");
    return -1;
  }
}

// MARK: Rendering Checks
-(NSSet*)__operators;
{
  return [NSSet setWithObjects:@"/", @"*", @"+", @"-", @"^", nil];
}
-(NSSet*)__plusminus;
{
  return [NSSet setWithObjects:@"+", @"-", nil];
}
-(NSSet*)__multdiv;
{
  return [NSSet setWithObjects:@"/", @"*", nil];
}
-(NSSet*)__exponent;
{
  return [NSSet setWithObjects:@"^", nil];
}

@end
