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
  XPLogExtra1(@"DEALLOC: %@", self);
  [_solution release];
  _solution = nil;
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(BOOL)shouldDrawError;
{
  SVRSolverTextAttachment *attachment = (SVRSolverTextAttachment*)[self attachment];
  return [attachment error] != SVRSolverErrorNone;
}

-(NSString*)description;
{
  return [[_description retain] autorelease];
}

// MARK: Init

-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  self = [super init];
  _description = [[NSString alloc] initWithFormat:@"<%@> {solution:`%@`, error:%@}",
      [self class], [attachment solution], SVRSolverDebugDescriptionForError([attachment error])];
  [self setAttachment:attachment];
  return self;
}

+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  return [[[SVRSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
}

// MARK: Custom Drawing

-(void)drawSolutionWithFrame:(NSRect)cellFrame
                   textFrame:(NSRect)textFrame
                      inView:(NSView*)controlView;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRSolverTextAttachment *attachment = (SVRSolverTextAttachment*)[self attachment];
  if ([ud SVR_userInterfaceStyle] == XPUserInterfaceStyleDark) {
    NSDrawGrayBezel(cellFrame, cellFrame);
  } else {
    NSDrawWhiteBezel(cellFrame, cellFrame);
  }
  [[attachment stringForDrawing] drawInRect:textFrame
                             withAttributes:[self attributesForDrawingSolution]];
  XPLogExtra1(@"drawSolutionWithFrame:%@", NSStringFromRect(cellFrame));
}

-(void)drawErrorWithFrame:(NSRect)cellFrame
                textFrame:(NSRect)textFrame
                   inView:(NSView*)controlView;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRSolverTextAttachment *attachment = (SVRSolverTextAttachment*)[self attachment];
  if ([ud SVR_userInterfaceStyle] == XPUserInterfaceStyleDark) {
    NSDrawGrayBezel(cellFrame, cellFrame);
  } else {
    NSDrawWhiteBezel(cellFrame, cellFrame);
  }
  [[attachment stringForDrawing] drawInRect:textFrame
                             withAttributes:[self attributesForDrawingError]];
  XPLogExtra1(@"drawErrorWithFrame:%@", NSStringFromRect(cellFrame));
}

-(NSDictionary*)attributesForDrawingSolution;
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
          [ud SVR_fontForTheme:SVRThemeFontMath],
          [ud SVR_colorForTheme:SVRThemeColorSolution],
          style,
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

-(NSDictionary*)attributesForDrawingError;
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
          [ud SVR_fontForTheme:SVRThemeFontError],
          [ud SVR_colorForTheme:SVRThemeColorErrorText],
          style,
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  NSDictionary *attributes = ([self shouldDrawError])
                            ? [self attributesForDrawingError]
                            : [self attributesForDrawingSolution];
  SVRSolverTextAttachment *attachment = (SVRSolverTextAttachment*)[self attachment];
  NSSize size = [[attachment stringForDrawing] sizeWithAttributes:attributes];
  size.width += 8;
  return size;
}

-(NSPoint)cellBaselineOffset;
{
  NSFont *font = [[self attributesForDrawingSolution] objectForKey:NSFontAttributeName];
  XPFloat capHeight = [font capHeight];
  XPFloat underline = fabs([font underlinePosition]);
  XPFloat calculation = 0-((capHeight/2)+underline);
  return NSMakePoint(0, calculation);
}

-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
{
  NSFont *font = [[self attributesForDrawingSolution] objectForKey:NSFontAttributeName];
  NSRect textFrame = NSMakeRect(cellFrame.origin.x,
                                cellFrame.origin.y - [font underlinePosition],
                                cellFrame.size.width,
                                cellFrame.size.height);
  return ([self shouldDrawError])
        ? [self drawErrorWithFrame:cellFrame    textFrame:textFrame inView:controlView]
        : [self drawSolutionWithFrame:cellFrame textFrame:textFrame inView:controlView];
}

-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;
{
  XPLogPause2(@"higlight:%@ withFrame:%@",
   (flag) ? @"YES" : @"NO", NSStringFromRect(cellFrame));
}

// MARK: Dealloc

-(void)dealloc;
{
  XPLogExtra1(@"DEALLOC: %@", self);
  [_description release];
  _description = nil;
  [super dealloc];
}

@end
