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

-(NSFont*)neighborFont;
{
  return [[_neighborFont retain] autorelease];
}

-(SVRSolverAttachmentTextPurpose)borderStyle;
{
  return _borderStyle;
}

-(id)initWithString:(NSString*)stringToDraw
             styles:(SVRSolverTextAttachmentStyles)styles;
{
  NSNumber *borderStyleNumber = [styles objectForKey:SVRSolverTextAttachmentPurpose];
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  
  self = [super initWithFileWrapper:wrapper];
  NSCParameterAssert(self);
  
  _toDrawString = [stringToDraw retain];
  _toDrawFont   = [[styles objectForKey:NSFontAttributeName] retain];
  _toDrawColor  = [[styles objectForKey:NSForegroundColorAttributeName] retain];
  _neighborFont = [[styles objectForKey:SVRSolverTextAttachmentPurposeNeighborFont] retain];
  _borderStyle  = (SVRSolverAttachmentTextPurpose)[borderStyleNumber XP_integerValue];
  
  NSCParameterAssert(_toDrawString);
  NSCParameterAssert(_toDrawFont);
  NSCParameterAssert(_toDrawColor);
  NSCParameterAssert(_neighborFont);
  NSCParameterAssert(borderStyleNumber != nil);
  
  [wrapper setPreferredFilename:_toDrawString];
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
  [_toDrawString release];
  [_toDrawFont   release];
  [_toDrawColor  release];
  [_neighborFont  release];
  _toDrawString = nil;
  _toDrawFont   = nil;
  _toDrawColor  = nil;
  _neighborFont = nil;
  [super dealloc];
}

@end

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(NSDictionary*)toDrawAttributes;
{
  return [[_toDrawAttributes retain] autorelease];
}

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
  _toDrawAttributes = [[SVRSolverTextAttachmentCell toDrawAttributesWithFont:[attachment toDrawFont]
                                                                       color:[attachment toDrawColor]] retain];
  return self;
}

+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;
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
//  switch ([[self SVR_attachment] borderStyle]) {
//    case SVRSolverTextAttachmentBorderStyleColored:
//      [[[self SVR_attachment] toDrawColor] set];
//      NSFrameRect(cellFrame);
//      break;
//    case SVRSolverTextAttachmentBorderStyleRecessedGray:
//      NSDrawGrayBezel(cellFrame, cellFrame);
//      break;
//    case SVRSolverTextAttachmentBorderStyleRecessedWhite:
//      NSDrawWhiteBezel(cellFrame, cellFrame);
//      break;
//    default:
//      XPLogRaise2(@"%@ borderStyle(%d) unsupported", self, [[self SVR_attachment] borderStyle]);
//      break;
//  }
  [self __drawBackgroundForSolutionInRect:cellFrame];
  [[[self SVR_attachment] toDrawString] drawInRect:cellFrame
                                    withAttributes:[self toDrawAttributes]];
  XPLogExtra2(@"drawString:`%@` withFrame:%@", [[self SVR_attachment] toDrawString], NSStringFromRect(cellFrame));
}

-(void)__drawBackgroundForSolutionInRect:(NSRect)_rect;
{
#ifdef XPSupportsNSBezierPath
  // Prepare Object Variables
  XPFloat stroke = 2.0;
  NSRect rect = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *color = [NSColor colorWithCalibratedRed:40/255.0
                                             green:92/255.0
                                              blue:246/255.0
                                             alpha:1.0];
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
  NSDrawWhiteBezel(_rect, _rect);
#endif
}

-(void)__drawBackgroundForPreviousSolutionInRect:(NSRect)_rect;
{
  
}

-(void)__drawBackgroundForErrorInRect:(NSRect)_rect;
{
  
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
  [_toDrawAttributes release];
  _toDrawAttributes = nil;
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
  return [[self toDrawString] isEqualToString:[rhs toDrawString]]
      && [[self toDrawFont]   isEqual:[rhs toDrawFont]]
      && [[self toDrawColor]  isEqual:[rhs toDrawColor]]
      && [[self neighborFont] isEqual:[rhs neighborFont]]
      && [self borderStyle] == [rhs borderStyle];
}

-(id)initWithCoder:(NSCoder *)coder;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  NSNumber *__borderStyle = nil;
  
  self = [super initWithCoder:coder];
  NSCParameterAssert(self);
  
  _toDrawString = [[coder XP_decodeObjectOfClass:[NSString class] forKey:@"toDrawString"] retain];
  _toDrawFont   = [[coder XP_decodeObjectOfClass:[NSFont   class] forKey:@"toDrawFont"]   retain];
  _toDrawColor  = [[coder XP_decodeObjectOfClass:[NSColor  class] forKey:@"toDrawColor"]  retain];
  _neighborFont = [[coder XP_decodeObjectOfClass:[NSFont   class] forKey:@"neighborFont"] retain];
  __borderStyle =  [coder XP_decodeObjectOfClass:[NSNumber class] forKey:@"borderStyle"];
  _borderStyle  = (SVRSolverAttachmentTextPurpose)[__borderStyle XP_integerValue];
  
  NSCParameterAssert(_toDrawString);
  NSCParameterAssert(_toDrawFont);
  NSCParameterAssert(_toDrawColor);
  NSCParameterAssert(_neighborFont);
  NSCParameterAssert(__borderStyle != nil);
  
  [wrapper setPreferredFilename:_toDrawString];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  
  return self;
}

-(void)encodeWithCoder:(NSCoder*)coder;
{
  [super encodeWithCoder:coder];
  [coder XP_encodeObject:_toDrawString forKey:@"toDrawString"];
  [coder XP_encodeObject:_toDrawFont   forKey:@"toDrawFont"];
  [coder XP_encodeObject:_toDrawColor  forKey:@"toDrawColor"];
  [coder XP_encodeObject:_neighborFont forKey:@"neighborFont"];
  [coder XP_encodeObject:[NSNumber XP_numberWithInteger:_borderStyle] forKey:@"borderStyle"];
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
