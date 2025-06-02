//
// MIT License
//
// Copyright (c) 2025 Jeffrey Bergier
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

#import "SVRAccessoryWindowViews.h"

// MARK: SVRAccessoryWindowKeypadView

NSRect SVR_rectForKeypadButtonOfKind(SVRKeypadButtonKind kind)
{
  XPFloat windowPad  = SVRAccessoryWindowKeypadWindowPadding;
  XPFloat buttonVPad = SVRAccessoryWindowKeypadWindowButtonVPadding;
  XPFloat buttonHPad = SVRAccessoryWindowKeypadWindowButtonHPadding;
  XPFloat groupPad   = SVRAccessoryWindowKeypadWindowGroupSpacing;
  NSSize  buttonSize = SVRAccessoryWindowKeypadWindowButtonSize;
  XPInteger column     = -1;
  XPInteger row        = -1;
  XPFloat   rowPadding = 0;
  NSRect    output     = NSZeroRect;
  
  switch (kind) {
    case SVRKeypadButtonKind1:
    case SVRKeypadButtonKindNegative:
    case SVRKeypadButtonKind4:
    case SVRKeypadButtonKind7:
    case SVRKeypadButtonKindAdd:
    case SVRKeypadButtonKindMultiply:
    case SVRKeypadButtonKindPower:
    case SVRKeypadButtonKindDelete:
      column = 0;
      break;
    case SVRKeypadButtonKindEqual:
    case SVRKeypadButtonKind0:
    case SVRKeypadButtonKind2:
    case SVRKeypadButtonKind5:
    case SVRKeypadButtonKind8:
    case SVRKeypadButtonKindSubtract:
    case SVRKeypadButtonKindDivide:
    case SVRKeypadButtonKindRoot:
      column = 1;
      break;
    case SVRKeypadButtonKindDecimal:
    case SVRKeypadButtonKind3:
    case SVRKeypadButtonKind6:
    case SVRKeypadButtonKind9:
    case SVRKeypadButtonKindBRight:
    case SVRKeypadButtonKindBLeft:
    case SVRKeypadButtonKindLog:
      column = 2;
      break;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRAccessoryWindowKeypadViewKind(%d)", (int)kind);
      break;
  }
  
  switch (kind) {
    case SVRKeypadButtonKindDelete:
    case SVRKeypadButtonKindEqual:
      row = 0;
      break;
    case SVRKeypadButtonKindNegative:
    case SVRKeypadButtonKind0:
    case SVRKeypadButtonKindDecimal:
      row = 1;
      break;
    case SVRKeypadButtonKind1:
    case SVRKeypadButtonKind2:
    case SVRKeypadButtonKind3:
      row = 2;
      break;
    case SVRKeypadButtonKind4:
    case SVRKeypadButtonKind5:
    case SVRKeypadButtonKind6:
      row = 3;
      break;
    case SVRKeypadButtonKind7:
    case SVRKeypadButtonKind8:
    case SVRKeypadButtonKind9:
      row = 4;
      break;
    case SVRKeypadButtonKindAdd:
    case SVRKeypadButtonKindSubtract:
    case SVRKeypadButtonKindBRight:
      row = 5;
      break;
    case SVRKeypadButtonKindMultiply:
    case SVRKeypadButtonKindDivide:
    case SVRKeypadButtonKindBLeft:
      row = 6;
      break;
    case SVRKeypadButtonKindPower:
    case SVRKeypadButtonKindRoot:
    case SVRKeypadButtonKindLog:
      row = 7;
      break;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRAccessoryWindowKeypadViewKind(%d)", (int)kind);
      break;
  }
  
  
  if (row > 0) {
    rowPadding += groupPad;
  }
  if (row > 4) {
    rowPadding += groupPad;
  }
  
  output.origin = NSMakePoint(((buttonHPad + buttonSize.width ) * column) + windowPad,
                              ((buttonVPad + buttonSize.height) * row   ) + windowPad + rowPadding);
  output.size = kind == SVRKeypadButtonKindEqual
                      ? NSMakeSize((buttonSize.width * 2) + buttonHPad, buttonSize.height)
                      : buttonSize;
  return output;
}

