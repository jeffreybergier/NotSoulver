//
//  SVRMathString+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathString+Rendering.h"

// MARK: SVRMathString (Rendering)
@implementation SVRMathString (Rendering)

-(NSAttributedString*)renderWithError:(NSNumber**)errorPointer;
{
  NSAttributedString *output;
  NSNumber *error = errorPointer ? *errorPointer : nil;
  output = [self __render_encodedStringWithError:&error];
  if (output == nil) {
    output = [self renderError:error];
  }
  if (errorPointer) { *errorPointer = error; }
  return output;
}

-(NSAttributedString*)renderError:(NSNumber*)error;
{
  // TODO: Color with new colors in NSUserDefaults
  NSMutableAttributedString *output;
  NSEnumerator *e;
  SVRMathStringEnumeratorLine *line;
  
  output = [[NSMutableAttributedString new] autorelease];
  e = [SVRMathStringEnumerator enumeratorWithMathString:self];
  
  while ((line = [e nextObject])) {
    [output appendAttributedString:[self __render_decodeEncodedLine:[line line]]];
    [output appendAttributedString:
     [NSAttributedString SVR_stringWithString:[line isComplete] ? @"=\n" : @"\n"]
    ];
  }
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:[XPError SVR_descriptionForError:error]
                                                                    color:[NSColor orangeColor]]];
  return [[output copy] autorelease];
}

-(NSAttributedString*)__render_encodedStringWithError:(NSNumber**)errorPointer;
{
  // TODO: Color with new colors in NSUserDefaults
  NSMutableAttributedString *decodedOutput;
  SVRMathStringEnumeratorLine *line;
  NSEnumerator *e;
  NSString *encodedLine;
  NSString *lastSolution;
  NSNumber *error = nil;
  
  if (![_string SVR_containsOnlyCharactersInSet:[NSSet SVR_allowedCharacters]]) {
    error = [XPError SVR_errorInvalidCharacter];
    if (errorPointer) { *errorPointer = error; }
    return nil;
  }
  
  decodedOutput = [[NSMutableAttributedString new] autorelease];
  e = [SVRMathStringEnumerator enumeratorWithMathString:self];
  encodedLine = nil;
  lastSolution = nil;
  
  while ((line = [e nextObject])) {
    if ([[line line] SVR_beginsWithCharacterInSet:[NSSet SVR_operatorsAll]]) {             // If the line begins with an operator we need to prepend the last solution
      if (!lastSolution) { error = [XPError SVR_errorMissingNumber]; break; }             // If no previous solution AND the line begins with an operator we need to bail
      encodedLine = [lastSolution stringByAppendingString:[line line]];                    // Prepend the encoded line with the last solution
    } else {
      encodedLine = [line line];                                                           // Set the baseline for doing math operations later
    }
    [decodedOutput appendAttributedString:[self __render_decodeEncodedLine:encodedLine]];  // Decode the encodedLine and append it to the output
    if (![line isComplete]) { continue; }                                                  // If the line is incomplete we can bail
    lastSolution = [self __render_solveEncodedLine:encodedLine error:&error];              // Solve the problem
    if (lastSolution == nil) { if (errorPointer) { *errorPointer = error; } return nil; }  // If the solution is nil, there was an error
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"="]]; // Append an equal sign
    [decodedOutput appendAttributedString:[NSAttributedString SVR_answerPostfixString:lastSolution]];     // Append the solution
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"\n"]];// Append a newline
  }
  
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }
  
  return [[decodedOutput copy] autorelease];
}

-(NSString*)__render_solveEncodedLine:(NSString*)input error:(NSNumber**)errorPointer;
{
  NSNumber *error = errorPointer ? *errorPointer : nil;
  SVRBoundingRange *parenRange = nil;
  SVRMathRange *mathRange = nil;
  NSMutableString *output = [[input mutableCopy] autorelease];
    
  if (error != nil) { return nil; }
  if (input == nil || [input length] == 0) { return @""; }
  
  // PEMDAS
  // Parantheses
  while ((parenRange = [output SVR_searchRangeBoundedByLHS:@"(" rhs:@")" error:&error])) {
    [output SVR_insertSolution:[self __render_solveEncodedLine:[parenRange contents] error:&error]
                       atRange:[parenRange range]
                         error:&error];
    if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }
  }
  // Exponents
  while ((mathRange = [self __render_rangeBySearching:output
                                       forOperators:[NSSet SVR_operatorsExponent]]))
  {
    [output SVR_insertSolution:[mathRange evaluate] atRange:[mathRange range] error:&error];
    if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }
  }
  // Multiply and Divide
  while ((mathRange = [self __render_rangeBySearching:output
                                       forOperators:[NSSet SVR_operatorsMultDiv]]))
  {
    [output SVR_insertSolution:[mathRange evaluate] atRange:[mathRange range] error:&error];
    if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }
  }
  
  // Add and Subtract
  while ((mathRange = [self __render_rangeBySearching:output
                                       forOperators:[NSSet SVR_operatorsPlusMinus]]))
  {
    [output SVR_insertSolution:[mathRange evaluate] atRange:[mathRange range] error:&error];
    if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }
  }
  
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }

  // If we get to the end here, and the result is not just a simple number,
  // then we have a mismatch between numbers and operators.
  // The NSDecimalNumber check is surprisingly shitty,
  // but it might help if the main check fails
  if (![output SVR_containsOnlyCharactersInSet:[NSSet SVR_numeralsAll]]) {
    error = [XPError SVR_errorMissingNumber];
  } else if ([[NSDecimalNumber SVR_decimalNumberWithString:output] SVR_isNotANumber]) {
    error = [XPError SVR_errorMissingNumber];
  }
  
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return nil; }
  
  return [[output copy] autorelease];
}

