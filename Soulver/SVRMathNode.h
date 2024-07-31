//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>

// MARK: Properties
@interface SVRMathNode : NSObject
{
  NSString *_value;
  SVRMathNode *_nextNode;
}

-(SVRMathNode*)nextNode;
-(void)setNextNode:(SVRMathNode*)aNode;
-(NSString*)value;
-(void)setValue:(NSString*)aString;

// MARK: Init
-(id)initWithValue:(NSString*)aString;
+(id)nodeWithValue:(NSString*)aString;

// MARK: Usage
-(void)appendNode:(SVRMathNode*)aNode;

// MARK: Class Variables
+(BOOL)isValidInput:(NSString*)input;

@end
