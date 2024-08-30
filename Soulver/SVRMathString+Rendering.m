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
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:[NSNumber SVR_descriptionForError:error]
                                                                    color:[NSColor orangeColor]]];
  return [[output copy] autorelease];
}

-(NSAttributedString*)__render_encodedStringWithError:(NSNumber**)errorPointer;
{
  NSMutableAttributedString *decodedOutput;
  SVRMathStringEnumeratorLine *line;
  NSEnumerator *e;
  NSString *encodedLine;
  NSString *lastSolution;
  NSNumber *error = nil;
  
  if (![_string SVR_containsOnlyCharactersInSet:[NSSet SVR_allowedCharacters]]) {
    error = [NSNumber SVR_errorInvalidCharacter];
    if (errorPointer) { *errorPointer = error; }
    return nil;
  }
  
  decodedOutput = [[NSMutableAttributedString new] autorelease];
  e = [SVRMathStringEnumerator enumeratorWithMathString:self];
  encodedLine = nil;
  lastSolution = nil;
  
  while ((line = [e nextObject])) {
    if ([[line line] SVR_beginsWithCharacterInSet:[NSSet SVR_operatorsAll]]) {             // If the line begins with an operator we need to prepend the last solution
      if (!lastSolution) { error = [NSNumber SVR_errorMissingNumber]; break; }             // If no previous solution AND the line begins with an operator we need to bail
      encodedLine = [lastSolution stringByAppendingString:[line line]];                    // Prepend the encoded line with the last solution
    } else {
      encodedLine = [line line];                                                           // Set the baseline for doing math operations later
    }
    [decodedOutput appendAttributedString:[self __render_decodeEncodedLine:encodedLine]];  // Decode the encodedLine and append it to the output
    if (![line isComplete]) { continue; }                                                  // If the line is incomplete we can bail
    lastSolution = [self __render_solveEncodedLine:encodedLine error:&error];              // Solve the problem
    if (lastSolution == nil) { if (errorPointer) { *errorPointer = error; } return nil; }  // If the solution is nil, there was an error
    [decodedOutput appendAttributedString:[NSAttributedString SVR_stringWithString:@"="]]; // Append an equal sign
    [decodedOutput appendAttributedString:[self __render_colorSolution:lastSolution]];     // Append the solution
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
    error = [NSNumber SVR_errorMissingNumber];
  } else if ([[NSDecimalNumber SVR_decimalNumberWithString:output] SVR_isNotANumber]) {
    error = [NSNumber SVR_errorMissingNumber];
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

-(NSAttributedString*)__render_colorSolution:(NSString*)solution;
{
  return [NSAttributedString SVR_stringWithString:solution color:[NSColor cyanColor]];
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

// MARK: NSString
@implementation NSString (Soulver)

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
    error = [NSNumber SVR_errorMismatchedBrackets];
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
                    error:(NSNumber**)errorPointer;
{
  NSString *solutionString;
  NSNumber *error = errorPointer ? *errorPointer : nil;
  BOOL problem = NO;
  
  if (error != nil) { return; }
  if (![self __canInsertSolutionAtRange:range]) {
    error = [NSNumber SVR_errorPatching];
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
    error = [NSNumber SVR_errorInvalidCharacter];
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

// MARK: SVRMathStringEnumerator
@implementation SVRMathStringEnumeratorLine
-(NSString*)line;
{
  return _line;
}

-(BOOL)isComplete;
{
  return _isComplete;
}

-(int)index;
{
  return _index;
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"<%@> Line: '%@' isComplete: %d, Index: %d",
          [super description], _line, _isComplete, _index];
}

-(id)initWithLine:(NSString*)line isComplete:(BOOL)isComplete index:(int)index;
{
  self = [super init];
  _line = [line retain];
  _isComplete = isComplete;
  _index = index;
  return self;
}

+(id)lineWithLine:(NSString*)line isComplete:(BOOL)isComplete index:(int)index;
{
  return [[[SVRMathStringEnumeratorLine alloc] initWithLine:line isComplete:isComplete index:index] autorelease];
}

- (void)dealloc
{
  [_line release];
  _line = nil;
  [super dealloc];
}
@end

@implementation SVRMathStringEnumerator

-(NSArray*)allObjects;
{
  return _allObjects;
}

-(SVRMathStringEnumeratorLine*)nextObject;
{
  NSString *outputString = nil;
  unsigned long count = [_allObjects count];
  unsigned long lastIndex = count - 1;
  BOOL lineIsComplete = YES;
  int index = _nextIndex;
  _nextIndex += 1;

  // Bail Conditions
  if (count == 0) { return nil; }
  if (index > lastIndex) { return nil; }

  // Figure out if we're the last line
  if (index == lastIndex && _lastLineComplete == NO) {
    lineIsComplete = NO;
  }

  // Get our string
  outputString = [_allObjects objectAtIndex:index];
  // If its empty, get the next object
  if ([outputString length] == 0) { return [self nextObject]; }
  // Success
  return [SVRMathStringEnumeratorLine lineWithLine:outputString
                                        isComplete:lineIsComplete
                                             index:index];
}

-(id)initWithMathString:(SVRMathString*)mathString;
{
  NSString *mathStringRaw = [mathString stringValue];
  self = [super init];
  _allObjects = [[mathStringRaw componentsSeparatedByString:@"="] retain];
  _lastLineComplete = [mathStringRaw SVR_endsWithCharacterInSet:[NSSet setWithObject:@"="]];
  _nextIndex = 0;
  return self;
}

+(id)enumeratorWithMathString:(SVRMathString*)mathString;
{
  return [[[SVRMathStringEnumerator alloc] initWithMathString:mathString] autorelease];
}

- (void)dealloc
{
  [_allObjects release];
  _allObjects = nil;
  [super dealloc];
}
@end

// MARK: Constant Storage

NSDictionary *NSDecimalNumber_SVR_numberLocale;
NSNumber *NSNumber_SVR_errorMismatchedBrackets;
NSNumber *NSNumber_SVR_errorInvalidCharacter;
NSNumber *NSNumber_SVR_SVR_errorMissingNumber;
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
@implementation NSNumber (SVRError)
+(NSNumber*)SVR_errorMismatchedBrackets;
{
  if (NSNumber_SVR_errorMismatchedBrackets == nil) {
    NSNumber_SVR_errorMismatchedBrackets = [[NSNumber alloc] initWithDouble:-1003];
  }
  return NSNumber_SVR_errorMismatchedBrackets;
}
+(NSNumber*)SVR_errorInvalidCharacter;
{
  if (NSNumber_SVR_errorInvalidCharacter == nil) {
    NSNumber_SVR_errorInvalidCharacter = [[NSNumber alloc] initWithDouble:-1002];
  }
  return NSNumber_SVR_errorInvalidCharacter;
}
+(NSNumber*)SVR_errorMissingNumber;
{
  if (NSNumber_SVR_SVR_errorMissingNumber == nil) {
    NSNumber_SVR_SVR_errorMissingNumber = [[NSNumber alloc] initWithDouble:-1004];
  }
  return NSNumber_SVR_SVR_errorMissingNumber;
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
  } else if ([error isEqualToNumber:[NSNumber SVR_errorMissingNumber]]) {
    return [NSString stringWithFormat:@"<Error:%@> Operators around the numbers were unbalanced", error];
  } else if ([error isEqualToNumber:[NSNumber SVR_errorPatching]]) {
    return [NSString stringWithFormat:@"<Error:%@> Operators around the parentheses were missing", error];
  } else {
    return @"<Error> An Unknown Error Ocurred";
  }
}
@end
