#import "SVRSinglePaneLayoutManager.h"
#import "SVRCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRSinglePaneLayoutManager

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
  NSAttributedString *storage = [[self textStorage] attributedSubstringFromRange:
                                 [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL]];
  NSTextContainer *container = nil;
  XPAttributeEnumerator *e = [storage SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)];
  NSRange solutionCharRange = XPNotFoundRange;
  NSRange solutionGlyphRange = XPNotFoundRange;
  NSSize equalSignSize = NSZeroSize;
  NSRect boundingRect = NSZeroRect;
  NSRect drawRect = NSZeroRect;
  NSNumber *solution = nil;
  
  [XPLog extra:@"drawGlyphsForGlyphRange:%@ atPoint:%@",
        [[[self textStorage] string] SVR_descriptionHighlightingRange:glyphRange],
        NSStringFromPoint(origin)];
  
  while ((solution = [e nextObjectEffectiveRange:&solutionCharRange])) {
    // Calculate everything
    equalSignSize = [[[storage string] substringWithRange:solutionCharRange] sizeWithAttributes:[self solutionFontAttributes]];
    solutionGlyphRange = [self glyphRangeForCharacterRange:solutionCharRange actualCharacterRange:NULL];
    container = [self textContainerForGlyphAtIndex:solutionGlyphRange.location effectiveRange:NULL];
    boundingRect = [self boundingRectForGlyphRange:solutionGlyphRange
                                   inTextContainer:container];
    drawRect = NSMakeRect(boundingRect.origin.x + equalSignSize.width,
                          boundingRect.origin.y,
                          boundingRect.size.width - equalSignSize.width,
                          boundingRect.size.height);
    // Draw
    NSDrawWhiteBezel(drawRect, drawRect);
    [[solution SVR_descriptionForDrawing] drawInRect:drawRect
                                      withAttributes:[self solutionFontAttributes]];
  }
  
  [super drawGlyphsForGlyphRange:glyphRange atPoint:origin];
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
  
  while ((solution = [e nextObjectEffectiveRange:&charRange])) {
    solutionSize = [[solution SVR_descriptionForDrawing] sizeWithAttributes:[self solutionFontAttributes]];
    usedRect.size.width += solutionSize.width;
  }
  
  [XPLog extra:@"setLineFragmentRect:forGlyphRange:%@ usedRectSize:%@",
   [[[self textStorage] string] SVR_descriptionHighlightingRange:glyphRange],
   NSStringFromSize(usedRect.size)];
  
  [super setLineFragmentRect:fragmentRect forGlyphRange:glyphRange usedRect:usedRect];
}

-(NSRect)boundingRectForGlyphRange:(NSRange)glyphRange
                   inTextContainer:(NSTextContainer *)container;
{
  NSAttributedString *storage = [[self textStorage] attributedSubstringFromRange:
                                 [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL]];
  XPAttributeEnumerator *e = [storage SVR_enumeratorForAttribute:XPAttributedStringKeyForTag(SVRSolverTagSolution)];
  NSRect output = [super boundingRectForGlyphRange:glyphRange inTextContainer:container];
  NSRange charRange = XPNotFoundRange;
  NSSize solutionSize = NSZeroSize;
  NSNumber *solution = nil;
  
  while ((solution = [e nextObjectEffectiveRange:&charRange])) {
    solutionSize = [[solution SVR_descriptionForDrawing] sizeWithAttributes:[self solutionFontAttributes]];
    output.size.width += solutionSize.width;
  }
  
  [XPLog extra:@"boundingRectForGlyphRange:%@ outputWidth:%g",
   [[[self textStorage] string] SVR_descriptionHighlightingRange:glyphRange], output.size.width];
  
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
