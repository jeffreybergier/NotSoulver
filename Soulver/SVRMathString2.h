//
//  SVRCharacterNode.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import <Foundation/Foundation.h>
#import "SVRCrossPlatform.h"

@interface SVRMathString2: NSObject
{
  /// Source of truth for this class
  NSString *_expressionString;
  /// Cached properties
  NSString *_encodedExpressionString;
  NSAttributedString *_coloredExpressionString;
  NSAttributedString *_coloredSolvedString;
}
-(NSString*)expressionString;
-(void)setExpressionString:(NSString*)expressionString;
-(NSString*)encodedExpressionString;
-(NSAttributedString*)coloredExpressionString;
-(NSAttributedString*)coloredSolvedString;
-(NSString*)description;

// MARK Private
+(NSString*)__encodeExpressionString:(NSString*)expressionString;
+(void)__colorExpressionString:(NSMutableAttributedString*)attrstr;
+(void)__resetAttributes:(NSMutableAttributedString*)attrstr;

// MARK: Stateless Methods
+(void)updateStorage:(NSMutableAttributedString*)attrstr;


@end

// MARK: Init
@interface SVRMathString2 (Creating)
-(id)init;
-(id)initWithExpressionString:(NSString*)expressionString;
+(id)mathStringWithExpressionString:(NSString*)expressionString;
@end

@interface SVRMathString2 (Copying) <NSCopying>
-(id)copyWithZone:(NSZone*)zone;
@end

@interface SVRMathString2 (Archiving)
-(BOOL)writeToFilename:(NSString*)filename;
+(id)mathStringWithFilename:(NSString*)filename;
@end

@interface SVRMathString2 (NSObjectProtocol)
-(BOOL)isEqual:(id)object;
-(XPUInteger)hash;
@end

// MARK: Constants

@interface SVRMathString2 (SVRConstants)
+(NSDictionary*)operatorDecodeMap;
+(NSDictionary*)operatorEncodeMap;
@end

// MARK: Testing
@interface SVRMathString2 (Testing)
+(void)executeUnitTests;
@end
