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
  XPFloat kWinPad  = SVRAccessoryWindowKeypadWindowPadding;
  XPFloat kBtnVPad = SVRAccessoryWindowKeypadWindowButtonVPadding;
  XPFloat kBtnHPad = SVRAccessoryWindowKeypadWindowButtonHPadding;
  XPFloat kGrpVPad = SVRAccessoryWindowKeypadWindowGroupSpacing;
  NSSize  kBtnSize = SVRAccessoryWindowKeypadWindowButtonSize;
  
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
    rowPadding += kGrpVPad;
  }
  if (row > 4) {
    rowPadding += kGrpVPad;
  }
  
  output.origin = NSMakePoint(((kBtnHPad + kBtnSize.width ) * column) + kWinPad,
                              ((kBtnVPad + kBtnSize.height) * row   ) + kWinPad + rowPadding);
  output.size = kind == SVRKeypadButtonKindEqual
                      ? NSMakeSize((kBtnSize.width * 2) + kBtnHPad, kBtnSize.height)
                      : kBtnSize;
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

-(id)initWithFrame:(NSRect)frameRect;
{
  SVRKeypadButtonKind kind = SVRKeypadButtonKindUnknown;
  NSButton *button = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _equalButton = nil;
  
  for (kind=SVRKeypadButtonKind1; kind<=SVRKeypadButtonKindLog; kind++) {
    button = [NSButton SVR_keypadButtonOfKind:kind];
    [self addSubview:button];
    if (kind == SVRKeypadButtonKindEqual) {
      _equalButton = button;
    }
  }
  
  XPParameterRaise(_equalButton);
  return self;
}

-(NSButton*)equalButton;
{
  return [[_equalButton retain] autorelease];
}

@end

// MARK: SVRAccessoryWindowAboutView

@implementation SVRAccessoryWindowAboutView

-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kLeftX = 8;
  XPFloat kLeftWidth = 312;
  XPFloat kRightX = 328;
  XPFloat kRightWidth = 144;
  XPFloat kAboveTextViewY = 168;
  NSPoint kTagLineOrigin = NSMakePoint(kLeftX-1, kLeftX);
  NSRect  kDedicationTextFrame = NSMakeRect(kLeftX, 30, kLeftWidth, 14);
  NSRect  kViewSourceButtonFrame = NSMakeRect(kRightX, kLeftX, kRightWidth, 42);
  NSRect  kSeparatorRect = NSMakeRect(kLeftX, 49, kLeftWidth, 1);
  NSRect  kTextViewRect = NSMakeRect(kLeftX, 58, 464, 100);
  NSRect  kSubtitleTextFrame = NSMakeRect(kLeftX-4, 184, kLeftWidth, 60);
  NSRect  kTitleTextFrame = NSMakeRect(kLeftX-4, 256, kLeftWidth, 44);
  NSRect  kPortraitImageView = NSMakeRect(kRightX, kAboveTextViewY, kRightWidth, kRightWidth);
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _textView = nil;
  _viewSourceButton = nil;
  
  // NeXT Tagline Image
  [self addSubview:[NSImageView SVR_imageViewWithOrigin:kTagLineOrigin
                                   sizedToFitImageNamed:@"TagLine"]];
  
  // Dedication Text
  [self addSubview:[[NSTextField SVR_labelWithFrame:kDedicationTextFrame]
                                 SVR_setObjectValue:@"This application is dedicated to my grandmother | 1932-2024"
                                               font:[NSFont systemFontOfSize:10]
                                          alignment:XPTextAlignmentLeft]];
  
  // View Source Button
  _viewSourceButton = [[[self class] __viewSourceButtonWithFrame:kViewSourceButtonFrame
                                                           title:@"View Source"
                                                      imageNamed:@"NeXTLogoMed"]
                                         SVR_setAutoresizingMask:NSViewMinXMargin];
  [self addSubview:_viewSourceButton];
  
  // Separator Line
  [self addSubview:[[NSBox SVR_lineWithFrame:kSeparatorRect]
                     SVR_setAutoresizingMask:NSViewWidthSizable]];
  
  // Large TextField
  [self addSubview:[[[self class] __scrollViewWithFrame:kTextViewRect
                                               textView:&_textView]
                                SVR_setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable]];
  
  // Add Subtitle Label
  [self addSubview:[[[NSTextField SVR_labelWithFrame:kSubtitleTextFrame]
                                  SVR_setObjectValue:@"for OpenStep\nby Jeffrey Bergier\n2025"
                                                font:[NSFont systemFontOfSize:16]
                                           alignment:XPTextAlignmentCenter]
                             SVR_setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable]];
  
  // Add Title Label
  [self addSubview:[[[NSTextField SVR_labelWithFrame:kTitleTextFrame]
                                  SVR_setObjectValue:@"[Not]Soulver"
                                                font:[NSFont boldSystemFontOfSize:36]
                                           alignment:XPTextAlignmentCenter]
                             SVR_setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable]];
  
  // Add Portrait Image View
  [self addSubview:[[[NSImageView SVR_imageViewWithFrame:kPortraitImageView
                                              imageNamed:@"about-image-512"]
                                  SVR_setImageFrameStyle:NSImageFrameGroove]
                                 SVR_setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin]];
  
  XPParameterRaise(_textView);
  XPParameterRaise(_viewSourceButton);

  return self;
}

