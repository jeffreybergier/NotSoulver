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
#import "NSUserDefaults+Soulver.h"

@implementation SVRSolverTextAttachmentImp

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

// MARK: Init
-(id)init;
{
  self = [super init];
  _toDrawString = nil;
  _toDrawFont   = nil;
  _toDrawColor  = nil;
  _neighorFont  = nil;
  return self;
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

@implementation SVRSolverSolutionTextAttachment

// MARK: Init

-(id)initWithSolution:(NSDecimalNumber*)solution;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  self = [super initWithFileWrapper:wrapper];
  _toDrawString = [[[self class] toDrawStringWithSolution:solution] retain];
  _toDrawFont   = [[[self class] toDrawFont]   retain];
  _toDrawColor  = [[[self class] toDrawColor]  retain];
  _neighorFont  = [[[self class] neighborFont] retain];
  _borderStyle  = [ [self class] borderStyle];
  [wrapper setPreferredFilename:_toDrawString];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  return self;
}

+(id)attachmentWithSolution:(NSDecimalNumber*)solution;
{
  return [[[SVRSolverSolutionTextAttachment alloc] initWithSolution:solution] autorelease];
}

// MARK: Business Logic
+(NSString*)toDrawStringWithSolution:(NSDecimalNumber*)solution;
{
  return [@"=" stringByAppendingString:[solution description]];
}
+(NSFont*)toDrawFont;
{
  return [[NSUserDefaults standardUserDefaults] SVR_fontForTheme:SVRThemeFontMath];
}
+(NSColor*)toDrawColor;
{
  return [[NSUserDefaults standardUserDefaults] SVR_colorForTheme:SVRThemeColorSolution];
}
+(NSFont*)neighborFont;
{
  return [[NSUserDefaults standardUserDefaults] SVR_fontForTheme:SVRThemeFontMath];
}
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

// MARK: Silence warnings in OpenStep
// for some reason OpenStep doesn't see the superclass
// implementation of these methods and gives warnings
#ifndef MAC_OS_X_VERSION_10_0
-(NSString*)toDrawString; { return [super toDrawString]; }
-(NSFont*)toDrawFont;     { return [super toDrawFont];   }
-(NSColor*)toDrawColor;   { return [super toDrawColor];  }
-(NSFont*)neighorFont;    { return [super neighorFont];  }
-(SVRSolverTextAttachmentBorderStyle)borderStyle; { return [super borderStyle]; }
#endif

@end

@implementation SVRSolverErrorTextAttachment

// MARK: Init

-(id)initWithError:(SVRSolverError)error;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  self = [super initWithFileWrapper:wrapper];
  _toDrawString = [[[self class] toDrawStringWithError:error] retain];
  _toDrawFont   = [[[self class] toDrawFont]   retain];
  _toDrawColor  = [[[self class] toDrawColor]  retain];
  _neighorFont  = [[[self class] neighborFont] retain];
  _borderStyle  = [ [self class] borderStyle];
  [wrapper setPreferredFilename:_toDrawString];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  return self;
}

+(id)attachmentWithError:(SVRSolverError)error;
{
  return [[[SVRSolverErrorTextAttachment alloc] initWithError:error] autorelease];
}

// MARK: Business Logic
+(NSString*)toDrawStringWithError:(SVRSolverError)error;
{
  return [@"=" stringByAppendingString:SVRSolverDescriptionForError(error)];
}
+(NSFont*)toDrawFont;
{
  return [[NSUserDefaults standardUserDefaults] SVR_fontForTheme:SVRThemeFontError];
}
+(NSColor*)toDrawColor;
{
  return [[NSUserDefaults standardUserDefaults] SVR_colorForTheme:SVRThemeColorErrorText];
}
+(NSFont*)neighborFont;
{
  return [[NSUserDefaults standardUserDefaults] SVR_fontForTheme:SVRThemeFontMath];
}
+(SVRSolverTextAttachmentBorderStyle)borderStyle;
{
  switch ([[NSUserDefaults standardUserDefaults] SVR_userInterfaceStyle]) {
    case XPUserInterfaceStyleDark:
      return SVRSolverTextAttachmentBorderStyleRecessedGray;
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleUnspecified:
    default:
      return SVRSolverTextAttachmentBorderStyleRecessedGray;
  }
}

