/* SVRSolverTextAttachment.h created by me on Fri 18-Oct-2024 */

#import <AppKit/AppKit.h>
#import "SVRSolver.h"
#import "XPCrossPlatform.h"

@class SVRSolverTextAttachmentCell;

@interface SVRSolverTextAttachment: NSTextAttachment
{
  mm_retain NSDecimalNumber *_solution;
  SVRSolverError _error;
}

-(NSDecimalNumber*)solution;
-(SVRSolverError)error;
-(NSString*)stringForDrawing;
-(id)initWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
-(NSString*)description;

@end

@interface SVRSolverTextAttachmentCell: NSTextAttachmentCell
{
  mm_new NSString *_description;
}

// MARK: Properties
-(BOOL)shouldDrawError;
-(NSString*)description;

// MARK: Init
-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;

// MARK: Custom Drawing
-(void)__sol_drawWithFrame:(NSRect)cellFrame
                    inView:(NSView*)controlView;
-(void)__err_drawWithFrame:(NSRect)cellFrame
                    inView:(NSView*)controlView;
-(NSDictionary*)__sol_attributes;
-(NSDictionary*)__err_attributes;

// MARK: Protocol (Used)
-(NSSize)cellSize;
-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;

@end
