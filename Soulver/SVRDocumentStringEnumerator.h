//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "SVRLegacyRegex.h"

@interface SVRDocumentStringEnumerator: NSObject
{
  NSString     *_string;
  NSEnumerator *_numbers;
  NSEnumerator *_operators;
  NSEnumerator *_expressions;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string;
+(id)enumeratorWithString:(NSString*)string;

// MARK: NSEnumerator
-(NSValue*)nextNumber;
-(NSValue*)nextOperator;
-(NSValue*)nextExpression;

// MARK: Enumerator Access (mostly for testing)
-(NSEnumerator*)numberEnumerator;
-(NSEnumerator*)operatorEnumerator;
-(NSEnumerator*)expressionEnumerator;

// MARK: Convenience Properties
-(NSString*)string;
-(NSString*)description;

// MARK: Private
-(void)__populateNumbers;
-(void)__populateOperators;
-(void)__populateExpressions;
-(void)__addRange:(NSRange)range toSet:(NSMutableSet*)set;

@end

@interface SVRDocumentStringEnumerator (Tests)
+(void)executeTests;
+(void)__executeNumberTests;
@end
