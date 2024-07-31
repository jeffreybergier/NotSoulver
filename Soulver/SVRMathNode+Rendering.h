//
//  SVRMathNode+Rendering.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import "SVRMathNode.h"

@interface SVRMathNode (Rendering)

// MARK: Render
-(BOOL)isStructureValid;
-(NSString*)render;
-(NSString*)__PRIVATE_renderNaive;
-(NSString*)__PRIVATE_renderValid;
-(double)__PRIVATE_doMathWithOperator:(NSString*)operator lhs:(NSString*)lhs rhs:(NSString*)rhs;

// MARK: Rendering Checks
-(NSSet*)__numerals;
-(NSSet*)__operators;
-(NSSet*)__equals;
-(NSSet*)__decimals;

@end
