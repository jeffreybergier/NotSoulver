//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "MATHSolverTextAttachment.h"

@implementation MATHSolverTextAttachment

+(NSSize)textPadding;
{
#ifdef AFF_NSBezierPathNone
  return NSMakeSize(8, 2);
#else
  return NSMakeSize(12, 4);
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
  return [_configuration objectForKey:MATHSolverTextAttachmentMixColorKey];
}

-(MATHSolverTextAttachmentBackground)background;
{
  return (MATHSolverTextAttachmentBackground)[[_configuration objectForKey:MATHSolverTextAttachmentBackgroundKey] XP_integerValue];
}

-(id)initWithString:(NSString*)string
             styles:(MATHSolverTextAttachmentStyles)styles;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  
  self = [super initWithFileWrapper:wrapper];
  
  XPParameterRaise(self);
  XPParameterRaise(string);
  XPParameterRaise([styles objectForKey:NSFontAttributeName]);
  XPParameterRaise([styles objectForKey:NSForegroundColorAttributeName]);
  XPParameterRaise([styles objectForKey:NSBackgroundColorAttributeName]);
  XPParameterRaise([styles objectForKey:MATHSolverTextAttachmentMixColorKey]);
  XPParameterRaise([styles objectForKey:MATHSolverTextAttachmentBackgroundKey]);

  _string = [string retain];
  _configuration = [styles retain];
  
  [wrapper setPreferredFilename:string];
  [self setAttachmentCell:[MATHSolverTextAttachmentCell cellWithAttachment:self]];
  
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution
                     styles:(MATHSolverTextAttachmentStyles)styles;
{
  NSString *toDrawString = [@"=" stringByAppendingString:[solution description]];
  return [[[MATHSolverTextAttachment alloc] initWithString:toDrawString
                                                    styles:styles] autorelease];
}

+(id)attachmentWithPreviousSolution:(NSDecimalNumber*)previousSolution
                           operator:(MATHSolverOperator)operator
                             styles:(MATHSolverTextAttachmentStyles)styles;
{
  NSString *toDrawString = [[previousSolution description] stringByAppendingString:RawStringForOperator(operator)];
  return [[[MATHSolverTextAttachment alloc] initWithString:toDrawString
                                                    styles:styles] autorelease];
}

+(id)attachmentWithError:(MATHCalculationError)error
                  styles:(MATHSolverTextAttachmentStyles)styles;
{
  NSString *toDrawString = [@"=" stringByAppendingString:MATHSolverDescriptionForError(error)];
  return [[[MATHSolverTextAttachment alloc] initWithString:toDrawString
                                                    styles:styles] autorelease];
}

// MARK: Dealloc

-(void)dealloc;
{
  XPLogExtra1(@"<%@>", XPPointerString(self));
  [_string release];
  [_configuration release];
  _string = nil;
  _configuration = nil;
  [super dealloc];
}

@end

@implementation MATHSolverTextAttachmentCell

// MARK: Properties

-(MATHSolverTextAttachment*)MATH_attachment;
{
  return (MATHSolverTextAttachment*)[self attachment];
}

// MARK: Init

-(id)initWithAttachment:(MATHSolverTextAttachment*)attachment;
{
  self = [super init];
  XPParameterRaise(self);
  
  [self setAttachment:attachment];
  _cellSize = [self __calculateCellSize];

  return self;
}

