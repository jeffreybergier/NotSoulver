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

-(void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin;
{
  NSRange charRange = XPNotFoundRange;
  NSString *character = nil;
  NSRect glyphRect = NSZeroRect;
  XPUInteger glyphIndex = 0;
  
  for (glyphIndex = glyphsToShow.location; glyphIndex < NSMaxRange(glyphsToShow); glyphIndex++) {
      charRange = [self characterRangeForGlyphRange:NSMakeRange(glyphIndex, 1) actualGlyphRange:NULL];
      character = [[[self textStorage] string] substringWithRange:charRange];
      
      if ([character isEqualToString:@"#"]) {
        glyphRect = [self boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
                                    inTextContainer:[self textContainerForGlyphAtIndex:glyphIndex effectiveRange:NULL]];
        glyphRect = NSOffsetRect(glyphRect, origin.x, origin.y);
        NSDrawButton(glyphRect, glyphRect);
        [[NSString stringWithFormat:@"553.678"] drawAtPoint:NSMakePoint(glyphRect.origin.x+glyphRect.size.width,
                                                                        glyphRect.origin.y)
                                             withAttributes:[self solutionFontAttributes]];
      }
  }
  [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

// TODO: Return length of the characters with with a solution
-(NSRect)boundingRectForGlyphRange:(NSRange)glyphRange inTextContainer:(NSTextContainer *)container;
{
  NSRect output = [super boundingRectForGlyphRange:glyphRange inTextContainer:container];
  [XPLog debug:@"boundingRectForGlyphRange:<%@> <%@>", NSStringFromRange(glyphRange), NSStringFromRect(output)];
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
