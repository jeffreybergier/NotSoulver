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
  XPAttributeEnumerator *e = [storage SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)];
  NSRange charRange = XPNotFoundRange;
  NSRange glyphRange = XPNotFoundRange;
  NSRect glyphRect = NSZeroRect;
  NSPoint drawPoint = NSZeroPoint;
  NSNumber *solution = nil;
  
  while ((solution = [e nextObjectEffectiveRange:&charRange])) {
    glyphRange = [self glyphRangeForCharacterRange:charRange actualCharacterRange:NULL];
    glyphRect = [self boundingRectForGlyphRange:glyphRange
                                inTextContainer:[self textContainerForGlyphAtIndex:glyphRange.location effectiveRange:NULL]];
    drawPoint = glyphRect.origin;
    drawPoint.x += [@"=" sizeWithAttributes:[self solutionFontAttributes]].width;
    
    NSDrawGroove(glyphRect, glyphRect);
    [[solution SVR_descriptionForDrawing] drawAtPoint:drawPoint
                                       withAttributes:[self solutionFontAttributes]];
    [XPLog extra:@"drawGlyphsForGlyphRange: Drew %@ atPoint %@",
     [solution SVR_descriptionForDrawing], NSStringFromPoint(drawPoint)];
  }
  
  [super drawGlyphsForGlyphRange:_glyphRange atPoint:origin];
}

// TODO: Return length of the characters with with a solution
-(NSRect)boundingRectForGlyphRange:(NSRange)_glyphRange inTextContainer:(NSTextContainer *)container;
{
  NSRect output = [super boundingRectForGlyphRange:_glyphRange inTextContainer:container];
  NSAttributedString *storage = [[self textStorage] attributedSubstringFromRange:
                                 [self characterRangeForGlyphRange:_glyphRange actualGlyphRange:NULL]];
  XPAttributeEnumerator *e = [storage SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)];
  NSRange charRange = XPNotFoundRange;
  NSSize solutionSize = NSZeroSize;
  id solution = nil;
  
  while ((solution = [e nextObjectEffectiveRange:&charRange])) {
    solutionSize = [[solution description] sizeWithAttributes:[self solutionFontAttributes]];
    if (output.size.height != solutionSize.height) {
      [XPLog pause:@"solutionSize.height %f != %f output.size.height",
       solutionSize.height, output.size.height];
    }
    [XPLog extra:@"boundingRectForGlyphRange: Adding Width %@ toRect %@",
     NSStringFromSize(solutionSize), NSStringFromRect(output)];
    output.size.width += solutionSize.width;
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
