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
-(void)appendString:(NSString*)aString;
-(void)backspace;
// MARK: Debugging
-(NSString*)description;
// MARK: Init
-(id)init;
-(id)initWithString:(NSString*)aString;
// MARK: Validation
+(BOOL)isValidInput:(NSString*)input;

@end

@interface SVRMathString (Coding) <NSCopying, NSCoding>
-(void)encodeWithCoder:(NSCoder*)coder;
-(id)initWithCoder:(NSCoder*)coder;
-(id)copyWithZone:(NSZone*)zone;
@end

@interface SVRMathString (Archiving)
-(BOOL)writeToFilename:(NSString*)filename;
+(id)mathStringFromFilename:(NSString*)filename;
@end

