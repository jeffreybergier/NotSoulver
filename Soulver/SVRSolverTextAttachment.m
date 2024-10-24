/* SVRSolverTextAttachment.m created by me on Fri 18-Oct-2024 */

#import "SVRSolverTextAttachment.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRSolverTextAttachment

-(NSDecimalNumber*)solution;
{
  return [[_solution retain] autorelease];
}

-(SVRSolverError)error;
{
  return _error;
}

-(NSString*)stringForDrawing;
{
  return ([self error] == SVRSolverErrorNone)
  ? [@"=" stringByAppendingString:[[self solution] SVR_description]]
  : [@"=" stringByAppendingString:SVRSolverDescriptionForError([self error])];
}

-(id)initWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  self = [super initWithFileWrapper:wrapper];
  _solution = [solution retain];
  _error = error;
  [wrapper setPreferredFilename:[self stringForDrawing]];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
{
  return [[[SVRSolverTextAttachment alloc] initWithSolution:solution error:error] autorelease];
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"<%@> {solution:`%@`, error:%@}",
    [self class], [self solution], SVRSolverDebugDescriptionForError([self error])];
}

- (void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_solution release];
  _solution = nil;
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(BOOL)shouldDrawError;
{
  return [[self attachment] error] != SVRSolverErrorNone;
}

-(NSString*)description;
{
  return [[_description retain] autorelease];
}

// MARK: Init

-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  self = [super init];
  _attachment = attachment;
  _description = [[NSString alloc] initWithFormat:@"<%@> {solution:`%@`, error:%@}",
      [self class], [attachment solution], SVRSolverDebugDescriptionForError([attachment error])];
  return self;
}

+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  return [[[SVRSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
}

// MARK: Custom Drawing

-(void)__sol_drawWithFrame:(NSRect)cellFrame
                    inView:(NSView*)controlView;
{
  [XPLog extra:@"__solut_drawWithFrame:%@", NSStringFromRect(cellFrame)];
  NSDrawWhiteBezel(cellFrame, cellFrame);
  [[[self attachment] stringForDrawing] drawInRect:cellFrame withAttributes:[self __sol_attributes]];
}

-(void)__err_drawWithFrame:(NSRect)cellFrame
                    inView:(NSView*)controlView;
{
  [XPLog extra:@"__error_drawWithFrame:%@", NSStringFromRect(cellFrame)];
  NSDrawGrayBezel(cellFrame, cellFrame);
  [[[self attachment] stringForDrawing] drawInRect:cellFrame withAttributes:[self __err_attributes]];
}

-(NSDictionary*)__sol_attributes;
{
  NSUserDefaults *ud;
  NSArray *keys;
  NSArray *vals;
  NSMutableParagraphStyle *style;
  
  style = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
  [style setAlignment:XPTextAlignmentCenter];
  
  ud   = [NSUserDefaults standardUserDefaults];
  keys = [NSArray arrayWithObjects:
          NSFontAttributeName,
          NSForegroundColorAttributeName,
          NSParagraphStyleAttributeName,
          nil];
  vals = [NSArray arrayWithObjects:
          [ud SVR_fontForText],
          [ud SVR_colorForSolutionPrimary],
          style,
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

-(NSDictionary*)__err_attributes;
{
  NSUserDefaults *ud;
  NSArray *keys;
  NSArray *vals;
  NSMutableParagraphStyle *style;
  
  style = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
  [style setAlignment:XPTextAlignmentCenter];
  
  ud   = [NSUserDefaults standardUserDefaults];
  keys = [NSArray arrayWithObjects:
          NSFontAttributeName,
          NSForegroundColorAttributeName,
          NSParagraphStyleAttributeName,
          nil];
  vals = [NSArray arrayWithObjects:
          [ud SVR_fontForText],
          [ud SVR_colorForError],
          style,
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  NSSize size = [[[self attachment] stringForDrawing] sizeWithAttributes:[self __sol_attributes]];
  size.width += 8;
  return size;
}

-(NSPoint)cellBaselineOffset;
{
  // TODO: Remove magic number
  return NSMakePoint(0, -6);
}

-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
{
  return ([self shouldDrawError])
        ? [self __err_drawWithFrame:cellFrame inView:controlView]
        : [self __sol_drawWithFrame:cellFrame inView:controlView];
}

-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;
{
  [XPLog pause:@"higlight:%@ withFrame:%@",
   (flag) ? @"YES" : @"NO", NSStringFromRect(cellFrame)];
}

// MARK: Protocol (Unused)

-(SVRSolverTextAttachment*)attachment;
{
  return [[_attachment retain] autorelease];
}

-(void)setAttachment:(SVRSolverTextAttachment*)attachment;
{
  _attachment = attachment;
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
  [XPLog extra:@"DEALLOC: %@", self];
  [_description release];
  _description = nil;
  _attachment = nil;
  [super dealloc];
}

@end