-(NSTextView*)textView;
{
  return [[_textView retain] autorelease];
}

-(NSButton*)viewSourceButton;
{
  return [[_viewSourceButton retain] autorelease];
}

+(NSScrollView*)__scrollViewWithFrame:(NSRect)frame textView:(NSTextView**)inoutTextView;
{
  NSTextView *textView = nil;
  NSScrollView *scrollView = nil;
  NSTextContainer *container = nil;

  // Create the scroll view
  scrollView = [[[NSScrollView alloc] initWithFrame:frame] autorelease];
  [scrollView setBorderType:NSGrooveBorder];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:NO];

  // Create the text view
  textView = [[[NSTextView alloc] initWithFrame:frame] autorelease];
  [textView setEditable:NO];
  [textView setSelectable:YES];
  [textView setDrawsBackground:NO];
  [textView setFont:[NSFont systemFontOfSize:12]];
  [textView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];

  // Make the text view vertically resizable only
  [textView setHorizontallyResizable:NO];
  [textView setVerticallyResizable:YES];

  // Set the container size and width tracking
  container = [textView textContainer];
  [container setContainerSize:NSMakeSize(frame.size.width, FLT_MAX)];
  [container setWidthTracksTextView:YES];

  // Put the text view inside the scroll view
  [scrollView setDocumentView:textView];

  *inoutTextView = textView;
  return scrollView;
}

+(NSButton*)__viewSourceButtonWithFrame:(NSRect)frame
                                  title:(NSString*)title
                             imageNamed:(NSString*)imageName;
{
  NSButton *button = [[[NSButton alloc] initWithFrame:frame] autorelease];
  NSImage  *image  = [NSImage imageNamed:imageName];
  XPParameterRaise(button);
  XPParameterRaise(image);
  [button setTitle:title];
  [button setImage:image];
  [button setImagePosition:NSImageLeft];
  [button XP_setBezelStyle:XPBezelStyleShadowlessSquare];
  return button;
}

@end

// MARK: SVRAccessoryWindowSettingsView

