/* SVRSolverTextAttachment.h created by me on Fri 18-Oct-2024 */

#import <AppKit/AppKit.h>
#import "SVRSolver.h"

@class SVRSolverTextAttachmentCell;

@interface SVRSolverTextAttachment: NSTextAttachment
{
  NSDecimalNumber *_solution;
  SVRSolverError _error;
}

-(NSDecimalNumber*)solution;
-(SVRSolverError)error;
-(id)initWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;

@end

@interface SVRSolverTextAttachmentCell: NSObject <NSTextAttachmentCell>
{
  SVRSolverTextAttachment *_attachment;
  NSDictionary *_solutionFontAttributes;
}

// MARK: Properties

-(NSString*)stringToDraw;
-(NSDictionary*)drawingAttributes;

// MARK: Init
-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;

// MARK: Protocol (Used)
-(NSSize)cellSize;
-(NSPoint)cellBaselineOffset;
-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;

// MARK: Protocol (Unused)
-(SVRSolverTextAttachment*)attachment;
-(void)setAttachment:(SVRSolverTextAttachment*)attachment;
-(BOOL)wantsToTrackMouse;
-(BOOL)trackMouse:(NSEvent *)theEvent
           inRect:(NSRect)cellFrame
           ofView:(NSView *)controlView
     untilMouseUp:(BOOL)flag;

@end
