//
//  SVRMathString+Rendering.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathString+Rendering.h"
#import "NSString+Soulver.h"
#import "SVRConstants.h"

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
  
  output = [[NSMutableAttributedString new] autorelease];
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:_string]];
  [output appendAttributedString:[NSAttributedString SVR_stringWithString:[NSString stringWithFormat:@"<Error:%@>\n", error]
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
  
  if (*error != NULL) {
    return nil;
  }
  
  if (input == nil || [input length] == 0) {
    return @"";
  }
  // PEMDAS
  // Parantheses
  while ((parenRange = [output SVR_searchRangeBoundedByLHS:@"(" rhs:@")" error:error])) {
    [output SVR_insertSolution:[self render_solveEncodedLine:[parenRange contents] error:error]
                       atRange:[parenRange range]
                         error:error];
  }
  // Exponents
  while ((mathRange = [self render_rangeBySearching:output forOperators:[NSSet SVR_operatorsExponent]]))
  {
    [output SVR_insertSolution:[NSString stringWithFormat:@"%g", [mathRange evaluate]]
                       atRange:[mathRange range]
                         error:error];
  }
  // Multiply and Divide
  while ((mathRange = [self render_rangeBySearching:output forOperators:[NSSet SVR_operatorsMultDiv]]))
  {
    [output SVR_insertSolution:[NSString stringWithFormat:@"%g", [mathRange evaluate]]
                       atRange:[mathRange range]
                         error:error];
  }
  
  // Add and Subtract
  while ((mathRange = [self render_rangeBySearching:output forOperators:[NSSet SVR_operatorsPlusMinus]]))
  {
    [output SVR_insertSolution:[NSString stringWithFormat:@"%g", [mathRange evaluate]]
                       atRange:[mathRange range]
                         error:error];
  }
  
  if (*error != NULL) {
    return nil;
  }
  
  // If we get to the end here, and the result is not just a simple number,
  // then we have a mismatch between numbers and operators
  if (![output isValidDouble]) {
    *error = [NSNumber SVR_errorMissingNumberBeforeOrAfterOperator];
    return nil;
  }
  return [[output copy] autorelease];
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
    _completeLines = [[input componentsSeparatedByString:@"="] retain];
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