@implementation SVRAccessoryWindowsSettingsGeneralBox
-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kResetWidth = 52;
  XPFloat kLabelWidth = 116;
  XPFloat kPopupWidth = 162;
  XPFloat kXOriginLHS = 8;
  XPFloat kXOriginRHS = 126;
  XPFloat kYOriginOne = 248;
  XPFloat kYOriginTwo = 222;
  XPFloat kHeight = 22;
  XPFloat HACK = 2;
  NSRect labelRect = NSMakeRect(kXOriginLHS,      kYOriginOne+HACK, kLabelWidth, kHeight);
  NSRect popupRect = NSMakeRect(kXOriginRHS,      kYOriginOne,      kPopupWidth, kHeight);
  NSRect fieldRect = NSMakeRect(kXOriginRHS+HACK, kYOriginTwo,      kPopupWidth-kResetWidth-HACK-2, kHeight);
  NSRect resetRect = NSMakeRect(kXOriginRHS+kPopupWidth-kResetWidth, kYOriginTwo, kResetWidth-HACK, kHeight);
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  
  [self setTitle:@"General"];
  [self setTitlePosition:NSNoTitle];
  
  _selectorButton = [[[NSPopUpButton alloc] initWithFrame:popupRect pullsDown:NO] autorelease];
  [_selectorButton addItemWithTitle:@"Automatic"];
  [_selectorButton addItemWithTitle:@"Light"];
  [_selectorButton addItemWithTitle:@"Dark"];
  [_selectorButton SVR_sizeToFitVertically];
  [_selectorButton setAction:NSSelectorFromString(@"writeTheme:")];
  [self addSubview:_selectorButton];
  
  _fieldTime = [[[NSTextField alloc] initWithFrame:fieldRect] autorelease];
  [_fieldTime setTarget:self];
  [_fieldTime setAction:@selector(__HACK_writeWaitTime:)];
  [[_fieldTime cell] setSendsActionOnEndEditing:YES];
  [self addSubview:_fieldTime];
  [self addSubview:[NSButton SVR_resetButtonWithFrame:resetRect
                                                 kind:SVRResetButtonKindWaitTime]];
  
  [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                  SVR_setObjectValue:@"Theme"
                                                font:nil
                                           alignment:XPTextAlignmentRight]
                             SVR_sizeToFitVertically]];
  labelRect.origin.y = resetRect.origin.y + HACK;
  [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                  SVR_setObjectValue:@"Solving Delay"
                                                font:nil
                                           alignment:XPTextAlignmentRight]
                             SVR_sizeToFitVertically]];
  
  XPParameterRaise(_selectorButton);
  XPParameterRaise(_fieldTime);
  
  return self;
}

-(NSPopUpButton*)themeSelector;
{
  return [[_selectorButton retain] autorelease];
}

-(NSTextField*)timeField;
{
  return [[_fieldTime retain] autorelease];
}

-(IBAction)__HACK_writeWaitTime:(NSTextField*)sender;
{
  // TODO: Remove this hack
  // For some reason NSTextField does not send its action
  // into the responder chain. It will only send it if its
  // target is set. So I set it to self and fire it
  // manually into the responder chain.
  // Also, for some reason, even though the user is typing
  // in the text field, its not the first responder.
  // So first I make it the first responder so the
  // responder chain works properly.
  [sender becomeFirstResponder];
  [[NSApplication sharedApplication] sendAction:NSSelectorFromString(@"writeWaitTime:")
                                             to:nil
                                           from:sender];
}

@end

@implementation SVRAccessoryWindowsSettingsColorsBox

