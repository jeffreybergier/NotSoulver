//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>
#import "SVRCrossPlatform.h"

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)annotateStorage:(NSMutableAttributedString*)input;
+(void)solveAnnotatedStorage:(NSMutableAttributedString*)input;
+(void)colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

// MARK: Private: annotateStorage
+(void)__annotateExpressions:(NSMutableAttributedString*)input;
+(void)__annotateBrackets:(NSMutableAttributedString*)input;
+(void)__annotateOperators:(NSMutableAttributedString*)output;
+(void)__annotateNumerals:(NSMutableAttributedString*)output;

// MARK: Private: annotateStorage
+(void)__solveExpressions:(NSMutableAttributedString*)output;

// MARK: Private: colorAnnotatedAndSolvedStorage
+(void)__colorAnnotatedAndSolvedStorage:(NSMutableAttributedString*)input;

@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end