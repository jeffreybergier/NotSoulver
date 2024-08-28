//
//  SVRMathString+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathString+Rendering.h"

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

// MARK: NSString
@implementation NSString (Soulver)

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

-(BOOL)SVR_containsOnlyCharactersInSet:(NSSet*)set;
{
  SVRStringEnumeratorRange *next;
  NSEnumerator *e = [SVRStringEnumerator enumeratorWithString:self];
  
  while ((next = [e nextObject])) {
    if ([set member:[next substring]]) { continue; }
    return NO;
  }
  
  return YES;
}

-(BOOL)SVR_beginsWithCharacterInSet:(NSSet*)set;
{
  if ([self length] == 0) { return NO; }
  return [set member:[self substringWithRange:NSMakeRange(0, 1)]] != nil;
}

-(BOOL)SVR_endsWithCharacterInSet:(NSSet*)set;
{
  if ([self length] == 0) { return NO; }
  return [set member:[self substringWithRange:NSMakeRange([self length] - 1, 1)]] != nil;
}

-(NSString*)SVR_stringByMappingCharactersInDictionary:(NSDictionary*)map;
{
  SVRStringEnumeratorRange *next = nil;
  NSEnumerator *e = [SVRStringEnumerator enumeratorWithString:self];
  NSMutableString *output = [[NSMutableString new] autorelease];
  NSString *toAppend = nil;
  while ((next = [e nextObject])) {
    toAppend = [map objectForKey:[next substring]];
    if (!toAppend) { toAppend = [next substring]; }
    [output appendString:toAppend];
  }
  return [[output copy] autorelease];
}

@end

// MARK: NSMutableString
@implementation NSMutableString (Soulver)

-(void)SVR_insertSolution:(id)solution
                  atRange:(NSRange)range
                    error:(NSNumber**)error;
{
  NSString *solutionString;
  BOOL problem = NO;
  
  if (*error != nil) { return; }
  if (![self __canInsertSolutionAtRange:range]) { *error = [NSNumber SVR_errorPatching]; return; }

  if ([solution isKindOfClass:[NSDecimalNumber class]]) {
    problem = [solution SVR_isNotANumber];
    solutionString = [solution SVR_description];
  } else if ([solution isKindOfClass:[NSString class]]) {
    problem = [[NSDecimalNumber SVR_decimalNumberWithString:solution] SVR_isNotANumber];
    solutionString = solution;
  } else {
    [NSException raise:@"UnexpectedTypeException" format:@"Expected NSDecimalNumber or NSString: Got %@", solution];
    solutionString = nil;
  }
  
  if (problem) {
    *error = [NSNumber SVR_errorInvalidCharacter];
    return;
  }
  
  [self replaceCharactersInRange:range withString:solutionString];
  return;
}

-(BOOL)__canInsertSolutionAtRange:(NSRange)range;
{
  BOOL issueFound = NO;
  BOOL canCheckLeft = NO;
  BOOL canCheckRight = NO;
  NSRange checkRange = NSMakeRange(0,0);
  
  canCheckLeft = range.location > 0;
  canCheckRight = range.location + range.length < [self length];
  
  // Perform Checks to the left and right to make sure
  // there are operators outside of where we are patching.
  if (canCheckLeft) {
    checkRange.location = range.location - 1;
    checkRange.length = 1;
    issueFound = [[NSSet SVR_solutionInsertCheck] member:[self substringWithRange:checkRange]] == nil;
  }
  
  if (issueFound) {
    return NO;
  }
  
  if (canCheckRight) {
    checkRange.location = range.location + range.length;
    checkRange.length = 1;
    issueFound = [[NSSet SVR_solutionInsertCheck] member:[self substringWithRange:checkRange]] == nil;
  }
  
  if (issueFound) {
    return NO;
  }
  
  return YES;
}

@end

// MARK: NSAttributedString
@implementation NSAttributedString (Soulver)

+(id)SVR_stringWithString:(NSString*)aString;
{
  return [self SVR_stringWithString:aString color:nil];
}

+(id)SVR_stringWithString:(NSString*)aString color:(NSColor*)aColor;
{
  NSArray      *keys;
  NSArray      *vals;
  NSFont       *font;
  NSDictionary *attr;
  
  font = [NSFont userFixedPitchFontOfSize:14];
  
  if (aColor) {
    keys = [NSArray arrayWithObjects:NSBackgroundColorAttributeName, NSFontAttributeName, nil];
    vals = [NSArray arrayWithObjects:aColor, font, nil];
    attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    return [[[NSAttributedString alloc] initWithString:aString attributes:attr] autorelease];
  } else {
    keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
    vals = [NSArray arrayWithObjects:font, nil];
    attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    return [[[NSAttributedString alloc] initWithString:aString attributes:attr] autorelease];
  }
}
@end

@implementation SVRStringEnumeratorRange

-(NSRange)range;
{
  return _range;
}

-(NSString*)substring;
{
  return _substring;
}

