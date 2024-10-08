#import <AppKit/AppKit.h>
#import "SVRSolver.h"

#if OS_OPENSTEP
@interface SVRDocumentTextDelegate: NSObject
#else
@interface SVRDocumentTextDelegate: NSObject <NSTextStorageDelegate, NSTextViewDelegate>
#endif

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;

-(void)textDidBeginEditing:(NSNotification*)aNotification;
-(void)textDidEndEditing:(NSNotification*)aNotification;

@end

@interface SVRLayoutManager: NSLayoutManager
{
  NSDictionary *_solutionFontAttributes;
}

-(NSDictionary*)solutionFontAttributes;
-(id)init;
-(void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin;
-(NSRect)boundingRectForGlyphRange:(NSRange)glyphRange inTextContainer:(NSTextContainer *)container;
@end
