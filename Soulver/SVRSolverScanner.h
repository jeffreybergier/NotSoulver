//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"

@interface SVRSolverScanner: NSObject
{
  mm_copy NSString *_string;
  mm_new  NSSet    *_numbers;
  mm_new  NSSet    *_operators;
  mm_new  NSSet    *_expressions;
  mm_new  NSSet    *_brackets;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string;
+(id)scannerWithString:(NSString*)string;

// MARK: Access the ranges
-(NSSet*)numberRanges;
-(NSSet*)operatorRanges;
-(NSSet*)expressionRanges;
-(NSSet*)bracketRanges;

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

@interface SVRSolverScanner (Tests)
+(void)executeTests;
+(void)__executeNumberTests;
+(void)__executeOperatorTests;
+(void)__executeExpressionTests;
+(void)__executeBracketTests;
@end