-(NSString*)description;
{
  return [
    NSString stringWithFormat:@"SVREnumeratorRange: '%@' {%lu, %lu}",
                              _substring, _range.location, _range.length];
}

-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
{
  self = [super init];
  _range = range;
  _substring = [substring retain];
  return self;
}

+(id)rangeWithRange:(NSRange)range substring:(NSString*)substring;
{
  return [[[SVRStringEnumeratorRange alloc] initWithRange:range substring:substring] autorelease];
}

- (void)dealloc
{
  [_substring release];
  [super dealloc];
}

@end

@implementation SVRStringEnumerator

-(SVRStringEnumeratorRange*)nextObject;
{
  SVRStringEnumeratorRange *output;
  NSString *substring;
  
  if ([_string length] == 0) {
    return nil;
  }
  
  if (_range.location > [_string length] - _range.length) {
    return nil;
  }
  
  substring = [_string substringWithRange:_range];
  output = [SVRStringEnumeratorRange rangeWithRange:_range substring:substring];
  
  _range.location += 1;
  return output;
}

-(id)initWithString:(NSString*)string;
{
  self = [super init];
  _string = [string retain];
  _range = NSMakeRange(0,1);
  return self;
}

+(id)enumeratorWithString:(NSString*)string;
{
  return [[[SVRStringEnumerator alloc] initWithString:string] autorelease];
}

- (void)dealloc
{
  [_string release];
  [super dealloc];
}

@end

// MARK: Constant Storage

NSDictionary *NSDecimalNumber_SVR_numberLocale;
NSNumber *NSNumber_SVR_errorMismatchedBrackets;
NSNumber *NSNumber_SVR_errorMissingNumberBeforeOrAfterOperator;
NSNumber *NSNumber_SVR_errorPatching;

// MARK: NSDecimalNumber
@implementation NSDecimalNumber (Soulver)

-(BOOL)SVR_isNotANumber;
{
  NSString *lhsDescription;
  NSString *rhsDescription;
  
  lhsDescription = [self SVR_description];
  rhsDescription = [[NSDecimalNumber notANumber] SVR_description];
  
  return [lhsDescription isEqualToString:rhsDescription];
}

-(NSString*)SVR_description;
{
  return [self descriptionWithLocale:[NSDecimalNumber SVR_numberLocale]];
}

+(id)SVR_decimalNumberWithString:(NSString*)string;
{
  return [NSDecimalNumber decimalNumberWithString:string locale:[NSDecimalNumber SVR_numberLocale]];
}

+(id)SVR_numberLocale;
{
  if (!NSDecimalNumber_SVR_numberLocale) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *keys   = [NSArray arrayWithObjects:@"kCFLocaleDecimalSeparatorKey", NSDecimalSeparator, nil];
    NSArray *values = [NSArray arrayWithObjects:@".", @".", nil];
    NSDecimalNumber_SVR_numberLocale = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
#pragma clang diagnostic pop
  }
  return NSDecimalNumber_SVR_numberLocale;
}
@end

// MARK: NSError
// OPENSTEP does not have NSError so I am just using NSNumber
@implementation NSNumber (NSError)
+(NSNumber*)SVR_errorMismatchedBrackets;
{
  if (NSNumber_SVR_errorMismatchedBrackets == nil) {
    NSNumber_SVR_errorMismatchedBrackets = [[NSNumber alloc] initWithDouble:-1003];
  }
  return NSNumber_SVR_errorMismatchedBrackets;
}
+(NSNumber*)SVR_errorMissingNumberBeforeOrAfterOperator;
{
  if (NSNumber_SVR_errorMissingNumberBeforeOrAfterOperator == nil) {
    NSNumber_SVR_errorMissingNumberBeforeOrAfterOperator = [[NSNumber alloc] initWithDouble:-1004];
  }
  return NSNumber_SVR_errorMissingNumberBeforeOrAfterOperator;
}
+(NSNumber*)SVR_errorPatching;
{
  if (NSNumber_SVR_errorPatching == nil) {
    NSNumber_SVR_errorPatching = [[NSNumber alloc] initWithDouble:-1005];
  }
  return NSNumber_SVR_errorPatching;
}
+(NSString*)SVR_descriptionForError:(NSNumber*)error;
{
  if ([error isEqualToNumber:[NSNumber SVR_errorInvalidCharacter]]) {
    return [NSString stringWithFormat:@"<Error:%@> An incompatible character was found", error];
  } else if ([error isEqualToNumber:[NSNumber SVR_errorMismatchedBrackets]]) {
    return [NSString stringWithFormat:@"<Error:%@> Parentheses were unbalanced", error];
  } else if ([error isEqualToNumber:[NSNumber SVR_errorMissingNumberBeforeOrAfterOperator]]) {
    return [NSString stringWithFormat:@"<Error:%@> Operators around the numbers were unbalanced", error];
  } else if ([error isEqualToNumber:[NSNumber SVR_errorPatching]]) {
    return [NSString stringWithFormat:@"<Error:%@> Operators around the parentheses were missing", error];
  } else {
    return @"<Error> An Unknown Error Ocurred";
  }
}
@end
