//
//  SVRMathString+Rendering.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/31.
//

#import <AppKit/AppKit.h>
#import "SVRMathString.h"

// MARK: Forward Declarations
@class SVRMathRange;
@class SVRBoundingRange;
@class SVRMathLineModel;

// MARK: SVRMathString (Rendering)
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

// MARK: Custom Ranges
@interface SVRBoundingRange: NSObject
{
  NSRange _range;
  NSString *_contents;
}
-(NSRange)range;
-(NSString*)contents;
-(id)initWithRange:(NSRange)range contents:(NSString*)contents;
+(id)rangeWithRange:(NSRange)range contents:(NSString*)contents;
-(NSString*)description;
@end

@interface SVRMathRange: NSObject
{
  NSRange _range;
  NSString *_lhs;
  NSString *_rhs;
  NSString *_operator;
}
-(NSRange)range;
-(NSString*)lhs;
-(NSString*)rhs;
-(NSString*)operator;
-(id)initWithRange:(NSRange)range lhs:(NSString*)lhs rhs:(NSString*)rhs operator:(NSString*)operator;
+(id)rangeWithRange:(NSRange)range lhs:(NSString*)lhs rhs:(NSString*)rhs operator:(NSString*)operator;
-(NSDecimalNumber*)evaluate;
-(NSString*)description;
@end

// MARK: Convert String to Array
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

// MARK: NSString

// MARK: NSString Custom Range Search
@interface NSString (Searching)
-(SVRBoundingRange*)SVR_searchRangeBoundedByLHS:(NSString*)lhs
                                            rhs:(NSString*)rhs
                                          error:(NSNumber**)error;
-(SVRMathRange*)SVR_searchMathRangeForOperators:(NSSet*)including
                           allPossibleOperators:(NSSet*)ignoring
                            allPossibleNumerals:(NSSet*)numerals;
@end
