//
//  NSAttributedString+Soulver.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/08/02.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// MARK: NSAttributedString
@interface NSAttributedString (Soulver)
+(id)withString:(NSString*)aString;
+(id)withString:(NSString*)aString andColor:(NSColor*)aColor;
@end

@interface NSMutableAttributedString (Soulver)
+(id)withString:(NSString*)aString;
+(id)withString:(NSString*)aString andColor:(NSColor*)aColor;
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
@end

// MARK: NSString Custom Range Search
@interface NSString (Searching)
-(SVRBoundingRange*)boundingRangeWithLHS:(NSString*)lhs andRHS:(NSString*)rhs;
-(SVRMathRange*)mathRangeByMonitoringSet:(NSSet*)monitorSet ignoringSet:(NSSet*)ignoreSet;
@end

@interface SVRStringEnumeratorObject: NSObject
{
  NSRange _range;
  NSString *_substring;
}
-(NSRange)range;
-(NSString*)substring;
-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
+(id)objectWithRange:(NSRange)range substring:(NSString*)substring;
@end

// MARK: Custom Enumerator
@interface SVRStringEnumerator: NSEnumerator
{
  NSString *_string;
  NSRange _range;
}
-(SVRStringEnumeratorObject*)nextObject;
-(id)initWithString:(NSString*)string;
+(id)enumeratorWithString:(NSString*)string;
@end
