//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "SVRSolverTextAttachment.h"

NSString *const SVRSolverTextAttachmentStyleToDrawFont    = @"SVRSolverTextAttachmentStyleToDrawFont";
NSString *const SVRSolverTextAttachmentStyleToDrawColor   = @"SVRSolverTextAttachmentStyleToDrawColor";
NSString *const SVRSolverTextAttachmentStyleNeighborFont  = @"SVRSolverTextAttachmentStyleNeighborFont";
NSString *const SVRSolverTextAttachmentStyleBorder        = @"SVRSolverTextAttachmentStyleBorder";
NSString *const SVRSolverTextAttachmentStyleUserInterface = @"SVRSolverTextAttachmentStyleUserInterface";

@implementation SVRSolverTextAttachment

-(NSString*)toDrawString;
{
  return [[_toDrawString retain] autorelease];
}

-(NSFont*)toDrawFont;
{
  return [[_toDrawFont retain] autorelease];
}

-(NSColor*)toDrawColor;
{
  return [[_toDrawColor retain] autorelease];
}

-(NSFont*)neighorFont;
{
  return [[_neighorFont retain] autorelease];
}

-(SVRSolverTextAttachmentBorderStyle)borderStyle;
{
  return _borderStyle;
}

-(XPUserInterfaceStyle)userInterfaceStyle;
{
  return _userInterfaceStyle;
}