NSString *SVR_titleForKeypadButtonOfKind(SVRKeypadButtonKind kind)
{
  switch (kind) {
    case SVRKeypadButtonKind1:
    case SVRKeypadButtonKind2:
    case SVRKeypadButtonKind3:
    case SVRKeypadButtonKind4:
    case SVRKeypadButtonKind5:
    case SVRKeypadButtonKind6:
    case SVRKeypadButtonKind7:
    case SVRKeypadButtonKind8:
    case SVRKeypadButtonKind9:
      return [NSString stringWithFormat:@"%d", (int)kind];
    case SVRKeypadButtonKind0:
      return @"0";
    case SVRKeypadButtonKindNegative:
      return @"-";
    case SVRKeypadButtonKindDecimal:
      return @".";
    case SVRKeypadButtonKindDelete:
#ifdef XPSupportsUnicodeUI
      return [NSString stringWithFormat:@"%C", 0x2190];
#else
      return @"<-";
#endif
    case SVRKeypadButtonKindEqual:
      return @"=";
    case SVRKeypadButtonKindAdd:
      return @"+";
    case SVRKeypadButtonKindSubtract:
      return @"-";
    case SVRKeypadButtonKindBRight:
      return @")";
    case SVRKeypadButtonKindMultiply:
      return @"*";
    case SVRKeypadButtonKindDivide:
      return @"/";
    case SVRKeypadButtonKindBLeft:
      return @"(";
    case SVRKeypadButtonKindPower:
      return @"^";
    case SVRKeypadButtonKindRoot:
#ifdef XPSupportsUnicodeUI
      return [NSString stringWithFormat:@"%C", 0x221A];
#else
      return @"root";
#endif
    case SVRKeypadButtonKindLog:
      return @"log";
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRAccessoryWindowKeypadViewKind(%d)", (int)kind);
      return [NSString stringWithFormat:@"%d", (int)kind];
  }
}

NSString *SVR_keyForKeypadButtonOfKind(SVRKeypadButtonKind kind)
{
  switch (kind) {
    case SVRKeypadButtonKindDelete:
      return @"\b";
    case SVRKeypadButtonKindRoot:
      return @"r";
    case SVRKeypadButtonKindLog:
      return @"l";
    default:
      return SVR_titleForKeypadButtonOfKind(kind);
  }
}


@implementation SVRAccessoryWindowKeypadView: NSView

-(id)init;
{
  SVRKeypadButtonKind kind = SVRKeypadButtonKindUnknown;
  NSButton *button = nil;
  
  self = [super init];
  XPParameterRaise(self);
  _equalButton = nil;
  
  for (kind=SVRKeypadButtonKind1; kind<=SVRKeypadButtonKindLog; kind++) {
    button = [NSButton SVR_keypadButtonOfKind:kind];
    [self addSubview:button];
    if (kind == SVRKeypadButtonKindEqual) {
      _equalButton = button;
    }
  }
  
  return self;
}

-(NSButton*)equalButton;
{
  return [[_equalButton retain] autorelease];
}

@end

// MARK: SVRAccessoryWindowAboutView

@implementation SVRAccessoryWindowAboutView

