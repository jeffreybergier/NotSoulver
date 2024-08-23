//
//  Constants.h
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/23.
//

#import <Foundation/Foundation.h>

// MARK: NSError
// OPENSTEP does not have NSError so I am just using NSNumber
@interface NSNumber (NSError)
+(NSNumber*)SVR_errorInvalidCharacter;
+(NSNumber*)SVR_errorMismatchedBrackets;
+(NSNumber*)SVR_errorMissingNumberBeforeOrAfterOperator;
+(NSNumber*)SVR_errorPatching;
@end

// MARK: NSSetHelper
@interface NSSet (Soulver)
+(NSSet*)SVR_operatorsAll;
+(NSSet*)SVR_operatorsPlusMinus;
+(NSSet*)SVR_operatorsMultDiv;
+(NSSet*)SVR_operatorsExponent;
+(NSSet*)SVR_numeralsAll;
+(NSSet*)SVR_solutionInsertCheck;
+(NSSet*)SVR_allowedCharacters;
@end

// MARK: NSDictionaryHelper
@interface NSDictionary (Soulver)
+(NSDictionary*)SVR_operatorDecodeMap;
+(NSDictionary*)SVR_operatorEncodeMap;
@end