-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kVPad = 32;
  XPFloat kYOrigin = 226;
  NSRect labelRect = NSMakeRect(8,   kYOrigin+4, 120, 0);
  NSRect lightRect = NSMakeRect(132, kYOrigin,   50, 30);
  NSRect darkkRect = NSMakeRect(184, kYOrigin,   50, 30);
  NSRect resetRect = NSMakeRect(236, kYOrigin,   48, 30);
  SVRColorWellKind colorKind = SVRColorWellKindUnknown;
  SVRResetButtonKind resetKind = SVRResetButtonKindUnknown;
  NSColorWell *colorWell = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _colorWells = [NSMutableDictionary new];
  
  [self setTitle:@"Colors"];
  [self setTitlePosition:NSNoTitle];
  
  for (colorKind =SVRColorWellKindOperandLight;
       colorKind<=SVRColorWellKindBackgroundDark;
       colorKind++)
  {
    resetKind = SVR_resetButtonKindForColorWellKind(colorKind);
    if (colorKind % 2) {
      [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                      SVR_setObjectValue:SVR_stringForLabelForKind(resetKind)
                                                    font:nil
                                               alignment:XPTextAlignmentRight]
                                 SVR_sizeToFitVertically]];
      colorWell = [NSColorWell SVR_colorWellWithFrame:lightRect kind:colorKind];
      [self addSubview:colorWell];
      labelRect.origin.y -= kVPad;
      lightRect.origin.y -= kVPad;
    } else {
      [self addSubview:[NSButton SVR_resetButtonWithFrame:resetRect kind:resetKind]];
      colorWell = [NSColorWell SVR_colorWellWithFrame:darkkRect kind:colorKind];
      [self addSubview:colorWell];
      darkkRect.origin.y -= kVPad;
      resetRect.origin.y -= kVPad;
    }
    XPParameterRaise(colorWell);
    [self setColorWell:colorWell forKind:colorKind];
  }
  
  lightRect.origin.y = kYOrigin + kVPad;
  darkkRect.origin.y = kYOrigin + kVPad;
  
  [self addSubview:[[[NSTextField SVR_labelWithFrame:lightRect]
                                  SVR_setObjectValue:@"Light"
                                                font:[NSFont systemFontOfSize:10]
                                           alignment:XPTextAlignmentCenter]
                             SVR_sizeToFitVertically]];
  [self addSubview:[[[NSTextField SVR_labelWithFrame:darkkRect]
                                  SVR_setObjectValue:@"Dark"
                                                font:[NSFont systemFontOfSize:10]
                                           alignment:XPTextAlignmentCenter]
                             SVR_sizeToFitVertically]];
  
  return self;
}

-(NSColorWell*)colorWellOfKind:(SVRColorWellKind)kind;
{
  NSColorWell *colorWell = [_colorWells objectForKey:[NSNumber XP_numberWithInteger:kind]];
  XPParameterRaise(colorWell);
  return colorWell;
}
-(void)setColorWell:(NSColorWell*)colorWell
            forKind:(SVRColorWellKind)kind;
{
  XPParameterRaise(colorWell);
  [_colorWells setObject:colorWell forKey:[NSNumber XP_numberWithInteger:kind]];
}

-(void)dealloc;
{
  [_colorWells release];
  _colorWells = nil;
  [super dealloc];
}

@end

@implementation SVRAccessoryWindowsSettingsFontsBox
-(id)initWithFrame:(NSRect)frameRect;
{
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  [self setTitle:@"Fonts"];
  return self;
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
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  return button;
}

+(NSTextField*)SVR_labelWithFrame:(NSRect)frame;
{
  NSTextField *label = [[[NSTextField alloc] initWithFrame:frame] autorelease];
  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setEditable:NO];
  [label setSelectable:NO];
  return label;
}

+(NSButton*)SVR_resetButtonWithFrame:(NSRect)frame
                                kind:(SVRResetButtonKind)kind;
{
  NSButton *button = [[[NSButton alloc] initWithFrame:frame] autorelease];
  XPParameterRaise(button);
  [button setTitle:@"Reset"];
  [button setTag:kind];
  [button setAction:NSSelectorFromString(@"reset:")];
  [button XP_setBezelStyle:XPBezelStyleShadowlessSquare];
  return button;
}

+(NSColorWell*)SVR_colorWellWithFrame:(NSRect)frame
                                 kind:(SVRColorWellKind)kind;
{
  NSColorWell *well = [[[NSColorWell alloc] initWithFrame:frame] autorelease];
  [well setTag:kind];
  [well setAction:NSSelectorFromString(@"writeColor:")];
  return well;
}

-(id)SVR_sizeToFitVertically;
{
  NSRect original = [self frame];
  NSRect new = NSZeroRect;
  [self sizeToFit];
  new = [self frame];
  new.size.width = original.size.width;
  [self setFrame:new];
  return self;
}

-(id)SVR_setObjectValue:(id)objectValue
                   font:(NSFont*)font
              alignment:(NSTextAlignment)alignment;
{
  if (objectValue) {
    [self setObjectValue:objectValue];
  }
  if (font) {
    [self setFont:font];
  }
  [self setAlignment:alignment];
  return self;
}

@end

@implementation NSView (SVRAccessoryWindows)

