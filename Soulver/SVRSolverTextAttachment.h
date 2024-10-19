/* SVRSolverTextAttachment.h created by me on Fri 18-Oct-2024 */

#import <AppKit/AppKit.h>

@class SVRSolverTextAttachmentCell;

@interface SVRSolverTextAttachment: NSTextAttachment
{
  NSDecimalNumber *_solution;
}

-(NSDecimalNumber*)solution;
-(id)initWithSolution:(NSDecimalNumber*)solution;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution;

@end

@interface SVRSolverTextAttachmentCell: NSObject <NSTextAttachmentCell>
{
  SVRSolverTextAttachment *_attachment;
  NSDictionary *_solutionFontAttributes;
}

// MARK: Properties

-(NSDecimalNumber*)solution;
-(NSDictionary*)solutionFontAttributes;

// MARK: Init
-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;

// MARK: Protocol (Used)
-(SVRSolverTextAttachment*)attachment;
-(void)setAttachment:(SVRSolverTextAttachment*)attachment;
-(NSSize)cellSize;
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;

// MARK: Protocol (Unused)
-(NSPoint)cellBaselineOffset;
-(BOOL)trackMouse:(NSEvent *)theEvent
           inRect:(NSRect)cellFrame
           ofView:(NSView *)controlView
     untilMouseUp:(BOOL)flag;
-(BOOL)wantsToTrackMouse;

@end
