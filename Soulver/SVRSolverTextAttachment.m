/* SVRSolverTextAttachment.m created by me on Fri 18-Oct-2024 */

#import "SVRSolverTextAttachment.h"
#import "XPCrossPlatform.h"

@implementation SVRSolverTextAttachment

-(NSDecimalNumber*)solution;
{
  return [[_solution retain] autorelease];
}

-(SVRSolverTextAttachmentCell*)attachmentCell;
{
  return [[_cell retain] autorelease];
}

-(id)initWithSolution:(NSDecimalNumber*)solution;
{
  self = [super initWithFileWrapper:nil];
  _solution = [solution retain];
  _cell = [[SVRSolverTextAttachmentCell alloc] init];
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution;
{
  return [[[SVRSolverTextAttachment alloc] initWithSolution:solution] autorelease];
}

- (void)dealloc
{
  [XPLog debug:@"DEALLOC: %@", self];
  [_solution release];
  [_cell release];
  _solution = nil;
  _cell = nil;
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachmentCell

-(SVRSolverTextAttachment*)attachment;
{
  return [[_attachment retain] autorelease];
}

-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  self = [super init];
  _attachment = attachment; // Non retained because the lifecycle is shared with the attachment
  return self;
}

+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  return [[[SVRSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
{
  [XPLog debug:@"drawWithFrame:%@ inView:%@", NSStringFromRect(cellFrame), controlView];
}

-(void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView*)controlView;
{
  [XPLog debug:@"higlight:%d withFrame:%@ inView:%@", flag, NSStringFromRect(cellFrame), controlView];
}

@end