-(id)init;
{
  XPFloat kLeftX = 8;
  XPFloat kLeftWidth = 312;
  XPFloat kRightX = 328;
  XPFloat kRightWidth = 144;
  NSPoint kTagLineOrigin = NSMakePoint(kLeftX-1, kLeftX);
  NSPoint kDedicationTextOrigin = NSMakePoint(kLeftX, 30);
  NSRect  kViewSourceButtonFrame = NSMakeRect(kRightX, kLeftX, kRightWidth, 42);
  NSRect  kSeparatorRect = NSMakeRect(kLeftX, 49, kLeftWidth, 1);
  
  self = [super init];
  XPParameterRaise(self);
  _textField = nil;
  _viewSourceButton = nil;
  
  // NeXT Tagline Image
  [self addSubview:[NSImageView SVR_imageViewWithOrigin:kTagLineOrigin
                                             imageNamed:@"TagLine"]];
  
  // Dedication Text
  [self addSubview:[NSControl SVR_configureControl:[NSTextField SVR_labelWithOrigin:kDedicationTextOrigin]
                                       stringValue:@"This application is dedicated to my grandmother | 1932-2024"
                                              font:[NSFont systemFontOfSize:10]
                                         alignment:NSTextAlignmentLeft
                                             image:nil]];
  
  _viewSourceButton = [[[NSButton alloc] initWithFrame:kViewSourceButtonFrame] autorelease];
  [_viewSourceButton setTitle:@"View Source"];
  [_viewSourceButton setImage:[NSImage imageNamed:@"NeXTLogoMed"]];
  [_viewSourceButton setImagePosition:NSImageLeft];
  [_viewSourceButton setBezelStyle:NSBezelStyleShadowlessSquare];
  [self addSubview:_viewSourceButton];
  
  // Separator Line
  [self addSubview:[NSBox SVR_lineWithFrame:kSeparatorRect]];
  
  return self;
}

-(NSTextField*)textField;
{
  return [[_textField retain] autorelease];
}

-(NSButton*)viewSourceButton;
{
  return [[_viewSourceButton retain] autorelease];
}
@end

@implementation NSControl (SVRAccessoryWindows)

+(NSButton*)SVR_keypadButtonOfKind:(SVRKeypadButtonKind)kind;
{
  SEL buttonAction  = NSSelectorFromString(@"keypadAppend:");
  NSRect buttonRect = SVR_rectForKeypadButtonOfKind(kind);
  NSButton *button  = nil;
  button = [[[NSButton alloc] initWithFrame:buttonRect] autorelease];
  [button setTitle:SVR_titleForKeypadButtonOfKind(kind)];
  [button setKeyEquivalent:SVR_keyForKeypadButtonOfKind(kind)];
  [button setTag:kind];
  [button setAction:buttonAction];
#ifdef XPSupportsButtonStyles
  [button setBezelStyle:XPBezelStyleFlexiblePush];
#endif
  return button;
}

+(NSTextField*)SVR_labelWithOrigin:(NSPoint)origin;
{
  NSRect frame = NSMakeRect(origin.x, origin.y, 0, 0);
  NSTextField *label = [[[NSTextField alloc] initWithFrame:frame] autorelease];
  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setEditable:NO];
  [label setSelectable:NO];
  return label;
}

+(NSImageView*)SVR_imageViewWithOrigin:(NSPoint)origin imageNamed:(NSString*)imageName;
{
  NSImage     *image = [NSImage imageNamed:@"TagLine"];
  NSRect       frame = NSMakeRect(origin.x, origin.y, image.size.width, image.size.height);
  NSImageView *view  = [[[NSImageView alloc] initWithFrame:frame] autorelease];
  XPParameterRaise(image);
  [view setImage:image];
  return view;
}

+(NSControl*)SVR_configureControl:(NSControl*)control
                      stringValue:(NSString*)stringValue
                             font:(NSFont*)font
                        alignment:(NSTextAlignment)alignment
                            image:(NSImage*)image;
{
  SEL setImageSEL = @selector(setImage:);
  XPParameterRaise(control);
  if (stringValue) {
    [control setStringValue:stringValue];
  }
  if (font) {
    [control setFont:font];
  }
  if (alignment >= 0) {
    [control setAlignment:alignment];
  }
  if (image && [control respondsToSelector:setImageSEL]) {
    [control performSelector:setImageSEL withObject:image];
  }
  [control sizeToFit];
  return control;
}

@end

@implementation NSView (SVRAccessoryWindows)
+(NSBox*)SVR_lineWithFrame:(NSRect)frame;
{
  NSBox *view = [[[NSBox alloc] initWithFrame:frame] autorelease];
  [view setBoxType:NSBoxSeparator];
  [view setBorderType:NSLineBorder];
  [view setBorderWidth:1.0];
  [view setTitlePosition:NSNoTitle];
  [view setHidden:NO];
  return view;
}
@end
