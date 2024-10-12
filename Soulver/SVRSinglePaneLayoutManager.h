#import <AppKit/AppKit.h>
#import "SVRSolver.h"

@interface SVRSinglePaneLayoutManager: NSLayoutManager
{
  NSDictionary *_solutionFontAttributes;
}

-(NSDictionary*)solutionFontAttributes;
-(id)init;
-(void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin;
-(void)setLineFragmentRect:(NSRect)fragmentRect
             forGlyphRange:(NSRange)glyphRange
                  usedRect:(NSRect)usedRect;
-(NSRect)boundingRectForGlyphRange:(NSRange)glyphRange
                   inTextContainer:(NSTextContainer *)container;
@end
