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

-(NSFont*)neighborFont;
{
  return [_configuration objectForKey:SVRSolverTextAttachmentNeighborFontKey];
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
  
  NSCParameterAssert(self);
  NSCParameterAssert(string);
  NSCParameterAssert([styles objectForKey:NSFontAttributeName]);
  NSCParameterAssert([styles objectForKey:SVRSolverTextAttachmentNeighborFontKey]);
  NSCParameterAssert([styles objectForKey:NSForegroundColorAttributeName]);
  NSCParameterAssert([styles objectForKey:NSBackgroundColorAttributeName]);
  NSCParameterAssert([styles objectForKey:SVRSolverTextAttachmentBackgroundKey]);

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
  XPLogExtra1(@"DEALLOC: %@", self);
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
  NSCParameterAssert(self);
  [self setAttachment:attachment];
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
  switch ([[self SVR_attachment] background]) {
    case SVRSolverTextAttachmentBackgroundCapsuleFill:
      [self __drawBackgroundCapsuleFillInRect:cellFrame];
      break;
    case SVRSolverTextAttachmentBackgroundCapsuleStroke:
      [self __drawBackgroundCapsuleStrokeInRect:cellFrame];
      break;
    case SVRSolverTextAttachmentBackgroundLegacyBoxWhite:
      NSDrawWhiteBezel(cellFrame, cellFrame);
      break;
    case SVRSolverTextAttachmentBackgroundLegacyBoxGray:
      NSDrawGrayBezel(cellFrame, cellFrame);
      break;
    case SVRSolverTextAttachmentBackgroundLegacyBoxStroke:
      [[[self SVR_attachment] foregroundColor] set];
      NSFrameRect(cellFrame);
      break;
    default:
      NSCAssert2(NO, @"%@ SVRSolverTextAttachmentBackground(%d) unknown case",
                 self, [[self SVR_attachment] background]);
      break;
  }
  [[[self SVR_attachment] string] drawInRect:cellFrame withAttributes:attributes];
  XPLogExtra2(@"drawString:`%@` withFrame:%@", [[self SVR_attachment] string], NSStringFromRect(cellFrame));
}

-(void)__drawBackgroundCapsuleFillInRect:(NSRect)_rect;
{
#ifdef XPSupportsNSBezierPath
  // Prepare Object Variables
  XPFloat stroke = 2.0;
  NSRect rect = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *color = [[self SVR_attachment] backgroundColor];
  NSColor *colorDark = [color blendedColorWithFraction:0.3 ofColor:[NSColor blackColor]];
  NSBezierPath *path = [NSBezierPath XP_bezierPathWithRoundedRect:rect
                                                          xRadius:radius
                                                          yRadius:radius];
  
  NSCParameterAssert(color);
  NSCParameterAssert(path);
  
  [color set];
  [path fill];
  [path setLineWidth:stroke];
  [colorDark set];
  [path stroke];
#else
  NSCAssert1(NO, @"%@ System does not support NSBezierPath", self);
#endif
}

-(void)__drawBackgroundCapsuleStrokeInRect:(NSRect)_rect;
{
#ifdef XPSupportsNSBezierPath
  // Prepare Object Variables
  XPFloat stroke = 2.0;
  NSRect rect = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *color = [[self SVR_attachment] backgroundColor];
  NSBezierPath *path = [NSBezierPath XP_bezierPathWithRoundedRect:rect
                                                          xRadius:radius
                                                          yRadius:radius];
  
  NSCParameterAssert(color);
  NSCParameterAssert(path);
  
  [color set];
  [path setLineWidth:stroke];
  [path stroke];
#else
  NSCAssert1(NO, @"%@ System does not support NSBezierPath", self);
#endif
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  NSDictionary *attributes = [[self class] attributesWithFont:[[self SVR_attachment] font]
                                                        color:[[self SVR_attachment] foregroundColor]];
  NSSize size = [[[self SVR_attachment] string] sizeWithAttributes:attributes];
  size.width += 8;
  return size;
}

-(NSPoint)cellBaselineOffset;
{
  NSPoint output = [super cellBaselineOffset];
  XPFloat height = [self cellSize].height;
  NSFont *toDrawFont = [[self SVR_attachment] font];
  output.y -= (height/2.0) + ([toDrawFont descender]/2.0);
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
  return [[self string] isEqualToString:[rhs string]]
      && [[self font]   isEqual:[rhs font]]
      && [[self foregroundColor]  isEqual:[rhs foregroundColor]]
      && [[self neighborFont] isEqual:[rhs neighborFont]]
      && [self background] == [rhs background];
}

-(id)initWithCoder:(NSCoder *)coder;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  
  self = [super initWithCoder:coder];
  NSCParameterAssert(self);
  
  _string = [[coder XP_decodeObjectOfClass:[NSString class] forKey:@"string"] retain];
  _configuration = [[coder XP_decodeObjectOfClass:[NSDictionary class] forKey:@"configuration"] retain];
  
  NSCParameterAssert(_string);
  NSCParameterAssert(_configuration);
  
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
  NSCParameterAssert(self);
  return self;
}

-(void)encodeWithCoder:(NSCoder*)coder;
{
  [super encodeWithCoder:coder];
}

@end
