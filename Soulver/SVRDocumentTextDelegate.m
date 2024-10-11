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
  [XPLog extra:@"%@ textStorageWillProcessEditing: `%@`", self, [storage string]];
  [SVRSolver annotateStorage:storage];
  [SVRSolver solveAnnotatedStorage:storage];
  [SVRSolver colorAnnotatedAndSolvedStorage:storage];
}

-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog extra:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
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

-(void)drawGlyphsForGlyphRange:(NSRange)_glyphRange atPoint:(NSPoint)origin;
{
  NSAttributedString *storage = [[self textStorage] attributedSubstringFromRange:
                                 [self characterRangeForGlyphRange:_glyphRange actualGlyphRange:NULL]];
  NSTextContainer *container = nil;
  XPAttributeEnumerator *e = [storage SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)];
  NSRange charRange = XPNotFoundRange;
  NSRange glyphRange = XPNotFoundRange;
  NSRect glyphRect = NSZeroRect;
  NSPoint drawPoint = NSZeroPoint;
  NSNumber *solution = nil;
  
  while ((solution = [e nextObjectEffectiveRange:&charRange])) {
    glyphRange = [self glyphRangeForCharacterRange:charRange actualCharacterRange:NULL];
    container = [self textContainerForGlyphAtIndex:glyphRange.location effectiveRange:NULL];
    glyphRect = [self boundingRectForGlyphRange:glyphRange
                                inTextContainer:container];
    drawPoint = glyphRect.origin;
    drawPoint.x += [@"=" sizeWithAttributes:[self solutionFontAttributes]].width;
    //glyphRect.size.width += [[solution SVR_descriptionForDrawing] sizeWithAttributes:[self solutionFontAttributes]].width;
    
    NSDrawGroove(glyphRect, glyphRect);
    [[solution SVR_descriptionForDrawing] drawAtPoint:drawPoint
                                       withAttributes:[self solutionFontAttributes]];
    [XPLog extra:@"drawGlyphsForGlyphRange: Drew `%@` atPoint %@",
     [solution SVR_descriptionForDrawing], NSStringFromPoint(drawPoint)];
  }
  
  [super drawGlyphsForGlyphRange:_glyphRange atPoint:origin];
}

-(void)setLineFragmentRect:(NSRect)fragmentRect
             forGlyphRange:(NSRange)glyphRange
                  usedRect:(NSRect)usedRect;
{
  NSAttributedString *storage = [[self textStorage] attributedSubstringFromRange:
                                 [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL]];
  XPAttributeEnumerator *e = [storage SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)];
  NSNumber *solution = nil;
  NSRange charRange = XPNotFoundRange;
  NSSize solutionSize = NSZeroSize;
  [XPLog debug:@"setLineFragmentRect:%@ forGlyphRange:%@ usedRect:%@",
   NSStringFromRect(fragmentRect), NSStringFromRange(glyphRange), NSStringFromRect(usedRect)];
  while ((solution = [e nextObjectEffectiveRange:&charRange])) {
    solutionSize = [[solution SVR_descriptionForDrawing] sizeWithAttributes:[self solutionFontAttributes]];
    usedRect.size.width += solutionSize.width;
    [XPLog debug:@"setLineFragmentRect: Found: `%@` addedWidth %@ toRect %@",
     [solution SVR_descriptionForDrawing], NSStringFromSize(solutionSize), NSStringFromRect(usedRect)];
  }
  [super setLineFragmentRect:fragmentRect forGlyphRange:glyphRange usedRect:usedRect];
}

/*
// TODO: Return length of the characters with with a solution
-(NSRect)boundingRectForGlyphRange:(NSRange)glyphRange inTextContainer:(NSTextContainer *)container;
{
  NSNumber *solution = nil;
  NSAttributedString *storage = nil;
  NSSize solutionSize = NSZeroSize;
  NSRange charRange = XPNotFoundRange;
  NSRect output = [super boundingRectForGlyphRange:glyphRange inTextContainer:container];
  if (glyphRange.length > 1) { return output; }
  
  charRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
  storage = [[self textStorage] attributedSubstringFromRange:charRange];
  solution = [storage attribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)
                        atIndex:0
                 effectiveRange:NULL];
  if (solution) {
    output.size.width += [[solution SVR_descriptionForDrawing] sizeWithAttributes:[self solutionFontAttributes]].width;
    [XPLog debug:@"boundingRectForGlyphRange: Found: %@ addedWidth %@ toRect %@",
     [solution SVR_descriptionForDrawing], NSStringFromSize(solutionSize), NSStringFromRect(output)];
  }
  
  return output;
}
*/

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
