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
  NSNumber *error = nil;

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
      NSString *_solution = [self __solvePEMDASLine:[[lineBuilder copy] autorelease] error:&error];
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
  
  if (error) {
    NSLog(@"Encountered Error: %@", error);
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

  if (input == nil || [input length] == 0) { 
    return @""; 
  }
  NSLog(@"Analyzing: %@", input);
  output = [[input mutableCopy] autorelease];
  // PEMDAS
  // Parantheses
  parenRange = [output boundingRangeWithLHS:@"(" andRHS:@")"];
  while (parenRange && *error == NULL) {
    solutionString = [self __solvePEMDASLine:[parenRange contents] error:error];
    [output replaceCharactersInRange:[parenRange range] withString:solutionString];
    NSLog(@"Patch (): %@", output);
    parenRange = [output boundingRangeWithLHS:@"(" andRHS:@")"];
  }
  
  // Exponents
  mathRange = [output mathRangeByMonitoringSet:[self __exponent] ignoringSet:[self __operators]];
  while (mathRange && *error == NULL) {
    solutionNumber = [self __performCalculationWithRange:mathRange error:error];
    solutionString = [NSString stringWithFormat:@"%g", [solutionNumber doubleValue]];
    [output replaceCharactersInRange:[mathRange range] withString:solutionString];
    NSLog(@"Patch ^^: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[self __exponent] ignoringSet:[self __operators]];
  }
  
  // Multiply and Divide
  mathRange = [output mathRangeByMonitoringSet:[self __multdiv] ignoringSet:[self __operators]];
  while (mathRange && *error == NULL) {
    solutionNumber = [self __performCalculationWithRange:mathRange error:error];
    solutionString = [NSString stringWithFormat:@"%g", [solutionNumber doubleValue]];
    [output replaceCharactersInRange:[mathRange range] withString:solutionString];
    NSLog(@"Patch */: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[self __multdiv] ignoringSet:[self __operators]];
  }
  
  // Add and Subtract
  mathRange = [output mathRangeByMonitoringSet:[self __plusminus] ignoringSet:[self __operators]];
  while (mathRange && *error == NULL) {
    solutionNumber = [self __performCalculationWithRange:mathRange error:error];
    solutionString = [NSString stringWithFormat:@"%g", [solutionNumber doubleValue]];
    [output replaceCharactersInRange:[mathRange range] withString:solutionString];
    NSLog(@"Patch +-: %@", output);
    mathRange = [output mathRangeByMonitoringSet:[self __plusminus] ignoringSet:[self __operators]];
  }
  
  if (*error != NULL) {
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
  } else if ([operator isEqualToString:@"**"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] * [rhs doubleValue]];
  } else if ([operator isEqualToString:@"+"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] + [rhs doubleValue]];
  } else if ([operator isEqualToString:@"-"]) {
    return [NSNumber numberWithDouble:[lhs doubleValue] - [rhs doubleValue]];
  } else if ([operator isEqualToString:@"^"]) {
    return [NSNumber numberWithDouble:pow([lhs doubleValue],[rhs doubleValue])];
  } else {
    *error = [SVRMathString errorOperatorUnsupported];
    return nil;
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

// MARK: Errors
+(NSNumber*)errorOperatorUnsupported;
{
  return [NSNumber numberWithInt:-1001];
}

@end
