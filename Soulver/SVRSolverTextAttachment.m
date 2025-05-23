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

@implementation SVRSolverTextAttachment

+(NSSize)textPadding;
{
#ifdef XPSupportsNSBezierPath
  return NSMakeSize(12, 4);
#else
  return NSMakeSize(8, 2);
#endif
}

-(NSString*)string;
{
  return [[_string retain] autorelease];
}

-(NSFont*)font;
{
  return [_configuration objectForKey:NSFontAttributeName];
}

-(NSColor*)foregroundColor;
{
  return [_configuration objectForKey:NSForegroundColorAttributeName];
}

-(NSColor*)backgroundColor;
{
  return [_configuration objectForKey:NSBackgroundColorAttributeName];
}

-(NSColor*)mixColor;
{
  return [_configuration objectForKey:SVRSolverTextAttachmentMixColorKey];
}

-(SVRSolverTextAttachmentBackground)background;
{
  return (SVRSolverTextAttachmentBackground)[[_configuration objectForKey:SVRSolverTextAttachmentBackgroundKey] XP_integerValue];
}

-(id)initWithString:(NSString*)string
             styles:(SVRSolverTextAttachmentStyles)styles;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  
  self = [super initWithFileWrapper:wrapper];
  
  XPParameterRaise(self);
  XPParameterRaise(string);
  XPParameterRaise([styles objectForKey:NSFontAttributeName]);
  XPParameterRaise([styles objectForKey:NSForegroundColorAttributeName]);
  XPParameterRaise([styles objectForKey:NSBackgroundColorAttributeName]);
  XPParameterRaise([styles objectForKey:SVRSolverTextAttachmentMixColorKey]);
  XPParameterRaise([styles objectForKey:SVRSolverTextAttachmentBackgroundKey]);

  _string = [string retain];
  _configuration = [styles retain];
  
  [wrapper setPreferredFilename:string];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution
                     styles:(SVRSolverTextAttachmentStyles)styles;
{
  NSString *toDrawString = [@"=" stringByAppendingString:[solution description]];
  return [[[SVRSolverTextAttachment alloc] initWithString:toDrawString
                                                   styles:styles] autorelease];
}

+(id)attachmentWithPreviousSolution:(NSDecimalNumber*)previousSolution
                           operator:(SVRSolverOperator)operator
                             styles:(SVRSolverTextAttachmentStyles)styles;
{
  NSString *toDrawString = [[previousSolution description] stringByAppendingString:RawStringForOperator(operator)];
  return [[[SVRSolverTextAttachment alloc] initWithString:toDrawString
                                                   styles:styles] autorelease];
}

+(id)attachmentWithError:(SVRCalculationError)error
                  styles:(SVRSolverTextAttachmentStyles)styles;
{
  NSString *toDrawString = [@"=" stringByAppendingString:SVRSolverDescriptionForError(error)];
  return [[[SVRSolverTextAttachment alloc] initWithString:toDrawString
                                                   styles:styles] autorelease];
}

// MARK: Dealloc

-(void)dealloc;
{
  XPLogExtra1(@"%p", self);
  [_string release];
  [_configuration release];
  _string = nil;
  _configuration = nil;
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(SVRSolverTextAttachment*)SVR_attachment;
{
  return (SVRSolverTextAttachment*)[self attachment];
}

// MARK: Init

-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  self = [super init];
  XPParameterRaise(self);
  
  [self setAttachment:attachment];
  _cellSize = [self __calculateCellSize];

  return self;
}

