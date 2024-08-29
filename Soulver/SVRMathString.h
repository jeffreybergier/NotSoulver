//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>

@interface SVRMathString: NSObject
{
  NSMutableString *_string;
}
// MARK: Properties
-(NSString*)stringValue;
// MARK: Main Business Logic
-(void)appendEncodedString:(NSString*)aString;
-(void)backspace;
-(BOOL)isEmpty;
// MARK: Debugging
-(NSString*)description;
@end

// MARK: Init
@interface SVRMathString (Creating)
-(id)init;
-(id)initWithString:(NSString*)aString;
+(id)mathStringWithString:(NSString*)aString;
@end

@interface SVRMathString (Copying) <NSCopying>
-(id)copyWithZone:(NSZone*)zone;
@end

@interface SVRMathString (Archiving)
-(BOOL)writeToFilename:(NSString*)filename;
+(id)mathStringWithFilename:(NSString*)filename;
@end

@interface SVRMathString (NSObjectProtocol)
-(BOOL)isEqual:(id)object;
-(unsigned long)hash;
@end

// MARK: Constants

@interface SVRMathString (SVRConstants)
+(NSDictionary*)operatorDecodeMap;
+(NSDictionary*)operatorEncodeMap;
@end

@interface NSSet (SVRConstants)
+(NSSet*)SVR_operatorsAll;
+(NSSet*)SVR_operatorsPlusMinus;
+(NSSet*)SVR_operatorsMultDiv;
+(NSSet*)SVR_operatorsExponent;
+(NSSet*)SVR_numeralsAll;
+(NSSet*)SVR_solutionInsertCheck;
+(NSSet*)SVR_allowedCharacters;
@end

@interface NSNumber (SVRError)
+(NSNumber*)SVR_errorInvalidCharacter;
@end
