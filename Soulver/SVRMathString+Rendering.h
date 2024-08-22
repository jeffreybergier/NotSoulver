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
-(NSAttributedString*)renderError:(NSNumber*)error;

// MARK: Private
-(NSAttributedString*)__preparePEMDASLinesWithError:(NSNumber**)error;
-(NSString*)__solvePEMDASLine:(NSString*)input error:(NSNumber**)error;
-(NSNumber*)__performCalculationWithRange:(SVRMathRange*)range;

@end

@interface NSMutableString (SVRMathStringRendering)
-(void)SVR_replaceCharactersInRange:(NSRange)range
                         withString:(NSString*)patch;
@end
