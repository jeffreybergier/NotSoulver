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
-(void)appendString:(NSString*)aString;
-(void)backspace;
-(NSString*)description;
-(id)init;
+(BOOL)isValidInput:(NSString*)input;

@end
