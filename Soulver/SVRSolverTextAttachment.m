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

-(XPUserInterfaceStyle)userInterfaceStyle;
{
  return _userInterfaceStyle;
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
  _toDrawString = [[SVRSolverSolutionTextAttachment toDrawStringWithSolution:solution] retain];
  _toDrawFont   = [[SVRSolverSolutionTextAttachment toDrawFont] retain];
  _toDrawColor  = [[SVRSolverSolutionTextAttachment toDrawColor] retain];
  _neighorFont  = [[SVRSolverSolutionTextAttachment neighborFont] retain];
  _userInterfaceStyle = [SVRSolverSolutionTextAttachment userInterfaceStyle];
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
+(XPUserInterfaceStyle)userInterfaceStyle;
{
  return [[NSUserDefaults standardUserDefaults] SVR_userInterfaceStyle];
}

// MARK: Silence warnings in OpenStep
// for some reason OpenStep doesn't see the superclass
// implementation of these methods and gives warnings
#ifndef MAC_OS_X_VERSION_10_0
-(NSString*)toDrawString; { return [super toDrawString]; }
-(NSFont*)toDrawFont;     { return [super toDrawFont];   }
-(NSColor*)toDrawColor;   { return [super toDrawColor];  }
-(NSFont*)neighorFont;    { return [super neighorFont];  }
-(XPUserInterfaceStyle)userInterfaceStyle; { return [super userInterfaceStyle]; }
#endif

@end

@implementation SVRSolverErrorTextAttachment

// MARK: Init

-(id)initWithError:(SVRSolverError)error;
{
  NSFileWrapper *wrapper = [[[NSFileWrapper alloc] init] autorelease];
  self = [super initWithFileWrapper:wrapper];
  _toDrawString = [[SVRSolverErrorTextAttachment toDrawStringWithError:error] retain];
  _toDrawFont   = [[SVRSolverErrorTextAttachment toDrawFont] retain];
  _toDrawColor  = [[SVRSolverErrorTextAttachment toDrawColor] retain];
  _neighorFont  = [[SVRSolverErrorTextAttachment neighborFont] retain];
  _userInterfaceStyle = [SVRSolverErrorTextAttachment userInterfaceStyle];
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
+(XPUserInterfaceStyle)userInterfaceStyle;
{
  return [[NSUserDefaults standardUserDefaults] SVR_userInterfaceStyle];
}

// MARK: Silence warnings in OpenStep
// for some reason OpenStep doesn't see the superclass
// implementation of these methods and gives warnings
#ifndef MAC_OS_X_VERSION_10_0
-(NSString*)toDrawString; { return [super toDrawString]; }
-(NSFont*)toDrawFont;     { return [super toDrawFont];   }
-(NSColor*)toDrawColor;   { return [super toDrawColor];  }
-(NSFont*)neighorFont;    { return [super neighorFont];  }
-(XPUserInterfaceStyle)userInterfaceStyle; { return [super userInterfaceStyle]; }
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
  if ([[self SVR_attachment] userInterfaceStyle] == XPUserInterfaceStyleDark) {
    NSDrawGrayBezel(cellFrame, cellFrame);
  } else {
    NSDrawWhiteBezel(cellFrame, cellFrame);
  }
  [[[self SVR_attachment] toDrawString] drawInRect:cellFrame
                                    withAttributes:[self toDrawAttributes]];
  XPLogExtra1(@"drawWithFrame:%@", NSStringFromRect(cellFrame));
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
