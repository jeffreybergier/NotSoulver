//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "SVRLegacyRegex.h"

@interface SVRSoulverScanner: NSObject
{
  NSString     *_string;
  NSEnumerator *_numbers;
  NSEnumerator *_operators;
  NSEnumerator *_expressions;
  NSEnumerator *_brackets;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string;
+(id)enumeratorWithString:(NSString*)string;

// MARK: NSEnumerator
-(NSValue*)nextNumber;
-(NSValue*)nextOperator;
-(NSValue*)nextExpression;
-(NSValue*)nextBracket;

// MARK: Enumerator Access (mostly for testing)
-(NSEnumerator*)numberEnumerator;
-(NSEnumerator*)operatorEnumerator;
-(NSEnumerator*)expressionEnumerator;
-(NSEnumerator*)bracketEnumerator;

// MARK: Convenience Properties
-(NSString*)string;
-(NSString*)description;

// MARK: Private
-(void)__populateNumbers;
-(void)__populateOperators;
-(void)__populateExpressions;
-(void)__populateBrackets;
-(void)__addRange:(NSRange)range toSet:(NSMutableSet*)set;

@end

@interface SVRSoulverScanner (Tests)
+(void)executeTests;
+(void)__executeNumberTests;
+(void)__executeOperatorTests;
+(void)__executeExpressionTests;
+(void)__executeBracketTests;
@end
