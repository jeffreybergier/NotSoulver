//
//  SVRRange.h
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/22.
//

#import <Foundation/Foundation.h>

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
-(NSString*)description;
@end

// MARK: NSString Custom Range Search
@interface NSString (Searching)
-(SVRBoundingRange*)boundingRangeWithLHS:(NSString*)lhs
                                  andRHS:(NSString*)rhs
                                   error:(NSNumber**)error;
-(SVRMathRange*)mathRangeWithOperators:(NSSet*)including
                     ignoringOperators:(NSSet*)ignoring
                         validNumerals:(NSSet*)numerals;
-(BOOL)isValidDouble;
@end
