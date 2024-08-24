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
-(SVRMathRange*)      render_rangeBySearching:(NSString*)string
                                 forOperators:(NSSet*)operators;
@end

@interface SVRMathLineModel: NSObject
{
  NSArray *_completeLines;
  NSString *_incompleteLine;
}
/// If no lines found, set to nil
-(NSArray*)completeLines;
/// If no last line found or empty, set to nil
-(NSString*)incompleteLine;
-(id)initWithEncodedString:(NSString*)input;
+(id)modelWithEncodedString:(NSString*)input;
-(void)__initProperties:(NSString*)input;
@end
