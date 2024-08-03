//
//  SVRMathString+Rendering.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import <AppKit/AppKit.h>
#import "SVRMathString.h"
#import "Foundation+Soulver.h"

@interface SVRMathString (Rendering)

// MARK: Render
-(NSAttributedString*)render;
-(NSAttributedString*)renderRaw;

// MARK: Private
-(NSAttributedString*)__preparePEMDASLines;
-(NSString*)__solvePEMDASLine:(NSString*)input;
-(double)__performCalculationWithRange:(SVRMathRange*)range;

// MARK: Operator Sets
-(NSSet*)__operators;
-(NSSet*)__plusminus;
-(NSSet*)__multdiv;
-(NSSet*)__exponent;

@end
