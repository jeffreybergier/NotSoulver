#import "SVRDocumentTextDelegate.h"
#import "SVRCrossPlatform.h"

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
-(void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin;
{
  NSDictionary *attribs = nil;
  [XPLog debug:@"drawGlyphsForGlyphRange:{%lu,%lu} point:{%f,%f}",
   glyphsToShow.location, glyphsToShow.length, origin.x, origin.y];
  
  attribs = [[self textStorage] attributesAtIndex:NSMaxRange(glyphsToShow)-1 effectiveRange:NULL];
  [XPLog debug:@"drawGlyphsForGlyphRange: %@ %@", [[[self textStorage] string] SVR_descriptionHighlightingRange:NSMakeRange(NSMaxRange(glyphsToShow)-1, 1)], attribs];
  
  [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}
@end
