//
//  SVRMathString+Rendering.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import <AppKit/AppKit.h>
#import "SVRMathString.h"
#import "SVRRange.h"

@interface SVRMathString (Rendering)

// MARK: Render
-(NSAttributedString*)render;
-(NSAttributedString*)renderError:(NSNumber*)error;

// MARK: Private
-(NSAttributedString*)__renderWithError:(NSNumber**)error;
-(NSString*)__solveLine:(NSString*)input error:(NSNumber**)error;

@end

@interface NSMutableString (SVRMathStringRendering)
-(void)SVR_replaceCharactersInRange:(NSRange)range
                         withString:(NSString*)patch
                              error:(NSNumber**)error;
@end
