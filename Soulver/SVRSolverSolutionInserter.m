//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverSolutionInserter.h"
#import "SVRSolver.h"

@implementation SVRSolverSolutionInserter

+(NSArray*)solutionsToInsertFromAttributedString:(NSAttributedString*)string;
{
  NSDecimalNumber *check = nil;
  XPUInteger index = 0;
  NSRange range = XPNotFoundRange;
  NSMutableArray *toInsert = [[NSMutableArray new] autorelease];
  
  // Find places to insert solutions
  while (index < [string length]) {
    check = [string attribute:SVR_stringForTag(SVRSolverTagExpressionSolution)
                      atIndex:index
        longestEffectiveRange:&range
                      inRange:NSMakeRange(0, [string length])];
    if (check) {
      index = NSMaxRange(range);
      if ([check isKindOfClass:[NSDecimalNumber class]]) {
        [toInsert addObject:
           [SVRSolverSolutionToInsert solutionWithIndex:index
            string:[self __attributedStringForNumber:check expressionRange:range]]
        ];
      } else {
        [toInsert addObject:
           [SVRSolverSolutionToInsert solutionWithIndex:index
            string:[self __attributedStringForError:check expressionRange:range]]
        ];
      }
    } else {
      index += 1;
    }
  }
  
  return toInsert;
}

+(void)insertSolutions:(NSArray*)solutions inAttributedString:(NSMutableAttributedString*)string;
{
  SVRSolverSolutionToInsert *next = nil;
  NSEnumerator *e = [solutions reverseObjectEnumerator];
  while ((next = [e nextObject])) {
    [string insertAttributedString:[next string] atIndex:[next index]];
  }
}

// MARK: Private
+(NSAttributedString*)__attributedStringForNumber:(NSDecimalNumber*)number
                                  expressionRange:(NSRange)range;
{
  NSMutableAttributedString *string = [[NSMutableAttributedString new] autorelease];
  NSDictionary *attribs = [NSDictionary dictionaryWithObject:[NSValue XP_valueWithRange:range]
                                                      forKey:SVR_stringForTag(SVRSolverTagSolution)];
  [string appendAttributedString:[[[NSAttributedString alloc] initWithString:[number SVR_description]
                                                                  attributes:attribs] autorelease]];
  [string appendAttributedString:[[[NSAttributedString alloc] initWithString:@"|"] autorelease]];
  return string;
}

+(NSAttributedString*)__attributedStringForError:(NSNumber*)error
                                 expressionRange:(NSRange)range;
{
  NSMutableAttributedString *string = [[NSMutableAttributedString new] autorelease];
  NSDictionary *attribs = [NSDictionary dictionaryWithObject:[NSValue XP_valueWithRange:range]
                                                      forKey:SVR_stringForTag(SVRSolverTagSolutionError)];
  [string appendAttributedString:[[[NSAttributedString alloc] initWithString:[XPError SVR_descriptionForError:error]
                                                                  attributes:attribs] autorelease]];
  [string appendAttributedString:[[[NSAttributedString alloc] initWithString:@"|"] autorelease]];
  return string;
}

@end

#import "SVRSolverSolutionTagger.h"

@implementation SVRSolverSolutionInserter (Tests)
+(NSMutableAttributedString*)executeTests;
{
  NSArray *output = nil;
  NSMutableAttributedString *input = [SVRSolverSolutionTagger executeTests];
  [XPLog alwys:@"SVRSolverStyler Tests: Starting"];
  output = [SVRSolverSolutionInserter solutionsToInsertFromAttributedString:input];
  NSAssert([[input string] isEqualToString:@"(-3.2+4)/7.3="],@"");
  [SVRSolverSolutionInserter insertSolutions:output inAttributedString:input];
  NSAssert([[input string] isEqualToString:@"(-3.2+4)/7.3=0.10958904109589041095890410958904109589\n"],@"");
  [XPLog alwys:@"SVRSolverStyler Tests: Passed"];
  return input;
}
@end

@implementation SVRSolverSolutionToInsert
-(XPUInteger)index;
{
  return _index;
}
-(NSAttributedString*)string;
{
  return [[_string retain] autorelease];
}
-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ {%lu} `%@`", [super description], [self index], [[self string] string]];
}
-(id)initWithIndex:(XPUInteger)index string:(NSAttributedString*)string;
{
  self = [super init];
  _index = index;
  _string = [string retain];
  return self;
}
+(id)solutionWithIndex:(XPUInteger)index string:(NSAttributedString*)string;
{
  return [[[SVRSolverSolutionToInsert alloc] initWithIndex:index string:string] autorelease];
}
- (void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_string release];
  _string = nil;
  [super dealloc];
}
@end
