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
  NSRange charRange = XPNotFoundRange;
  NSString *character = nil;
  NSRect glyphRect = NSZeroRect;
  //NSBezierPath *path = nil;
  XPUInteger glyphIndex;
  
  for (glyphIndex = glyphsToShow.location; glyphIndex < NSMaxRange(glyphsToShow); glyphIndex++) {
      charRange = [self characterRangeForGlyphRange:NSMakeRange(glyphIndex, 1) actualGlyphRange:NULL];
      character = [[[self textStorage] string] substringWithRange:charRange];
      
      if ([character isEqualToString:@"="]) {
        // Custom drawing for "*"
        glyphRect = [self boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
                                    inTextContainer:[self textContainerForGlyphAtIndex:glyphIndex effectiveRange:NULL]];
        glyphRect = NSOffsetRect(glyphRect, origin.x, origin.y);

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
      }
  }
  [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}
@end

/*
 More from ChatGPT
 - (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {
     for (NSUInteger glyphIndex = glyphsToShow.location; glyphIndex < NSMaxRange(glyphsToShow); glyphIndex++) {
         NSRange charRange = [self characterRangeForGlyphRange:NSMakeRange(glyphIndex, 1) actualGlyphRange:NULL];
         NSString *character = [[self textStorage] string]; // Old API without modern accessors
         character = [character substringWithRange:charRange];

         if ([character isEqualToString:@"*"]) {
             // Custom drawing for "*"
             NSRect glyphRect = [self boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
                                                inTextContainer:[self textContainerForGlyphAtIndex:glyphIndex effectiveRange:NULL]];
             glyphRect = NSOffsetRect(glyphRect, origin.x, origin.y);

             // Use NSColor's set method (older API)
             [[NSColor redColor] set];  // This sets both the fill and stroke colors in older API

             // Manually draw the oval (no bezier path `fill` in older API)
             NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:glyphRect];
             [path fill];  // In older APIs, this might not exist. So, instead:

             // Fallback method for older APIs without NSBezierPath's fill:
             [[NSGraphicsContext currentContext] saveGraphicsState];
             [[NSColor redColor] set];  // Again, ensure color is set
             NSRectFill(glyphRect);     // Use NSRectFill as a fallback for basic shape drawing
             [[NSGraphicsContext currentContext] restoreGraphicsState];
         }
     }
     [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
 }
 */
