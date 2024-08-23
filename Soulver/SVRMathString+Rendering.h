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
-(NSAttributedString*)render_encodedStringWithError:(NSNumber**)error;
-(NSString*)          render_solveEncodedLine:(NSString*)input error:(NSNumber**)error;
-(NSAttributedString*)render_decodeEncodedLine:(NSString*)line;
-(NSAttributedString*)render_colorSolution:(NSString*)solution;

@end

@interface NSMutableString (SVRMathStringRendering)
-(void)SVR_replaceCharactersInRange:(NSRange)range
                         withString:(NSString*)patch
                              error:(NSNumber**)error;
@end
