//
//  Constants.m
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/23.
//

#import "SVRConstants.h"

// MARK: Constant Storage
NSNumber *NSNumber_SVR_errorInvalidCharacter;
NSNumber *NSNumber_SVR_errorMismatchedBrackets;
NSNumber *NSNumber_SVR_errorMissingNumberBeforeOrAfterOperator;
NSNumber *NSNumber_SVR_errorPatching;

NSSet *NSSet_SVR_numeralsAll;
NSSet *NSSet_SVR_operatorsAll;
NSSet *NSSet_SVR_allowedCharacters;
NSSet *NSSet_SVR_operatorsPlusMinus;
NSSet *NSSet_SVR_operatorsMultDiv;
NSSet *NSSet_SVR_operatorsExponent;
NSSet *NSSet_SVR_solutionInsertCheck;
NSSet *NSSet_SVR_solutionInsertCheck;

NSDictionary *NSDictionary_SVR_operatorDecodeMap;
NSDictionary *NSDictionary_SVR_operatorEncodeMap;
NSDictionary *NSDictionary_SVR_numberLocale;

// MARK: NSError
// OPENSTEP does not have NSError so I am just using NSNumber
@implementation NSNumber (NSError)
+(NSNumber*)SVR_errorInvalidCharacter;
{
  if (NSNumber_SVR_errorInvalidCharacter == nil) {
    NSNumber_SVR_errorInvalidCharacter = [[NSNumber alloc] initWithDouble:-1002];
  }
  return NSNumber_SVR_errorInvalidCharacter;
}
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

// MARK: NSSetHelper
@implementation NSSet (Soulver)
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

// MARK: NSDictionaryHelper
@implementation NSDictionary (Soulver)
+(NSDictionary*)SVR_operatorDecodeMap;
{
  if (!NSDictionary_SVR_operatorDecodeMap) {
    NSArray *keys   = [NSArray arrayWithObjects:@"a", @"s", @"d", @"m", @"e", nil];
    NSArray *values = [NSArray arrayWithObjects:@"+", @"-", @"/", @"*", @"^", nil];
    NSDictionary_SVR_operatorDecodeMap = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  }
  return NSDictionary_SVR_operatorDecodeMap;
}
+(NSDictionary*)SVR_operatorEncodeMap;
{
  if (!NSDictionary_SVR_operatorEncodeMap) {
    NSArray *keys   = [NSArray arrayWithObjects:@"+", @"-", @"/", @"*", @"^", nil];
    NSArray *values = [NSArray arrayWithObjects:@"a", @"s", @"d", @"m", @"e", nil];
    NSDictionary_SVR_operatorEncodeMap = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  }
  return NSDictionary_SVR_operatorEncodeMap;
}
+(id)SVR_numberLocale;
{
  if (!NSDictionary_SVR_numberLocale) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *keys   = [NSArray arrayWithObjects:@"kCFLocaleDecimalSeparatorKey", NSDecimalSeparator, nil];
    NSArray *values = [NSArray arrayWithObjects:@".", @".", nil];
    NSDictionary_SVR_numberLocale = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
#pragma clang diagnostic pop
  }
  return [[[DEBUG_SVRLocale alloc] init] autorelease];
  return NSDictionary_SVR_numberLocale;
}
@end

@implementation DEBUG_SVRLocale: NSObject
-(id)objectForKey:(id)key;
{
  id value = [NSDictionary_SVR_numberLocale objectForKey:key];
  NSAssert(value, @"DEBUG_SVRLocale: value missing for key: %@", key);
  return value;
}
@end

