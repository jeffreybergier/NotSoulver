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
// MARK: Main Business Logic
/// Dictionary containing the map for encoding
+(NSDictionary*)operatorEncodeMap;
/// Dictionary containing the map for decoding
+(NSDictionary*)operatorDecodeMap;
/// Appends the string and automatically encodes the operator. Use `initWithString` to skip encoding
/// Return 0 if successful, anything other than 0, check the error
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)error;
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
-(unsigned)hash;
@end

