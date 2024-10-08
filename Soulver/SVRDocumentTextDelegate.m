#import "SVRDocumentTextDelegate.h"
#import "SVRCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRDocumentTextDelegate

-(void)awakeFromNib
{
  [XPLog debug:@"%@ awakeFromNib", self];
}

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageWillProcessEditing: `%@`", self, [storage string]];
  [SVRSolver annotateStorage:storage];
  [SVRSolver solveAnnotatedStorage:storage];
}

-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
  [SVRSolver colorAnnotatedAndSolvedStorage:storage];
}

-(void)textDidBeginEditing:(NSNotification*)aNotification;
{
  [XPLog debug:@"%@ textDidBeginEditing", self];
}

-(void)textDidEndEditing:(NSNotification*)aNotification;
{
  [XPLog debug:@"%@ textDidEndEditing", self];
}

@end

@implementation SVRLayoutManager

-(NSDictionary*)solutionFontAttributes;
{
  NSUserDefaults *ud;
  NSArray *keys;
  NSArray *vals;
  
  if (_solutionFontAttributes) { return _solutionFontAttributes; }
  ud = [NSUserDefaults standardUserDefaults];
  keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
  vals = [NSArray arrayWithObjects:[ud SVR_fontForText], nil];
  _solutionFontAttributes = [[NSDictionary alloc] initWithObjects:vals forKeys:keys];
  return _solutionFontAttributes;
}

-(id)init;
{
  self = [super init];
  _solutionFontAttributes = nil;
  return self;
}

-(void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)origin;
{
  NSRange storageRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
  NSArray *solutionRanges = [self rangesOfSolutionsInStorage];
  NSEnumerator *e = [solutionRanges objectEnumerator];
  NSValue *next = nil;
  NSRange solutionRange = XPNotFoundRange;
  NSRange solutionGlyphRange = XPNotFoundRange;
  NSDecimalNumber *solution = nil;
  NSRect rect = NSZeroRect;
  
  while ((next = [e nextObject])) {
    if (XPContainsRange(storageRange, [next XP_rangeValue])) {
      solutionRange = [next XP_rangeValue];
      break;
    }
  }
  
  if (XPIsNotFoundRange(solutionRange)) {
    [super drawGlyphsForGlyphRange:glyphRange atPoint:origin];
    return;
  }
  
  solution = [[self textStorage] attribute:SVR_stringForTag(SVRSolverTagSolution)
                                   atIndex:solutionRange.location
                            effectiveRange:NULL];
  if (![solution isKindOfClass:[NSDecimalNumber class]]) {
    [XPLog error:@"unexpected solution: %@", solution];
    return;
  }
  
  solutionGlyphRange = [self glyphRangeForCharacterRange:solutionRange actualCharacterRange:NULL];
  rect = [self boundingRectForGlyphRange:solutionGlyphRange
                         inTextContainer:[self textContainerForGlyphAtIndex:solutionGlyphRange.location effectiveRange:NULL]];
  [XPLog pause:@"Found solution:%@ forRect:%@", solution, NSStringFromRect(rect)];
  
  [super drawGlyphsForGlyphRange:glyphRange atPoint:origin];
}

// TODO: Return length of the characters with with a solution
-(NSRect)boundingRectForGlyphRange:(NSRange)glyphRange inTextContainer:(NSTextContainer *)container;
{
  NSRect output = [super boundingRectForGlyphRange:glyphRange inTextContainer:container];
  [XPLog debug:@"boundingRectForGlyphRange:<%@> <%@>", NSStringFromRange(glyphRange), NSStringFromRect(output)];
  return output;
}

-(NSArray*)rangesOfSolutionsInStorage;
{
  id check = nil;
  XPUInteger index = 0;
  NSRange range = XPNotFoundRange;
  NSAttributedString *storage = [self textStorage];
  NSMutableArray *output = [[NSMutableArray new] autorelease];
  
  while (index < [storage length]) {
    check = [storage attribute:SVR_stringForTag(SVRSolverTagExpressionSolution)
                       atIndex:index
                effectiveRange:&range];
    if (!check) {
      // TODO: Clean up ENUM
      // TODO: Add in error handling
      // check = [storage attribute:SVR_stringForTag(SVRSolverTagExpressionSolutionError)
                         // atIndex:index
                  // effectiveRange:&range];
    }
    if (check) {
      [output addObject:[NSValue XP_valueWithRange:range]];
      index = NSMaxRange(range);
    } else {
      index += 1;
    }
  }
  return output;
}

- (void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_solutionFontAttributes release];
  _solutionFontAttributes = nil;
  [super dealloc];
}
@end

/*
 // Draw with postscript
 // Draw box
 PSsetgray(0.3);
 PSrectstroke(glyphRect.origin.x,
              glyphRect.origin.y,
              glyphRect.size.width/1.2,
              glyphRect.size.height/1.2);
 // Draw Line
 // TODO: Figure out how to do this drawing
 PSsetgray(0.0);
 PSmoveto(glyphRect.origin.x, glyphRect.origin.y);
 PSlineto(glyphRect.origin.x+glyphRect.size.width,
          glyphRect.origin.y+glyphRect.size.height);
 PSstroke();
 
 // Draw text
 // PSmoveto(glyphRect.origin.x, glyphRect.origin.y);
 // PSshow("Hello, PostScript World");
 
 // Flush the PostScript drawing commands to render
 PSflush();
 */