+(NSBox*)SVR_lineWithFrame:(NSRect)frame;
{
  NSBox *view = [[[NSBox alloc] initWithFrame:frame] autorelease];
  [view XP_setBoxType:XPBoxSeparator];
  [view setTitlePosition:NSNoTitle];
  return view;
}

-(id)SVR_setAutoresizingMask:(XPUInteger)mask;
{
  [self setAutoresizingMask:mask];
  return self;
}

@end

@implementation NSImageView (SVRAccessoryWindows)

+(NSImageView*)SVR_imageViewWithOrigin:(NSPoint)origin
                  sizedToFitImageNamed:(NSString*)imageName;
{
  NSImage     *image = [NSImage imageNamed:imageName];
  NSRect       frame = NSMakeRect(origin.x, origin.y, [image size].width, [image size].height);
  NSImageView *view  = [[[NSImageView alloc] initWithFrame:frame] autorelease];
  XPParameterRaise(image);
  [view setImage:image];
  return view;
}

+(NSImageView*)SVR_imageViewWithFrame:(NSRect)frame
                           imageNamed:(NSString*)imageName;
{
  NSImage     *image = [NSImage imageNamed:imageName];
  NSImageView *view  = [[[NSImageView alloc] initWithFrame:frame] autorelease];
  XPParameterRaise(image);
  [view setImage:image];
  return view;
}

-(NSImageView*)SVR_setImageFrameStyle:(NSImageFrameStyle)imageFrameStyle;
{
  [self setImageFrameStyle:imageFrameStyle];
  return self;
}

@end

NSString *SVR_stringForLabelForKind(SVRResetButtonKind kind)
{
  switch (kind) {
    case SVRResetButtonKindWaitTime:
      return @"Solving Delay";
    case SVRResetButtonKindMathFont:
      return @"Math Text";
    case SVRResetButtonKindOtherFont:
      return @"Normal Text";
    case SVRResetButtonKindErrorFont:
      return @"Error Text";
    case SVRResetButtonKindOperandColor:
      return @"Operand";
    case SVRResetButtonKindOperatorColor:
      return @"Operator";
    case SVRResetButtonKindSolutionColor:
      return @"Solution";
    case SVRResetButtonKindPreviousSolutionColor:
      return @"Carryover";
    case SVRResetButtonKindOtherTextColor:
      return @"Normal Text";
    case SVRResetButtonKindErrorTextColor:
      return @"Error Text";
    case SVRResetButtonKindInsertionPointColor:
      return @"Insertion Point";
    case SVRResetButtonKindBackgroundColor:
      return @"Background";
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRResetButtonKind(%d)", (int)kind);
      return @"Unknown";
  }
}

SVRResetButtonKind SVR_resetButtonKindForColorWellKind(SVRColorWellKind kind)
{
  switch (kind) {
    case SVRColorWellKindOperandLight:
    case SVRColorWellKindOperandDark:
      return SVRResetButtonKindOperandColor;
    case SVRColorWellKindOperatorLight:
    case SVRColorWellKindOperatorDark:
      return SVRResetButtonKindOperatorColor;
    case SVRColorWellKindSolutionLight:
    case SVRColorWellKindSolutionDark:
      return SVRResetButtonKindSolutionColor;
    case SVRColorWellKindSolutionSecondaryLight:
    case SVRColorWellKindSolutionSecondaryDark:
      return SVRResetButtonKindPreviousSolutionColor;
    case SVRColorWellKindOtherTextLight:
    case SVRColorWellKindOtherTextDark:
      return SVRResetButtonKindOtherTextColor;
    case SVRColorWellKindErrorTextLight:
    case SVRColorWellKindErrorTextDark:
      return SVRResetButtonKindErrorTextColor;
    case SVRColorWellKindInsertionPointLight:
    case SVRColorWellKindInsertionPointDark:
      return SVRResetButtonKindInsertionPointColor;
    case SVRColorWellKindBackgroundLight:
    case SVRColorWellKindBackgroundDark:
      return SVRResetButtonKindBackgroundColor;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRColorWellKind(%d)", (int)kind);
      return SVRResetButtonKindUnknown;
  }
}