+(id)cellWithAttachment:(MATHSolverTextAttachment*)attachment;
{
  return [[[MATHSolverTextAttachmentCell alloc] initWithAttachment:attachment] autorelease];
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
  NSDictionary *attributes = [[self class] attributesWithFont:[[self MATH_attachment] font]
                                                        color:[[self MATH_attachment] foregroundColor]];
  NSSize padding = [[[self MATH_attachment] class] textPadding];
  MATHSolverTextAttachmentBackground background = [[self MATH_attachment] background];
  switch (background) {
    case MATHSolverTextAttachmentBackgroundCapsuleFill:
      [self __drawBackgroundCapsuleFillInRect:cellFrame];
      break;
    case MATHSolverTextAttachmentBackgroundCapsuleStroke:
      [self __drawBackgroundCapsuleStrokeInRect:cellFrame];
      break;
    case MATHSolverTextAttachmentBackgroundLegacyBoxStroke:
      [[[self MATH_attachment] backgroundColor] set];
      NSFrameRect(cellFrame);
      break;
    default:
      XPLogAssrt1(NO, @"MATHSolverTextAttachmentBackground(%d) unknown case", (int)background);
      break;
  }
  cellFrame.origin.y += padding.height / 2.0;
  [[[self MATH_attachment] string] drawInRect:cellFrame withAttributes:attributes];
  XPLogExtra2(@"drawString:`%@` withFrame:%@", [[self MATH_attachment] string], NSStringFromRect(cellFrame));
}

-(void)__drawBackgroundCapsuleFillInRect:(NSRect)_rect;
{
#ifdef AFF_NSBezierPathNone
  XPLogRaise(@"System does not support NSBezierPath");
#else
  XPFloat stroke = 1.0;
  NSRect  rect = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *mixColor = [[self MATH_attachment] mixColor];
  NSColor *backgroundColor = [[self MATH_attachment] backgroundColor];
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
#endif
}

-(void)__drawBackgroundCapsuleStrokeInRect:(NSRect)_rect;
{
#ifdef AFF_NSBezierPathNone
  XPLogRaise(@"System does not support NSBezierPath");
#else
  XPFloat stroke = 2.0;
  NSRect  rect   = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  NSColor *strokeColor = [[self MATH_attachment] backgroundColor];
  NSBezierPath *path   = [NSBezierPath XP_bezierPathWithRoundedRect:rect
                                                            xRadius:radius
                                                            yRadius:radius];
  
  XPParameterRaise(strokeColor);
  XPParameterRaise(path);
  
  [strokeColor set];
  [path setLineWidth:stroke];
  [path stroke];
#endif
}

// MARK: Protocol (Used)

-(NSSize)cellSize;
{
  return _cellSize;
}

-(NSSize)__calculateCellSize;
{
  MATHSolverTextAttachment *attachment = [self MATH_attachment];
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

  XPFloat capHeight    = [[[self MATH_attachment] font] capHeight];
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
  XPLogExtra1(@"<%@>", XPPointerString(self));
  [super dealloc];
}

@end

@implementation MATHSolverTextAttachment (NSCoding)

+(BOOL)supportsSecureCoding;
{
  return YES;
}

-(BOOL)isEqual:(MATHSolverTextAttachment*)rhs;
{
  if ([rhs class] != [MATHSolverTextAttachment class]) { return NO; }
  return [[self string]  isEqualToString:[rhs string         ]]
      && [[self font           ] isEqual:[rhs font           ]]
      && [[self mixColor       ] isEqual:[rhs mixColor       ]]
      && [[self foregroundColor] isEqual:[rhs foregroundColor]]
      && [[self backgroundColor] isEqual:[rhs backgroundColor]]
      && [ self background     ] == [rhs background           ];
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
  [self setAttachmentCell:[MATHSolverTextAttachmentCell cellWithAttachment:self]];
  
  return self;
}

-(void)encodeWithCoder:(NSCoder*)coder;
{
  [super encodeWithCoder:coder];
  [coder XP_encodeObject:_string forKey:@"string"];
  [coder XP_encodeObject:_configuration forKey:@"configuration"];
}

@end

@implementation MATHSolverTextAttachmentCell (NSCoding)
+(BOOL)supportsSecureCoding;
{
  return YES;
}

-(BOOL)isEqual:(MATHSolverTextAttachmentCell*)rhs;
{
  if ([rhs class] != [MATHSolverTextAttachmentCell class]) { return NO; }
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