// MARK: Silence warnings in OpenStep
// for some reason OpenStep doesn't see the superclass
// implementation of these methods and gives warnings
#ifndef MAC_OS_X_VERSION_10_0
-(NSString*)toDrawString; { return [super toDrawString]; }
-(NSFont*)toDrawFont;     { return [super toDrawFont];   }
-(NSColor*)toDrawColor;   { return [super toDrawColor];  }
-(NSFont*)neighorFont;    { return [super neighorFont];  }
-(SVRSolverTextAttachmentBorderStyle)borderStyle; { return [super borderStyle]; }
#endif

@end

@implementation SVRSolverPreviousSolutionTextAttachment

// MARK: Init
-(id)initWithPreviousSolution:(NSDecimalNumber*)previousSolution
                     operator:(SVRSolverOperator)operator;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  self = [super initWithFileWrapper:wrapper];
  _toDrawString = [[[self class] toDrawStringWithPreviousSolution:previousSolution
                                                         operator:operator] retain];
  _toDrawFont   = [[[self class] toDrawFont]   retain];
  _toDrawColor  = [[[self class] toDrawColor]  retain];
  _neighorFont  = [[[self class] neighborFont] retain];
  _borderStyle  = [ [self class] borderStyle];
  [wrapper setPreferredFilename:_toDrawString];
  [self setAttachmentCell:[SVRSolverTextAttachmentCell cellWithAttachment:self]];
  return self;
}

+(id)attachmentWithPreviousSolution:(NSDecimalNumber*)previousSolution
                           operator:(SVRSolverOperator)operator;
{
  return [[[SVRSolverPreviousSolutionTextAttachment alloc] initWithPreviousSolution:previousSolution
                                                                           operator:operator] autorelease];
}

// MARK: Business Logic
+(NSString*)toDrawStringWithPreviousSolution:(NSDecimalNumber*)previousSolution
                                    operator:(SVRSolverOperator)operator;
{
  return [[previousSolution description] stringByAppendingString:RawStringForOperator(operator)];
}
+(NSFont*)toDrawFont;
{
  return [[NSUserDefaults standardUserDefaults] SVR_fontForTheme:SVRThemeFontMath];
}
+(NSColor*)toDrawColor;
{
  return [[NSUserDefaults standardUserDefaults] SVR_colorForTheme:SVRThemeColorOperator];
}
+(NSFont*)neighborFont;
{
  return [[NSUserDefaults standardUserDefaults] SVR_fontForTheme:SVRThemeFontMath];
}
+(SVRSolverTextAttachmentBorderStyle)borderStyle;
{
  return SVRSolverTextAttachmentBorderStyleDotted;
}

// MARK: Silence warnings in OpenStep
// for some reason OpenStep doesn't see the superclass
// implementation of these methods and gives warnings
#ifndef MAC_OS_X_VERSION_10_0
-(NSString*)toDrawString; { return [super toDrawString]; }
-(NSFont*)toDrawFont;     { return [super toDrawFont];   }
-(NSColor*)toDrawColor;   { return [super toDrawColor];  }
-(NSFont*)neighorFont;    { return [super neighorFont];  }
-(SVRSolverTextAttachmentBorderStyle)borderStyle; { return [super borderStyle]; }
#endif

@end

@implementation SVRSolverTextAttachmentCell

// MARK: Properties

-(NSDictionary*)toDrawAttributes;
{
  return [[_toDrawAttributes retain] autorelease];
}

-(id<SVRSolverTextAttachment>)SVR_attachment;
{
  return (id<SVRSolverTextAttachment>)[self attachment];
}

// MARK: Init

-(id)initWithAttachment:(NSTextAttachment<SVRSolverTextAttachment>*)attachment;
{
  self = [super init];
  [self setAttachment:attachment];
  _toDrawAttributes = [
    [SVRSolverTextAttachmentCell toDrawAttributesWithFont:[attachment toDrawFont]
                                                    color:[attachment toDrawColor]]
    retain];
  return self;
}

+(id)cellWithAttachment:(NSTextAttachment<SVRSolverTextAttachment>*)attachment;
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
  // TODO: Play with the drawing styles
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
  // TODO: Figure out how to always make this render in vertically center
  NSFont *font = [[self SVR_attachment] toDrawFont];
  XPFloat capHeight = [font capHeight];
  XPFloat underline = fabs([font underlinePosition]);
  XPFloat calculation = 0-((capHeight/2)+underline);
  return NSMakePoint(0, calculation);
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
