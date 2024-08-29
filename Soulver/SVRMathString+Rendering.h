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

// MARK: SVRMathString (Rendering)
@interface SVRMathString (Rendering)

// MARK: Render
-(NSAttributedString*)renderWithError:(NSNumber**)errorPointer;
-(NSAttributedString*)renderError:(NSNumber*)errorPointer;

// MARK: Private
-(NSAttributedString*)__render_encodedStringWithError:(NSNumber**)errorPointer;
-(NSString*)          __render_solveEncodedLine:(NSString*)input error:(NSNumber**)errorPointer;
-(NSAttributedString*)__render_decodeEncodedLine:(NSString*)line;
-(NSAttributedString*)__render_colorSolution:(NSString*)solution;
-(SVRMathRange*)      __render_rangeBySearching:(NSString*)string
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

// MARK: NSString

@interface NSString (Soulver)
-(SVRBoundingRange*)SVR_searchRangeBoundedByLHS:(NSString*)lhs
                                            rhs:(NSString*)rhs
                                          error:(NSNumber**)errorPointer;
-(SVRMathRange*)SVR_searchMathRangeForOperators:(NSSet*)including
                           allPossibleOperators:(NSSet*)ignoring
                            allPossibleNumerals:(NSSet*)numerals;
-(BOOL)SVR_containsOnlyCharactersInSet:(NSSet*)set;
-(BOOL)SVR_beginsWithCharacterInSet:(NSSet*)set;
-(BOOL)SVR_endsWithCharacterInSet:(NSSet*)set;
-(NSString*)SVR_stringByMappingCharactersInDictionary:(NSDictionary*)map;
@end

// MARK: NSMutableString
@interface NSMutableString (Soulver)
-(void)SVR_insertSolution:(id)solution
                  atRange:(NSRange)range
                    error:(NSNumber**)errorPointer;
-(BOOL)__canInsertSolutionAtRange:(NSRange)range;
@end

// MARK: NSAttributedString
@interface NSAttributedString (Soulver)
+(id)SVR_stringWithString:(NSString*)aString;
+(id)SVR_stringWithString:(NSString*)aString color:(NSColor*)aColor;
@end

// MARK: NSStringEnumerator
@interface SVRStringEnumeratorRange: NSObject
{
  NSRange _range;
  NSString *_substring;
}
-(NSRange)range;
-(NSString*)substring;
-(NSString*)description;
-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
+(id)rangeWithRange:(NSRange)range substring:(NSString*)substring;
@end

@interface SVRStringEnumerator: NSEnumerator
{
  NSString *_string;
  NSRange _range;
}
-(SVRStringEnumeratorRange*)nextObject;
-(id)initWithString:(NSString*)string;
+(id)enumeratorWithString:(NSString*)string;
@end

// MARK: SVRMathStringEnumerator
@interface SVRMathStringEnumeratorLine: NSObject
{
  NSString *_line;
  BOOL _isComplete;
  int _index;
}
-(NSString*)line;
-(BOOL)isComplete;
-(int)index;
-(NSString*)description;
-(id)initWithLine:(NSString*)line isComplete:(BOOL)isComplete index:(int)index;
+(id)lineWithLine:(NSString*)line isComplete:(BOOL)isComplete index:(int)index;
@end

@interface SVRMathStringEnumerator: NSEnumerator
{
  NSArray *_allObjects;
  int _nextIndex;
  BOOL _lastLineComplete;
}
-(NSArray*)allObjects;
-(SVRMathStringEnumeratorLine*)nextObject;
-(id)initWithMathString:(SVRMathString*)mathString;
+(id)enumeratorWithMathString:(SVRMathString*)mathString;
@end

// MARK: NSDecimalNumber
@interface NSDecimalNumber (Soulver)
/// In OpenStep, NaN comparisons are weird, so this uses a string comparison
-(BOOL)SVR_isNotANumber;
-(NSString*)SVR_description;
+(id)SVR_decimalNumberWithString:(NSString*)string;
+(id)SVR_numberLocale;
@end

// MARK: Error Handling
@interface NSNumber (SVRError)
+(NSNumber*)SVR_errorInvalidCharacter;
+(NSNumber*)SVR_errorMismatchedBrackets;
+(NSNumber*)SVR_errorMissingNumber;
+(NSNumber*)SVR_errorPatching;
+(NSString*)SVR_descriptionForError:(NSNumber*)error;
@end
