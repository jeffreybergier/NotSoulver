/* SVRSolverTextAttachment.h created by me on Fri 18-Oct-2024 */

#import <AppKit/AppKit.h>

@class SVRSolverTextAttachmentCell;

@interface SVRSolverTextAttachment: NSTextAttachment
{
  NSDecimalNumber *_solution;
  SVRSolverTextAttachmentCell *_cell;
}

-(NSDecimalNumber*)solution;
-(SVRSolverTextAttachmentCell*)attachmentCell;
-(id)initWithSolution:(NSDecimalNumber*)solution;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution;

@end

@interface SVRSolverTextAttachmentCell: NSObject <NSTextAttachmentCell>
{
  SVRSolverTextAttachment *_attachment;
}

-(SVRSolverTextAttachment*)attachment;
-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
-(void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView*)controlView;

@end
