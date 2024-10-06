//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "SVRCrossPlatform.h"

@interface SVRSolverSolutionInserter: NSObject
// MARK: Business Logic
+(NSArray*)solutionsToInsertFromAttributedString:(NSAttributedString*)string;
+(void)insertSolutions:(NSArray*)solutions inAttributedString:(NSMutableAttributedString*)string;

// MARK: Private
+(NSAttributedString*)__attributedStringForNumber:(NSDecimalNumber*)number
                                  expressionRange:(NSRange)range;
+(NSAttributedString*)__attributedStringForError:(NSNumber*)error
                                 expressionRange:(NSRange)range;
@end

@interface SVRSolverSolutionInserter (Tests)
+(NSMutableAttributedString*)executeTests;
@end

@interface SVRSolverSolutionToInsert: NSObject
{
  XPUInteger _index;
  NSAttributedString *_string;
}
-(XPUInteger)index;
-(NSAttributedString*)string;
-(NSString*)description;
-(id)initWithIndex:(XPUInteger)index string:(NSAttributedString*)string;
+(id)solutionWithIndex:(XPUInteger)index string:(NSAttributedString*)string;
@end
