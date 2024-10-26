//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"
#import "SLRERegex.h"

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

@end

@interface SLRERegex (Soulver)

+(id)SVR_regexForNumbersInString:(NSString*)string;
+(id)SVR_regexForOperatorsInString:(NSString*)string;
+(id)SVR_regexForExpressionsInString:(NSString*)string;
+(id)SVR_regexForLeftBracketsInString:(NSString*)string;
+(id)SVR_regexForRightBracketsInString:(NSString*)string;

@end
