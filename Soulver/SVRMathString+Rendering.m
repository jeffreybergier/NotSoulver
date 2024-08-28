//
//  SVRMathString+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathString+Rendering.h"
#import "NSString+Soulver.h"
#import "SVRConstants.h"

// MARK: SVRMathString (Rendering)
@implementation SVRMathString (Rendering)

-(NSAttributedString*)render;
{
  NSAttributedString *output;
  NSNumber *error = nil;
  output = [self render_encodedStringWithError:&error];
  if (output == nil) {
    output = [self renderError:error];
  }
  return output;
}

-(NSAttributedString*)renderError:(NSNumber*)error;
{
  NSMutableAttributedString *output;
  SVRMathLineModel *model;
  NSEnumerator *e;
  NSString *line;
  
  output = [[NSMutableAttributedString new] autorelease];
  model = [SVRMathLineModel modelWithEncodedString:[[_string copy] autorelease]];
  e = [[model completeLines] objectEnumerator];
  
  while ((line = [e nextObject])) {
    [output appendAttributedString:[self render_decodeEncodedLine:line]];
    [output appendAttributedString:[NSAttributedString SVR_stringWithString:@"=\n"]];
  }
  if ([model incompleteLine]) {
    [output appendAttributedString:[self render_decodeEncodedLine:[model incompleteLine]]];
    [output appendAttributedString:[NSAttributedString SVR_stringWithString:@"\n"]];
  }
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:[NSNumber SVR_descriptionForError:error]
                                                                    color:[NSColor orangeColor]]];
  return [[output copy] autorelease];
}

-(NSAttributedString*)render_encodedStringWithError:(NSNumber**)error;
{
  SVRMathLineModel *model;
  NSMutableAttributedString *decodedOutput;
  NSEnumerator *e;
  NSString *_encodedLine;
  NSString *encodedLine;
  NSString *lastSolution;
  
  if (![_string SVR_containsOnlyCharactersInSet:[NSSet SVR_allowedCharacters]]) {
    *error = [NSNumber SVR_errorInvalidCharacter];
    return nil;
  }
  
  model = [SVRMathLineModel modelWithEncodedString:[[_string copy] autorelease]];
  decodedOutput = [[NSMutableAttributedString new] autorelease];
  e = [[model completeLines] objectEnumerator];
  encodedLine = nil;
  lastSolution = nil;
  
  // TODO: Enhance into 1 while loop
  // Instead of separating the incomplete line into a separate property,
  // just have a BOOL for lastLineIncomplete.
  // Then make a custom array enumerator that has the -(int)index and -(BOOL)lastLine properties.
  // Then this loop can all happen in one without the need for the separate check for the last line
  // which is mostly copy and paste code
  while ((_encodedLine = [e nextObject])) {
    if ([_encodedLine length] == 0) { continue; }
    if ([_encodedLine SVR_beginsWithCharacterInSet:[NSSet SVR_operatorsAll]]) {             // If the line begins with an operator we need to prepend the last solution
      if (!lastSolution) {
        *error = [NSNumber SVR_errorMissingNumberBeforeOrAfterOperator];                    // If no previous solution AND the line begins with an operator we need to bail
        return nil;
      }
      encodedLine = [lastSolution stringByAppendingString:_encodedLine];                    // Prepend the encoded line with the last solution
    } else {
      encodedLine = _encodedLine;                                                           // Set the baseline for doing math operations later
    }
    lastSolution = [self render_solveEncodedLine:encodedLine error:error];                  // Solve the problem
    if (lastSolution == nil) { return nil; }                                                // If the solution is nil, there was an error
    [decodedOutput appendAttributedString:[self render_decodeEncodedLine:encodedLine]];     // Decode the encodedLine and append it to the output
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"="]];  // Append an equal sign
    [decodedOutput appendAttributedString:[self render_colorSolution:lastSolution]];        // Append the solution
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"\n"]]; // Append a newline
  }
  
  _encodedLine = [model incompleteLine];
  if (_encodedLine) {
    if ([_encodedLine SVR_beginsWithCharacterInSet:[NSSet SVR_operatorsAll]]) {             // If the line begins with an operator we need to prepend the last solution
      if (!lastSolution) {
        *error = [NSNumber SVR_errorMissingNumberBeforeOrAfterOperator];                    // If no previous solution AND the line begins with an operator we need to bail
        return nil;
      }
      encodedLine = [lastSolution stringByAppendingString:_encodedLine];                    // Prepend the encoded line with the last solution
    } else {
      encodedLine = _encodedLine;                                                           // Set the baseline for doing math operations later
    }
    [decodedOutput appendAttributedString:[self render_decodeEncodedLine:encodedLine]];     // Decode the encodedLine and append it to the output
  }
  
  return [[decodedOutput copy] autorelease];
}