-(NSAttributedString*)__render_decodeEncodedLine:(NSString*)line;
{
  return [NSAttributedString SVR_stringWithString:
            [line SVR_stringByMappingCharactersInDictionary:
               [SVRMathString operatorDecodeMap]
            ]
  ];
}

-(SVRMathRange*)__render_rangeBySearching:(NSString*)string
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

-(void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_contents release];
  _contents = nil;
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
              [lhs decimalNumberByRaisingToPower:(XPUInteger)abs([rhs intValue])]];
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

-(void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_lhs release];
  [_rhs release];
  [_operator release];
  _lhs = nil;
  _rhs = nil;
  _operator = nil;
  [super dealloc];
}

@end

// MARK: NSString
@implementation NSString (Rendering)

-(SVRBoundingRange*)SVR_searchRangeBoundedByLHS:(NSString*)lhs
                                            rhs:(NSString*)rhs
                                          error:(NSNumber**)errorPointer;
{
  SVRStringEnumerator *e;
  SVRStringEnumeratorRange *next;
  NSMutableArray *foundLHS;
  SVRStringEnumeratorRange *foundRHS;
  NSRange outputRange;
  NSString *outputContents;
  int balanceCounter;
  NSNumber *error = errorPointer ? *errorPointer : nil;
  
  if (error != nil) { return nil; }
  
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
    error = [XPError SVR_errorMismatchedBrackets];
    if (errorPointer) { *errorPointer = error; }
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
                    error:(NSNumber**)errorPointer;
{
  NSString *solutionString;
  NSNumber *error = errorPointer ? *errorPointer : nil;
  BOOL problem = NO;
  
  if (error != nil) { return; }
  if (![self __canInsertSolutionAtRange:range]) {
    error = [XPError SVR_errorPatching];
    if (errorPointer) { *errorPointer = error; }
    return;
  }

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
    error = [XPError SVR_errorInvalidCharacter];
    if (errorPointer) { *errorPointer = error; }
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
@implementation NSAttributedString (MathStringRendering)

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

+(id)SVR_answerPostfixString:(NSString*)aString;
{
  NSArray      *keys;
  NSArray      *vals;
  NSDictionary *attr;
  NSFont       *font;
  NSColor      *fClr;
  NSColor      *bClr;
  
  font = [NSFont userFixedPitchFontOfSize:14];
  fClr = [NSColor colorWithDeviceRed:004/255.0 green:051/255.0 blue:255/255.0 alpha:1];
  bClr = [NSColor colorWithDeviceRed:184/255.0 green:197/255.0 blue:255/255.0 alpha:1];
  
  keys = [NSArray arrayWithObjects:
          NSBackgroundColorAttributeName,
          NSForegroundColorAttributeName,
          NSFontAttributeName,
          nil];
  vals = [NSArray arrayWithObjects:bClr, fClr, font, nil];
  attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
  return [[[NSAttributedString alloc] initWithString:aString attributes:attr] autorelease];
}

+(id)SVR_answerPrefixString:(NSString*)aString;
{
  NSArray      *keys;
  NSArray      *vals;
  NSDictionary *attr;
  NSFont       *font;
  NSColor      *fClr;
  
  font = [NSFont userFixedPitchFontOfSize:14];
  fClr = [NSColor colorWithDeviceRed:004/255.0 green:051/255.0 blue:255/255.0 alpha:1];
  
  keys = [NSArray arrayWithObjects:
          NSForegroundColorAttributeName,
          NSFontAttributeName,
          nil];
  vals = [NSArray arrayWithObjects:fClr, font, nil];
  attr = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
  return [[[NSAttributedString alloc] initWithString:aString attributes:attr] autorelease];
}

+(id)SVR_operatorString:(NSString*)aString;
{
  return nil;
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

-(void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_substring release];
  _substring = nil;
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

-(void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_string release];
  _string = nil;
  [super dealloc];
}

@end

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
  return [self descriptionWithLocale:[[NSUserDefaults standardUserDefaults] SVR_decimalNumberLocale]];
}

+(id)SVR_decimalNumberWithString:(NSString*)string;
{
  return [NSDecimalNumber decimalNumberWithString:string locale:[[NSUserDefaults standardUserDefaults] SVR_decimalNumberLocale]];
}

@end