-(id)initWithString:(NSString*)stringToDraw styles:(NSDictionary*)styles;
{
  NSNumber *borderStyleNumber        = [styles objectForKey:SVRSolverTextAttachmentStyleBorder];
  NSNumber *userInterfaceStyleNumber = [styles objectForKey:SVRSolverTextAttachmentStyleUserInterface];
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  
  self = [super initWithFileWrapper:wrapper];
  
  _toDrawString = [stringToDraw retain];
  _toDrawFont   = [[styles objectForKey:SVRSolverTextAttachmentStyleToDrawFont] retain];
  _toDrawColor  = [[styles objectForKey:SVRSolverTextAttachmentStyleToDrawColor] retain];
  _neighorFont  = [[styles objectForKey:SVRSolverTextAttachmentStyleNeighborFont] retain];
  _borderStyle  = (SVRSolverTextAttachmentBorderStyle)[borderStyleNumber intValue];
  _userInterfaceStyle = (XPUserInterfaceStyle)[userInterfaceStyleNumber intValue];
  
  NSParameterAssert(_toDrawString);
  NSParameterAssert(_toDrawFont);
  NSParameterAssert(_toDrawColor);
  NSParameterAssert(_neighorFont);
  NSParameterAssert(borderStyleNumber != nil);
  NSParameterAssert(userInterfaceStyleNumber != nil);
  
  [wrapper setPreferredFilename:_toDrawString];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution styles:(NSDictionary*)styles;
{
  return [[[SVRSolverTextAttachment alloc] initWithString:[@"=" stringByAppendingString:[solution description]]
                                                   styles:styles] autorelease];
}

+(id)attachmentWithPreviousSolution:(NSDecimalNumber*)previousSolution
                           operator:(SVRSolverOperator)operator
                             styles:(NSDictionary*)styles;
{
  return [[[SVRSolverTextAttachment alloc] initWithString:[[previousSolution description] stringByAppendingString:RawStringForOperator(operator)]
                                                   styles:styles] autorelease];
}

+(id)attachmentWithError:(SVRCalculationError)error
                  styles:(NSDictionary*)styles;
{
  return [[[SVRSolverTextAttachment alloc] initWithString:[@"=" stringByAppendingString:SVRSolverDescriptionForError(error)]
                                                                                 styles:styles] autorelease];
}

// MARK: Dealloc

-(void)dealloc;
{
  XPLogExtra1(@"DEALLOC: %@", self);
  [_toDrawString release];
  [_toDrawFont   release];
  [_toDrawColor  release];
  [_neighorFont  release];
  _toDrawString = nil;
  _toDrawFont   = nil;
  _toDrawColor  = nil;
  _neighorFont  = nil;
  [super dealloc];
}

@end

// TODO: SVRSolverSolutionTextAttachmentBorderStyle
/*
+(SVRSolverTextAttachmentBorderStyle)borderStyle;
{
  switch ([[NSUserDefaults standardUserDefaults] SVR_userInterfaceStyle]) {
    case XPUserInterfaceStyleDark:
      return SVRSolverTextAttachmentBorderStyleRecessedGray;
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleUnspecified:
    default:
      return SVRSolverTextAttachmentBorderStyleRecessedWhite;
  }
}
*/

// TODO: SVRSolverPreviousSolutionTextAttachmentBorderStyle
/*
+(SVRSolverTextAttachmentBorderStyle)borderStyle;
{
  return SVRSolverTextAttachmentBorderStyleColored;
}
*/

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(NSDictionary*)toDrawAttributes;
{
  return [[_toDrawAttributes retain] autorelease];
}

-(id<SVRSolverTextAttachmentProtocol>)SVR_attachment;
{
  return (id<SVRSolverTextAttachmentProtocol>)[self attachment];
}

// MARK: Init

-(id)initWithAttachment:(NSTextAttachment<SVRSolverTextAttachmentProtocol>*)attachment;
{
  self = [super init];
  [self setAttachment:attachment];
  _toDrawAttributes = [
    [SVRSolverTextAttachmentCell toDrawAttributesWithFont:[attachment toDrawFont]
                                                    color:[attachment toDrawColor]]
    retain];
  return self;
}

+(id)cellWithAttachment:(NSTextAttachment<SVRSolverTextAttachmentProtocol>*)attachment;
{
  return [[[SVRSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
}

// MARK: Custom Drawing

+(NSDictionary*)toDrawAttributesWithFont:(NSFont*)font
                                   color:(NSColor*)color;
{
  NSArray *keys;
  NSArray *vals;
  NSMutableParagraphStyle *style;
  
  style = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
  [style setAlignment:XPTextAlignmentCenter];
  
  keys = [NSArray arrayWithObjects:
          NSFontAttributeName,
          NSForegroundColorAttributeName,
          NSParagraphStyleAttributeName,
          nil];
  vals = [NSArray arrayWithObjects:
          font,
          color,
          style,
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
{
  switch ([[self SVR_attachment] borderStyle]) {
    case SVRSolverTextAttachmentBorderStyleColored:
      [[[self SVR_attachment] toDrawColor] set];
      NSFrameRect(cellFrame);
      break;
    case SVRSolverTextAttachmentBorderStyleRecessedGray:
      NSDrawGrayBezel(cellFrame, cellFrame);
      break;
    case SVRSolverTextAttachmentBorderStyleRecessedWhite:
      NSDrawWhiteBezel(cellFrame, cellFrame);
      break;
    case SVRSolverTextAttachmentBorderStyleGroove:
      NSDrawGroove(cellFrame, cellFrame);
      break;
    case SVRSolverTextAttachmentBorderStyleDotted:
      NSDottedFrameRect(cellFrame);
      break;
    case SVRSolverTextAttachmentBorderStyleNone:
    default:
      break;
  }
  [[[self SVR_attachment] toDrawString] drawInRect:cellFrame
                                    withAttributes:[self toDrawAttributes]];
  XPLogExtra2(@"drawString:`%@` withFrame:%@", [[self SVR_attachment] toDrawString], NSStringFromRect(cellFrame));
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  NSDictionary *attributes = [self toDrawAttributes];
  NSSize size = [[[self SVR_attachment] toDrawString] sizeWithAttributes:attributes];
  size.width += 8;
  return size;
}

-(NSPoint)cellBaselineOffset;
{
  NSPoint output = [super cellBaselineOffset];
  XPFloat height = [self cellSize].height;
  NSFont *toDrawFont = [[self SVR_attachment] toDrawFont];
  output.y -= (height/2.0) + ([toDrawFont descender]*2.0);
  return output;
}

// MARK: Protocol (Unused)

-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;
{
  XPLogPause2(@"higlight:%@ withFrame:%@", (flag) ? @"YES" : @"NO", NSStringFromRect(cellFrame));
}

// MARK: Dealloc

-(void)dealloc;
{
  XPLogExtra1(@"DEALLOC: %@", self);
  [_toDrawAttributes release];
  _toDrawAttributes = nil;
  [super dealloc];
}

@end