-(NSString*)render_solveEncodedLine:(NSString*)input error:(NSNumber**)error;
{
  SVRBoundingRange *parenRange = nil;
  SVRMathRange *mathRange = nil;
  NSMutableString *output = [[input mutableCopy] autorelease];
  
  if (*error != nil) { return nil; }
  if (input == nil || [input length] == 0) { return @""; }
  
  // PEMDAS
  // Parantheses
  while ((parenRange = [output SVR_searchRangeBoundedByLHS:@"(" rhs:@")" error:error])) {
    [output SVR_insertSolution:[self render_solveEncodedLine:[parenRange contents] error:error]
                       atRange:[parenRange range]
                         error:error];
    if (*error != nil) { return nil; }
  }
  // Exponents
  while ((mathRange = [self render_rangeBySearching:output
                                       forOperators:[NSSet SVR_operatorsExponent]]))
  {
    [output SVR_insertSolution:[mathRange evaluate] atRange:[mathRange range] error:error];
    if (*error != nil) { return nil; }
  }
  // Multiply and Divide
  while ((mathRange = [self render_rangeBySearching:output
                                       forOperators:[NSSet SVR_operatorsMultDiv]]))
  {
    [output SVR_insertSolution:[mathRange evaluate] atRange:[mathRange range] error:error];
    if (*error != nil) { return nil; }
  }
  
  // Add and Subtract
  while ((mathRange = [self render_rangeBySearching:output
                                       forOperators:[NSSet SVR_operatorsPlusMinus]]))
  {
    [output SVR_insertSolution:[mathRange evaluate] atRange:[mathRange range] error:error];
    if (*error != nil) { return nil; }
  }
  
  if (*error != nil) { return nil; }
  
  // If we get to the end here, and the result is not just a simple number,
  // then we have a mismatch between numbers and operators.
  // The NSDecimalNumber check is surprisingly shitty,
  // but it might help if the main check fails
  if (![output SVR_containsOnlyCharactersInSet:[NSSet SVR_numeralsAll]]) {
    *error = [NSNumber SVR_errorMissingNumberBeforeOrAfterOperator];
    return nil;
  } else if ([[NSDecimalNumber SVR_decimalNumberWithString:output] SVR_isNotANumber]) {
    *error = [NSNumber SVR_errorMissingNumberBeforeOrAfterOperator];
    return nil;
  } else {
    return [[output copy] autorelease];
  }
}

-(NSAttributedString*)render_decodeEncodedLine:(NSString*)line;
{
  return [NSAttributedString SVR_stringWithString:
            [line SVR_stringByMappingCharactersInDictionary:
               [SVRMathString operatorDecodeMap]
            ]
  ];
}
-(NSAttributedString*)render_colorSolution:(NSString*)solution;
{
  return [NSAttributedString SVR_stringWithString:solution color:[NSColor cyanColor]];
}

-(SVRMathRange*)render_rangeBySearching:(NSString*)string
                           forOperators:(NSSet*)operators;
{
  return [string SVR_searchMathRangeForOperators:operators
                            allPossibleOperators:[NSSet SVR_operatorsAll]
                             allPossibleNumerals:[NSSet SVR_numeralsAll]];
}

@end

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
  NSDecimalNumber *lhs = [NSDecimalNumber SVR_decimalNumberWithString:[self lhs]];
  NSDecimalNumber *rhs = [NSDecimalNumber SVR_decimalNumberWithString:[self rhs]];
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
      return [[NSDecimalNumber one] decimalNumberByDividingBy:
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

@implementation SVRMathLineModel
-(NSArray*)completeLines;
{
  return _completeLines;
}
-(NSString*)incompleteLine;
{
  return _incompleteLine;
}

-(id)initWithEncodedString:(NSString*)input;
{
  self = [super init];
  [self __initProperties:input];
  return self;
}
+(id)modelWithEncodedString:(NSString*)input;
{
  return [[[SVRMathLineModel alloc] initWithEncodedString:input] autorelease];
}

-(void)__initProperties:(NSString*)input;
{
  NSMutableArray *tempLines;
  if ([input SVR_endsWithCharacterInSet:[NSSet setWithObject:@"="]]) {
    tempLines = [[[input componentsSeparatedByString:@"="] mutableCopy] autorelease];
    if ([[tempLines lastObject] length] == 0) { [tempLines removeLastObject]; }
    _completeLines = [tempLines copy];
    _incompleteLine = nil;
  } else {
    tempLines = [[[input componentsSeparatedByString:@"="] mutableCopy] autorelease];
    _incompleteLine = [[tempLines lastObject] retain];
    [tempLines removeLastObject];
    _completeLines = [tempLines copy];
  }
  if ([_completeLines count] == 0) {
    [_completeLines release];
    _completeLines = nil;
  }
  if ([_incompleteLine length] == 0) {
    [_incompleteLine release];
    _incompleteLine = nil;
  }
  return;
}

- (void)dealloc
{
  [_completeLines release];
  [_incompleteLine release];
  _completeLines = nil;
  _incompleteLine = nil;
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
  
  if (*error != nil) { return nil; }
  
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
