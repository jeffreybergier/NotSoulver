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
  NSAttributedString *output;
  NSNumber *error = nil;
  output = [self __preparePEMDASLinesWithError:&error];
  if (output == nil) {
    NSLog(@"Error: %@", error);
    output = [self renderRaw];
  }
  return output;
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
  [output appendAttributedString: [NSAttributedString withString:@"<ERROR>"
                                                        andColor: [NSColor orangeColor]]];
  return [[output copy] autorelease];
}

-(NSAttributedString*)__preparePEMDASLinesWithError:(NSNumber**)error;
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
  
  while (next && *error == nil) {
    [output appendAttributedString:[NSAttributedString withString:[next substring]]];
    if ([[next substring] isEqualToString:@"="]) {
      NSString *_solution = [self __solvePEMDASLine:[[lineBuilder copy] autorelease] error:error];
      NSAttributedString *toAppend = [NSAttributedString withString:[NSString stringWithFormat:@"%@", _solution]
                                                           andColor:[NSColor cyanColor]];
      [output appendAttributedString:toAppend];
      [output appendAttributedString:[NSAttributedString withString:@"\n"]];
      lineBuilder = [[NSMutableString new] autorelease];
      next = [e nextObject];
      if ([[NSSet SVROperators] member:[next substring]]) {
        // The next line starts with an operator so I need to put this line's answer first
        [lineBuilder appendString:_solution];
        [output appendAttributedString:toAppend];
      }
    } else {
      [lineBuilder appendString:[next substring]];
      next = [e nextObject];
    }
  }
  
  if (*error) {
    return nil;
  }
  
  return [[output copy] autorelease];
}

-(NSString*)__solvePEMDASLine:(NSString*)input error:(NSNumber**)error;
{
  SVRBoundingRange *parenRange;
  SVRMathRange *mathRange;
  NSString *solutionString;
  NSNumber *solutionNumber;
  NSMutableString *output;
  
  if (*error) {
    return nil;
  }

  if (input == nil || [input length] == 0) { 
    return @""; 
  }
  NSLog(@"Analyzing: %@", input);
  output = [[input mutableCopy] autorelease];
  // PEMDAS
  // Parantheses
  parenRange = [output boundingRangeWithLHS:@"(" andRHS:@")" error:error];
  while (parenRange && *error == NULL) {
    solutionString = [self __solvePEMDASLine:[parenRange contents] error:error];
    [output replaceCharactersInRange:[parenRange range] withString:solutionString];
    NSLog(@"Patch (): %@", output);
    parenRange = [output boundingRangeWithLHS:@"(" andRHS:@")" error:error];
  }
  
  // Exponents
  mathRange = [output mathRangeByMonitoringSet:[NSSet SVRExponent]
                                   ignoringSet:[NSSet SVROperators]];
  while (mathRange && *error == NULL) {
    solutionNumber = [self __performCalculationWithRange:mathRange error:error];
    solutionString = [NSString stringWithFormat:@"%g", [solutionNumber doubleValue]];
    [output replaceCharactersInRange:[mathRange range] withString:solutionString];
    NSLog(@"Patch ^^: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[NSSet SVRExponent]
                                     ignoringSet:[NSSet SVROperators]];
  }
  
  // Multiply and Divide
  mathRange = [output mathRangeByMonitoringSet:[NSSet SVRMultDiv]
                                   ignoringSet:[NSSet SVROperators]];
  while (mathRange && *error == NULL) {
    solutionNumber = [self __performCalculationWithRange:mathRange error:error];
    solutionString = [NSString stringWithFormat:@"%g", [solutionNumber doubleValue]];
    [output replaceCharactersInRange:[mathRange range] withString:solutionString];
    NSLog(@"Patch */: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[NSSet SVRMultDiv]
                                     ignoringSet:[NSSet SVROperators]];
  }
  
  // Add and Subtract
  mathRange = [output mathRangeByMonitoringSet:[NSSet SVRPlusMinus]
                                   ignoringSet:[NSSet SVROperators]];
  while (mathRange && *error == NULL) {
    solutionNumber = [self __performCalculationWithRange:mathRange error:error];
    solutionString = [NSString stringWithFormat:@"%g", [solutionNumber doubleValue]];
    [output replaceCharactersInRange:[mathRange range] withString:solutionString];
    NSLog(@"Patch +-: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[NSSet SVRPlusMinus]
                                     ignoringSet:[NSSet SVROperators]];
  }
  
  // If we get to the end here, and the result is not just a simple number,
  // then we have a mismatch between numbers and operators
  if (![output containsOnlyCharactersInSet:[NSSet SVRNumerals]]) {
    *error = [NSNumber errorMissingNumberBeforeOrAfterOperator];
  }
  
  if (*error) {
    return nil;
  }
  
  NSLog(@"Finished: %@", output);
  return [[output copy] autorelease];
}

-(NSNumber*)__performCalculationWithRange:(SVRMathRange*)range error:(NSNumber**)error;
{
  NSString *lhs = [range lhs];
  NSString *rhs = [range rhs];
  NSString *operator = [range operator];
  
  if ([operator isEqualToString:@"/"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] / [rhs doubleValue]];
  } else if ([operator isEqualToString:@"*"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] * [rhs doubleValue]];
  } else if ([operator isEqualToString:@"+"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] + [rhs doubleValue]];
  } else if ([operator isEqualToString:@"-"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] - [rhs doubleValue]];
  } else if ([operator isEqualToString:@"^"]) {
    return [NSNumber numberWithDouble:pow([lhs doubleValue],[rhs doubleValue])];
  } else {
    *error = [NSNumber errorOperatorUnsupported];
    return nil;
  }
}

@end