+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
{
  return [[[SVRSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
}

// MARK: Custom Drawing

+(NSDictionary*)attributesWithFont:(NSFont*)font
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

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
{
  NSDictionary *attributes = [[self class] attributesWithFont:[[self SVR_attachment] font]
                                                        color:[[self SVR_attachment] foregroundColor]];
  NSSize padding = [[[self SVR_attachment] class] textPadding];
  SVRSolverTextAttachmentBackground background = [[self SVR_attachment] background];
  switch (background) {
    case SVRSolverTextAttachmentBackgroundCapsuleFill:
      [self __drawBackgroundCapsuleFillInRect:cellFrame];
      break;
    case SVRSolverTextAttachmentBackgroundCapsuleStroke:
      [self __drawBackgroundCapsuleStrokeInRect:cellFrame];
      break;
    case SVRSolverTextAttachmentBackgroundLegacyBoxStroke:
      [[[self SVR_attachment] backgroundColor] set];
      NSFrameRect(cellFrame);
      break;
    default:
      XPLogAssrt1(NO, @"SVRSolverTextAttachmentBackground(%d) unknown case", (int)background);
      break;
  }
  cellFrame.origin.y += padding.height / 2.0;
  [[[self SVR_attachment] string] drawInRect:cellFrame withAttributes:attributes];
  XPLogExtra2(@"drawString:`%@` withFrame:%@", [[self SVR_attachment] string], NSStringFromRect(cellFrame));
}

-(void)__drawBackgroundCapsuleFillInRect:(NSRect)_rect;
{
#ifdef XPSupportsNSBezierPath
  XPFloat stroke = 1.0;
  NSRect  rect = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *mixColor = [[self SVR_attachment] mixColor];
  NSColor *backgroundColor = [[self SVR_attachment] backgroundColor];
  NSColor *strokeColor = [backgroundColor blendedColorWithFraction:0.5 ofColor:mixColor];
  NSBezierPath *path = [NSBezierPath XP_bezierPathWithRoundedRect:rect
                                                          xRadius:radius
                                                          yRadius:radius];
  
  XPParameterRaise(mixColor);
  XPParameterRaise(backgroundColor);
  XPParameterRaise(strokeColor);
  XPParameterRaise(path);
  
  [backgroundColor set];
  [path fill];
  [path setLineWidth:stroke];
  [strokeColor set];
  [path stroke];
#else
  XPLogRaise(@"System does not support NSBezierPath");
#endif
}

-(void)__drawBackgroundCapsuleStrokeInRect:(NSRect)_rect;
{
#ifdef XPSupportsNSBezierPath
  XPFloat stroke = 2.0;
  NSRect  rect   = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *strokeColor = [[self SVR_attachment] backgroundColor];
  NSBezierPath *path   = [NSBezierPath XP_bezierPathWithRoundedRect:rect
                                                            xRadius:radius
                                                            yRadius:radius];
  
  XPParameterRaise(strokeColor);
  XPParameterRaise(path);
  
  [strokeColor set];
  [path setLineWidth:stroke];
  [path stroke];
#else
  XPLogRaise(@"System does not support NSBezierPath");
#endif
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  return _cellSize;
}

-(NSSize)__calculateCellSize;
{
  SVRSolverTextAttachment *attachment = [self SVR_attachment];
  NSDictionary *attributes = [[self class] attributesWithFont:[attachment font]
                                                        color:[attachment foregroundColor]];
  NSSize size = [[attachment string] sizeWithAttributes:attributes];
  NSSize padding = [[attachment class] textPadding];
  size.width += padding.width;
  size.height += padding.height;
  return size;
}

-(NSPoint)cellBaselineOffset;
{
  NSPoint output = [super cellBaselineOffset];

  XPFloat capHeight    = [[[self SVR_attachment] font] capHeight];
  XPFloat attachHeight = [self cellSize].height;
  XPFloat offset       = (capHeight - attachHeight) / 2.0;
  
  output.y += offset;
  return output;
}

// MARK: Protocol (Unused)

-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;
{
  XPLogAssrt2(NO, @"higlight:%@ withFrame:%@", (flag) ? @"YES" : @"NO", NSStringFromRect(cellFrame));
}

// MARK: Dealloc

-(void)dealloc;
{
  XPLogExtra1(@"%p", self);
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachment (NSCoding)

+(BOOL)supportsSecureCoding;
{
  return YES;
}

-(BOOL)isEqual:(SVRSolverTextAttachment*)rhs;
{
  if ([rhs class] != [SVRSolverTextAttachment class]) { return NO; }
  return [[self string]  isEqualToString:[rhs string]]
      && [[self font           ] isEqual:[rhs font]]
      && [[self mixColor       ] isEqual:[rhs mixColor]]
      && [[self foregroundColor] isEqual:[rhs foregroundColor]]
      && [[self backgroundColor] isEqual:[rhs backgroundColor]]
      && [ self background     ] == [rhs background];
}

-(id)initWithCoder:(NSCoder *)coder;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  
  self = [super initWithCoder:coder];
  XPParameterRaise(self);
  
  _string = [[coder XP_decodeObjectOfClass:[NSString class] forKey:@"string"] retain];
  _configuration = [[coder XP_decodeObjectOfClass:[NSDictionary class] forKey:@"configuration"] retain];
  
  XPParameterRaise(_string);
  XPParameterRaise(_configuration);
  
  [wrapper setPreferredFilename:_string];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  
  return self;
}

-(void)encodeWithCoder:(NSCoder*)coder;
{
  [super encodeWithCoder:coder];
  [coder XP_encodeObject:_string forKey:@"string"];
  [coder XP_encodeObject:_configuration forKey:@"configuration"];
}

@end

@implementation SVRSolverTextAttachmentCell (NSCoding)
+(BOOL)supportsSecureCoding;
{
  return YES;
}

-(BOOL)isEqual:(SVRSolverTextAttachmentCell*)rhs;
{
  if ([rhs class] != [SVRSolverTextAttachmentCell class]) { return NO; }
  return [[self attachment] isEqual:[rhs attachment]];
}

-(id)initWithCoder:(NSCoder *)coder;
{
  self = [super initWithCoder:coder];
  XPParameterRaise(self);
  return self;
}

-(void)encodeWithCoder:(NSCoder*)coder;
{
  [super encodeWithCoder:coder];
}

@end
