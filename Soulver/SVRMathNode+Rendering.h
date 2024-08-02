//
//  SVRMathNode+Rendering.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import <AppKit/AppKit.h>
#import "SVRMathNode.h"

@interface SVRMathNode (Rendering)

// MARK: Render
-(BOOL)isStructureValid;
-(NSAttributedString*)render;
-(NSAttributedString*)__PRIVATE_renderNaive;
-(NSAttributedString*)__PRIVATE_renderValid;
-(double)__PRIVATE_doMathWithOperator:(NSString*)operator lhs:(NSString*)lhs rhs:(NSString*)rhs;

// MARK: NSAttributedString Helpers
-(NSAttributedString*)__NSASErrorForString:(NSString*)aString;
-(NSAttributedString*)__NSASAnswerForString:(NSString*)aString;

// MARK: Rendering Checks
-(NSSet*)__numerals;
-(NSSet*)__operators;
-(NSSet*)__equals;
-(NSSet*)__decimals;

@end
