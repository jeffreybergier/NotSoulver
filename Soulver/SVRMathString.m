//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathString.h"

@implementation SVRMathString

// MARK: Properties
-(NSString*)stringValue;
{
  return [[_string copy] autorelease];
}

// MARK: Main Business Logic

-(void)appendEncodedString:(NSString*)aString;
{
  [_string appendString:aString];
}

-(void)backspace;
{
  NSRange range;
  switch ([_string length]) {
    case 0:
      return;
    case 1:
      [_string setString:@""];
      return;
    default:
      range = NSMakeRange([_string length] - 1, 1);
      [_string deleteCharactersInRange:range];
      return;
  }
}

-(BOOL)isEmpty;
{
  return [_string length] == 0;
}

// MARK: Debugging
-(NSString*)description;
{
  return [[super description] stringByAppendingString:_string];
}

// MARK: Dealloc
- (void)dealloc
{
  [_string release];
  [super dealloc];
}

@end

// MARK: Init
@implementation SVRMathString (Creating)

-(id)init;
{
 self = [super init];
 _string = [NSMutableString new];
 return self;
}

-(id)initWithString:(NSString*)aString;
{
 self = [super init];
 _string = [aString mutableCopy];
 return self;
}

+(id)mathStringWithString:(NSString*)aString;
{
  return [[[SVRMathString alloc] initWithString:aString] autorelease];
}

@end

@implementation SVRMathString (Copying)

-(id)copyWithZone:(NSZone*)zone;
{
  return [[SVRMathString alloc] initWithString:_string];
}

@end

@implementation SVRMathString (Archiving)

-(BOOL)writeToFilename:(NSString*)filename;
{
  NSData *data = [_string dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) { return NO; }
  return [data writeToFile:filename atomically:YES];
}

+(id)mathStringWithFilename:(NSString*)filename;
{
  NSString *string;
  NSData *data = [NSData dataWithContentsOfFile:filename];
  if (!data) { return nil; }
  string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  if (!string) { return nil; }
  return [SVRMathString mathStringWithString:string];
}

@end

@implementation SVRMathString (NSObjectProtocol)

-(BOOL)isEqual:(id)object;
{
  SVRMathString *rhs = nil;
  SVRMathString *lhs = self;
  if ([object isKindOfClass:[SVRMathString class]]) {
    rhs = object;
  }
  if (rhs) {
    return [lhs->_string isEqualToString:rhs->_string];
  } else {
    return NO;
  }
}

-(unsigned long)hash;
{
  return [_string hash];
}

@end

NSDictionary *SVR_operatorDecodeMap;
NSDictionary *SVR_operatorEncodeMap;

NSSet *NSSet_SVR_numeralsAll;
NSSet *NSSet_SVR_operatorsAll;
NSSet *NSSet_SVR_allowedCharacters;
NSSet *NSSet_SVR_operatorsPlusMinus;
NSSet *NSSet_SVR_operatorsMultDiv;
NSSet *NSSet_SVR_operatorsExponent;
NSSet *NSSet_SVR_solutionInsertCheck;
NSSet *NSSet_SVR_solutionInsertCheck;

NSNumber *NSNumber_SVR_errorInvalidCharacter;

// MARK: NSDictionaryHelper
@implementation SVRMathString (Constants)
+(NSDictionary*)operatorDecodeMap;
{
  if (!SVR_operatorDecodeMap) {
    NSArray *keys   = [NSArray arrayWithObjects:@"a", @"s", @"d", @"m", @"e", nil];
    NSArray *values = [NSArray arrayWithObjects:@"+", @"-", @"/", @"*", @"^", nil];
    SVR_operatorDecodeMap = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  }
  return SVR_operatorDecodeMap;
}
+(NSDictionary*)operatorEncodeMap;
{
  if (!SVR_operatorEncodeMap) {
    NSArray *keys   = [NSArray arrayWithObjects:@"+", @"-", @"/", @"*", @"^", nil];
    NSArray *values = [NSArray arrayWithObjects:@"a", @"s", @"d", @"m", @"e", nil];
    SVR_operatorEncodeMap = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  }
  return SVR_operatorEncodeMap;
}
@end

@implementation NSSet (Constants)
+(NSSet*)SVR_operatorsAll;
{
  if (!NSSet_SVR_operatorsAll) {
    NSMutableSet *output = [[NSMutableSet new] autorelease];
    [output unionSet:[NSSet SVR_operatorsPlusMinus]];
    [output unionSet:[NSSet SVR_operatorsMultDiv]];
    [output unionSet:[NSSet SVR_operatorsExponent]];
    NSSet_SVR_operatorsAll = [output copy];
  }
  return NSSet_SVR_operatorsAll;
}
+(NSSet*)SVR_operatorsPlusMinus;
{
  if (!NSSet_SVR_operatorsPlusMinus) {
    NSSet_SVR_operatorsPlusMinus = [[NSSet alloc] initWithObjects:@"a", @"s", nil];
  }
  return NSSet_SVR_operatorsPlusMinus;
}
+(NSSet*)SVR_operatorsMultDiv;
{
  if (!NSSet_SVR_operatorsMultDiv) {
    NSSet_SVR_operatorsMultDiv = [[NSSet alloc] initWithObjects:@"d", @"m", nil];
  }
  return NSSet_SVR_operatorsMultDiv;
}
+(NSSet*)SVR_operatorsExponent;
{
  if (!NSSet_SVR_operatorsExponent) {
    NSSet_SVR_operatorsExponent = [[NSSet alloc] initWithObjects:@"e", nil];
  }
  return NSSet_SVR_operatorsExponent;
}
+(NSSet*)SVR_numeralsAll;
{
  if (!NSSet_SVR_numeralsAll) {
    NSSet_SVR_numeralsAll = [[NSSet alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @".", @"-", nil];
  }
  return NSSet_SVR_numeralsAll;
}
+(NSSet*)SVR_solutionInsertCheck;
{
  if (!NSSet_SVR_solutionInsertCheck) {
    NSMutableSet *output = [[NSMutableSet new] autorelease];
    [output unionSet:[NSSet SVR_operatorsAll]];
    [output unionSet:[NSSet setWithObjects:@"(", @")", @"=", nil]];
    NSSet_SVR_solutionInsertCheck = [output copy];
  }
  return NSSet_SVR_solutionInsertCheck;
}
+(NSSet*)SVR_allowedCharacters;
{
  if (!NSSet_SVR_allowedCharacters) {
    NSMutableSet *output = [[NSMutableSet new] autorelease];
    [output unionSet:[NSSet SVR_solutionInsertCheck]];
    [output unionSet:[NSSet SVR_numeralsAll]];
    NSSet_SVR_allowedCharacters = [output copy];
  }
  return NSSet_SVR_allowedCharacters;
}
@end

@implementation NSNumber (SVRError)
+(NSNumber*)SVR_errorInvalidCharacter;
{
  if (NSNumber_SVR_errorInvalidCharacter == nil) {
    NSNumber_SVR_errorInvalidCharacter = [[NSNumber alloc] initWithDouble:-1002];
  }
  return NSNumber_SVR_errorInvalidCharacter;
}
@end
