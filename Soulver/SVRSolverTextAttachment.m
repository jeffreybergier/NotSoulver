/* SVRSolverTextAttachment.m created by me on Fri 18-Oct-2024 */

#import "SVRSolverTextAttachment.h"
#import "XPCrossPlatform.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRSolverTextAttachment

-(NSDecimalNumber*)solution;
{
  return [[_solution retain] autorelease];
}

-(id)initWithSolution:(NSDecimalNumber*)solution;
{
  self = [super initWithFileWrapper:nil];
  _solution = [solution retain];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution;
{
  return [[[SVRSolverTextAttachment alloc] initWithSolution:solution] autorelease];
}

- (void)dealloc
{
  [XPLog debug:@"DEALLOC: Attachment: %@", self];
  [_solution release];
  _solution = nil;
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(NSDecimalNumber*)solution;
{
  return [_attachment solution];
}

-(NSString*)stringToDraw;
{
  return [@"=" stringByAppendingString:[[self solution] SVR_description]];
}

-(NSDictionary*)drawingAttributes;
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

// MARK: Init

-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  self = [super init];
  _attachment = [attachment retain];
  return self;
}

+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  return [[[SVRSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  return [[self stringToDraw] sizeWithAttributes:[self drawingAttributes]];
}

-(NSPoint)cellBaselineOffset;
{
  // TODO: Remove magic number
  return NSMakePoint(0, -6);
}

-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
{
  [XPLog extra:@"drawWithFrame:%@", NSStringFromRect(cellFrame)];
  NSDrawWhiteBezel(cellFrame, cellFrame);
  [[self stringToDraw] drawInRect:cellFrame withAttributes:[self drawingAttributes]];
}

-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;
{
  [XPLog pause:@"higlight:%d withFrame:%@", flag, NSStringFromRect(cellFrame)];
  NSDrawButton(cellFrame, cellFrame);
  [[self stringToDraw] drawInRect:cellFrame withAttributes:[self drawingAttributes]];
}

// MARK: Protocol (Unused)

-(SVRSolverTextAttachment*)attachment;
{
  return [[_attachment retain] autorelease];
}

-(void)setAttachment:(SVRSolverTextAttachment*)attachment;
{
  [_attachment release];
  _attachment = [attachment retain];
}

-(BOOL)wantsToTrackMouse;
{
  return NO;
}

-(BOOL)trackMouse:(NSEvent *)theEvent
           inRect:(NSRect)cellFrame
           ofView:(NSView *)controlView
     untilMouseUp:(BOOL)flag;
{
  return NO;
}

// MARK: Dealloc

-(void)dealloc;
{
  [XPLog debug:@"DEALLOC: Cell: %@", self];
  [_attachment release];
  _attachment = nil;
  [super dealloc];
}

@end