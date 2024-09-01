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
-(void)backspaceCharacter;
-(void)backspaceLine;
-(void)backspaceAll;
-(BOOL)isEmpty;
-(NSString*)description;
-(NSEnumerator*)lineEnumerator;
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

// MARK: NSString

@interface NSString (Soulver)
-(BOOL)SVR_beginsWithCharacterInSet:(NSSet*)set;
-(BOOL)SVR_endsWithCharacterInSet:(NSSet*)set;
@end

// MARK: SVRMathStringEnumerator
@interface SVRMathStringEnumeratorLine: NSObject
{
  NSString *_line;
  BOOL _isComplete;
  int _index;
}
-(NSString*)line;
-(BOOL)isComplete;
-(int)index;
-(NSString*)description;
-(id)initWithLine:(NSString*)line isComplete:(BOOL)isComplete index:(int)index;
+(id)lineWithLine:(NSString*)line isComplete:(BOOL)isComplete index:(int)index;
@end

@interface SVRMathStringEnumerator: NSEnumerator
{
  NSArray *_allObjects;
  int _nextIndex;
  BOOL _lastLineComplete;
}
-(NSArray*)allObjects;
-(SVRMathStringEnumeratorLine*)nextObject;
-(id)initWithMathString:(SVRMathString*)mathString;
+(id)enumeratorWithMathString:(SVRMathString*)mathString;
@end
