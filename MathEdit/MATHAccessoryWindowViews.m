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

#import "MATHAccessoryWindowViews.h"

// MARK: MATHAccessoryWindowKeypadView

@implementation MATHAccessoryWindowKeypadView: NSView

-(id)initWithFrame:(NSRect)frameRect;
{
  MATHKeypadButtonKind kind = MATHKeypadButtonKindUnknown;
  NSButton *button = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _equalButton = nil;
  
  for (kind=MATHKeypadButtonKind1; kind<=MATHKeypadButtonKindLog; kind++) {
    button = [NSButton MATH_keypadButtonOfKind:kind];
    [self addSubview:button];
    if (kind == MATHKeypadButtonKindEqual) {
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

// MARK: MATHAccessoryWindowAboutView

@implementation MATHAccessoryWindowAboutView

-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kLeftX = 8;
  XPFloat kLeftWidth = 314;
  XPFloat kRightX = 328;
  XPFloat kRightWidth = 144;
  NSPoint kTagLineOrigin = NSMakePoint(kLeftX-1, kLeftX);
  NSRect  kDedicationTextFrame = NSMakeRect(kLeftX, 30, kLeftWidth, 14);
  NSRect  kViewSourceButtonFrame = NSMakeRect(kRightX, kLeftX, kRightWidth, 44);
  NSRect  kSeparatorRect = NSMakeRect(kLeftX, 49, kLeftWidth, 1);
  NSRect  kTextViewRect = NSMakeRect(kLeftX, 58, 464, 100);
  NSRect  kSubtitleTextFrame = NSMakeRect(kLeftX-4, 184, kLeftWidth, 60);
  NSRect  kTitleTextFrame = NSMakeRect(kLeftX-4, 256, kLeftWidth, 44);
  NSRect  kPortraitImageView = NSMakeRect(kRightX, 166, kRightWidth, kRightWidth);
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _textView = nil;
  _viewSourceButton = nil;
  
  // NeXT Tagline Image
  [self addSubview:[NSImageView MATH_imageViewWithOrigin:kTagLineOrigin
                                    sizedToFitImageNamed:[Localized imageNeXTTagline]]];
  
  // Dedication Text
  [self addSubview:[[NSTextField MATH_labelWithFrame:kDedicationTextFrame]
                                 MATH_setObjectValue:[Localized phraseAboutDedication]
                                                font:[NSFont systemFontOfSize:10]
                                           alignment:XPTextAlignmentLeft]];
  
  // View Source Button
  _viewSourceButton = [[[self class] __viewSourceButtonWithFrame:MATH_rectByAdjustingAquaButtonRect(kViewSourceButtonFrame)
                                                           title:[Localized verbViewSource]
                                                      imageNamed:[Localized imageNeXTLogo]]
                                        MATH_setAutoresizingMask:NSViewMinXMargin];
  [self addSubview:_viewSourceButton];
  
  // Separator Line
  [self addSubview:[[NSBox MATH_lineWithFrame:kSeparatorRect]
                     MATH_setAutoresizingMask:NSViewWidthSizable]];
  
  // Large TextField
  [self addSubview:[[[self class] __scrollViewWithFrame:kTextViewRect
                                               textView:&_textView]
                               MATH_setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable]];
  
  // Add Subtitle Label
  [self addSubview:[[[NSTextField MATH_labelWithFrame:kSubtitleTextFrame]
                                  MATH_setObjectValue:[Localized phraseAboutTagline]
                                                 font:[NSFont systemFontOfSize:16]
                                            alignment:XPTextAlignmentCenter]
                             MATH_setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable]];
  
  // Add Title Label
  [self addSubview:[[[NSTextField MATH_labelWithFrame:kTitleTextFrame]
                                  MATH_setObjectValue:[Localized titleAppName]
                                                 font:[NSFont boldSystemFontOfSize:36]
                                            alignment:XPTextAlignmentCenter]
                             MATH_setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable]];
  
  // Add Portrait Image View
  [self addSubview:[[[NSImageView MATH_imageViewWithFrame:kPortraitImageView
                                               imageNamed:[Localized imageAboutPortrait]]
                                  MATH_setImageFrameStyle:NSImageFrameGroove]
                                 MATH_setAutoresizingMask:NSViewMinYMargin | NSViewMinXMargin]];
  
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
  NSSize contentSize = NSZeroSize;
  NSRect contentBounds = NSZeroRect;
  NSTextView *textView = nil;
  NSScrollView *scrollView = nil;
  
  XPLogAssrt(inoutTextView != NULL, @"inout parameter 'textView' was NULL");

  /// This way of constructing the TextView is directly from Apple
  /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html#//apple_ref/doc/uid/20000938-CJBBIAAF
  
  // ScrollView configuration
  scrollView = [[[NSScrollView alloc] initWithFrame:frame ] autorelease];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView XP_setDrawsBackground:NO];

  // TextView configuration
  contentSize = [scrollView contentSize];
  contentBounds = NSMakeRect(0,0, contentSize.width, contentSize.height);
  textView = [[[NSTextView alloc] initWithFrame:contentBounds] autorelease];
  [textView setMinSize:NSMakeSize(0.0, contentSize.height)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:NO];
  [textView setAutoresizingMask:NSViewWidthSizable];
  [[textView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
  [[textView textContainer] setWidthTracksTextView:YES];
  
  // Embed the text view
  [scrollView setDocumentView:textView];
  /// END Apple Instructions
  
  // Customize for this app
  [scrollView setBorderType:NSBezelBorder];
  [textView setEditable:NO];
  [textView setSelectable:YES];
  [textView setDrawsBackground:NO];
  [textView setFont:[NSFont systemFontOfSize:12]];
  
  XPParameterRaise(textView);
  XPParameterRaise(scrollView);
  
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
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  return button;
}

@end

// MARK: MATHAccessoryWindowSettingsView

@implementation MATHAccessoryWindowsSettingsGeneralView

-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kTopY = frameRect.size.height-92;
  XPFloat kBotY = frameRect.size.height-160;
  XPFloat kSgmntH  = 72;
  XPFloat kSlidrH  = 30;
  NSRect delayRect = NSMakeRect(frameRect.size.width-50, kBotY,           50,                   kSlidrH);
  NSRect slidrRect = NSMakeRect(frameRect.origin.x,      kBotY,           delayRect.origin.x-4, kSlidrH);
  NSRect sgmntRect = NSMakeRect(frameRect.origin.x,      kTopY,           frameRect.size.width, kSgmntH);
  NSRect labelRect = NSMakeRect(frameRect.origin.x,      kTopY+kSgmntH+4, frameRect.size.width,  0);
  MATHResetButtonKind kind = MATHResetButtonKindUnknown;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  
  // User Interface Style Selector
  kind = MATHResetButtonKindUIStyle;
  [self addSubview:[[[NSTextField MATH_labelWithFrame:labelRect]
                                  MATH_setObjectValue:MATH_localizedStringForKind(kind)
                                                 font:nil
                                            alignment:XPTextAlignmentLeft]
                             MATH_sizeToFitVertically]];
  
  _selectorControl = [[[XPSegmentedControl alloc] initWithFrame:sgmntRect] autorelease];
  [_selectorControl setSegmentCount:3];
  [_selectorControl setLabel:[Localized titleAutomatic] forSegment:0];
  [_selectorControl setLabel:[Localized titleLight    ] forSegment:1];
  [_selectorControl setLabel:[Localized titleDark     ] forSegment:2];
  [_selectorControl setImage:[[NSImage imageNamed:[Localized imageThemeAuto ]] MATH_setTemplate:YES] forSegment:0];
  [_selectorControl setImage:[[NSImage imageNamed:[Localized imageThemeLight]] MATH_setTemplate:YES] forSegment:1];
  [_selectorControl setImage:[[NSImage imageNamed:[Localized imageThemeDark ]] MATH_setTemplate:YES] forSegment:2];
  [_selectorControl setAction:@selector(writeUserInterfaceStyle:)];
  [self addSubview:_selectorControl];
  
  // Adjust frames
  kind = MATHResetButtonKindWaitTime;
  labelRect.origin.y = slidrRect.origin.y+kSlidrH+4;
  
  // Wait Time Slider
  [self addSubview:[[[NSTextField MATH_labelWithFrame:labelRect]
                                  MATH_setObjectValue:MATH_localizedStringForKind(kind)
                                                 font:nil
                                            alignment:XPTextAlignmentLeft]
                             MATH_sizeToFitVertically]];
  
  _delayLabel = [NSTextField MATH_textFieldWithFrame:delayRect
                                              target:nil
                                              action:NULL];
  [_delayLabel setAlignment:XPTextAlignmentCenter];
  [self addSubview:_delayLabel];
  
  _delaySlider = [[[NSSlider alloc] initWithFrame:slidrRect] autorelease];
  [_delaySlider setMinValue:0];
  [_delaySlider setMaxValue:10];
  [_delaySlider setAction:@selector(writeWaitTime:)];
  [self addSubview:_delaySlider];
  
  XPParameterRaise(_selectorControl);
  XPParameterRaise(_delayLabel);
  XPParameterRaise(_delaySlider);
  
  return self;
}

-(XPSegmentedControl*)themeSelector;
{
  XPParameterRaise(_selectorControl);
  return [[_selectorControl retain] autorelease];
}

-(NSTextField*)delayLabel;
{
  XPParameterRaise(_delayLabel);
  return [[_delayLabel retain] autorelease];
}

-(NSSlider*)delaySlider;
{
  XPParameterRaise(_delaySlider);
  return [[_delaySlider retain] autorelease];
}

@end

@implementation MATHAccessoryWindowsSettingsColorsView

-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kVPad = 32;
  XPFloat kYOrigin = frameRect.size.height-48;
  XPFloat buttonWidth = 52;
  NSRect resetRect = NSMakeRect(frameRect.size.width-buttonWidth, kYOrigin,   buttonWidth,          30);
  NSRect darkkRect = NSMakeRect(resetRect.origin.x-buttonWidth-4, kYOrigin,   buttonWidth,          30);
  NSRect lightRect = NSMakeRect(darkkRect.origin.x-buttonWidth-4, kYOrigin,   buttonWidth,          30);
  NSRect labelRect = NSMakeRect(frameRect.origin.x,               kYOrigin+4, lightRect.origin.x-4,  0);
  MATHColorWellKind colorKind = MATHColorWellKindUnknown;
  MATHResetButtonKind resetKind = MATHResetButtonKindUnknown;
  NSColorWell *colorWell = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _colorWells = [NSMutableDictionary new];
  
  for (colorKind =MATHColorWellKindOperandLight;
       colorKind<=MATHColorWellKindBackgroundDark;
       colorKind++)
  {
    resetKind = MATH_resetButtonKindForColorWellKind(colorKind);
    if (colorKind % 2) {
      [self addSubview:[[[NSTextField MATH_labelWithFrame:labelRect]
                                      MATH_setObjectValue:MATH_localizedStringForKind(resetKind)
                                                     font:nil
                                                alignment:XPTextAlignmentRight]
                                 MATH_sizeToFitVertically]];
      colorWell = [NSColorWell MATH_colorWellWithFrame:lightRect kind:colorKind];
      [self addSubview:colorWell];
      labelRect.origin.y -= kVPad;
      lightRect.origin.y -= kVPad;
    } else {
      [self addSubview:[NSButton MATH_settingsButtonWithFrame:MATH_rectByAdjustingAquaButtonRect(resetRect)
                                                        title:[Localized verbReset]
                                                       action:@selector(reset:)
                                                          tag:resetKind]];
      colorWell = [NSColorWell MATH_colorWellWithFrame:darkkRect kind:colorKind];
      [self addSubview:colorWell];
      darkkRect.origin.y -= kVPad;
      resetRect.origin.y -= kVPad;
    }
    XPParameterRaise(colorWell);
    [self setColorWell:colorWell forKind:colorKind];
  }
  
  lightRect.origin.y = kYOrigin + kVPad;
  darkkRect.origin.y = kYOrigin + kVPad;
  
  [self addSubview:[[[NSTextField MATH_labelWithFrame:lightRect]
                                  MATH_setObjectValue:[Localized titleLight]
                                                 font:[NSFont systemFontOfSize:10]
                                            alignment:XPTextAlignmentCenter]
                             MATH_sizeToFitVertically]];
  [self addSubview:[[[NSTextField MATH_labelWithFrame:darkkRect]
                                  MATH_setObjectValue:[Localized titleDark]
                                                 font:[NSFont systemFontOfSize:10]
                                            alignment:XPTextAlignmentCenter]
                             MATH_sizeToFitVertically]];
  
  return self;
}

-(NSColorWell*)colorWellOfKind:(MATHColorWellKind)kind;
{
  NSColorWell *colorWell = [_colorWells objectForKey:[NSNumber XP_numberWithInteger:kind]];
  XPParameterRaise(colorWell);
  return colorWell;
}
-(void)setColorWell:(NSColorWell*)colorWell
            forKind:(MATHColorWellKind)kind;
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

@implementation MATHAccessoryWindowsSettingsFontsView
-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kLabelYOffset = 32;
  XPFloat kYOrigin = frameRect.size.height-kLabelYOffset-16;
  XPFloat kVPad = kLabelYOffset + 22;
  XPFloat buttonWidth = 52;
  NSRect resetRect = NSMakeRect(frameRect.size.width-buttonWidth, kYOrigin,               buttonWidth,          30);
  NSRect setttRect = NSMakeRect(resetRect.origin.x-buttonWidth-4, kYOrigin,               buttonWidth,          30);
  NSRect fieldRect = NSMakeRect(frameRect.origin.x,               kYOrigin,               setttRect.origin.x-4, 30);
  NSRect labelRect = NSMakeRect(frameRect.origin.x,               kYOrigin+kLabelYOffset, setttRect.origin.x-4,  0);
  MATHThemeFont fontKind = MATHThemeFontUnknown;
  MATHResetButtonKind resetKind = MATHResetButtonKindUnknown;
  NSTextField *textField = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _textFields = [NSMutableDictionary new];
  
  for (fontKind =MATHThemeFontMath;
       fontKind<=MATHThemeFontError;
       fontKind++)
  {
    resetKind = MATH_resetButtonKindForFontSettingKind(fontKind);
    
    // Label
    [self addSubview:[[[NSTextField MATH_labelWithFrame:labelRect]
                                    MATH_setObjectValue:MATH_localizedStringForKind(resetKind)
                                                   font:nil
                                              alignment:XPTextAlignmentLeft]
                               MATH_sizeToFitVertically]];
    
    // TextField
    textField = [NSTextField MATH_textFieldWithFrame:fieldRect
                                              target:nil
                                              action:NULL];
    [self setTextField:textField forKind:fontKind];
    [self addSubview:textField];
    
    // Buttons
    [self addSubview:[NSButton MATH_settingsButtonWithFrame:MATH_rectByAdjustingAquaButtonRect(setttRect)
                                                      title:[Localized verbSet]
                                                     action:@selector(presentFontPanel:)
                                                        tag:fontKind]];
    [self addSubview:[NSButton MATH_settingsButtonWithFrame:MATH_rectByAdjustingAquaButtonRect(resetRect)
                                                      title:[Localized verbReset]
                                                     action:@selector(reset:)
                                                        tag:resetKind]];
    
    // Adjust frames
    labelRect.origin.y -= kVPad;
    fieldRect.origin.y -= kVPad;
    setttRect.origin.y -= kVPad;
    resetRect.origin.y -= kVPad;
  }
  
  return self;
}

-(NSTextField*)textFieldOfKind:(MATHThemeFont)kind;
{
  NSTextField *textField = [_textFields objectForKey:[NSNumber XP_numberWithInteger:kind]];
  XPParameterRaise(textField);
  return textField;
}

-(void)setTextField:(NSTextField*)textField
            forKind:(MATHThemeFont)kind;
{
  XPParameterRaise(textField);
  [_textFields setObject:textField forKey:[NSNumber XP_numberWithInteger:kind]];
}

-(void)dealloc;
{
  [_textFields release];
  _textFields = nil;
  [super dealloc];
}

@end

@implementation XPSegmentedControl

+(Class)cellClass;
{
	return [NSActionCell class];
}

-(id)initWithFrame:(NSRect)frameRect;
{
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _buttons = [NSMutableArray new];
  _selectedSegment = 0;
  return self;
}

-(void)setSegmentCount:(XPInteger)_;
{
}

-(XPInteger)selectedSegment;
{
  return (XPInteger)_selectedSegment;
}

-(void)setSelectedSegment:(XPInteger)_selection;
{
  XPUInteger selection = (XPUInteger)_selection;
  XPUInteger count = [_buttons count];
  XPUInteger index = 0;
  XPLogAssrt1(count > selection, @"[BOUNDS] Selection(%d)", (int)selection);
  for (index=0; index<count; index++) {
    [[_buttons objectAtIndex:index] setState:index==selection];
  }
  _selectedSegment = selection;
}

-(NSString*)labelForSegment:(XPInteger)segment;
{
  return [[_buttons objectAtIndex:(XPUInteger)segment] title];
}

-(void)setLabel:(NSString*)label forSegment:(XPInteger)segment;
{
  XPInteger count = (XPInteger)[_buttons count];
  NSButton *button = nil;
  if (segment < count) {
    [[_buttons objectAtIndex:(XPUInteger)segment] setTitle:label];
  } else {
    button = [self __insertButtonAtIndex:segment];
    [button setTitle:label];
  }
}

-(NSImage*)imageForSegment:(XPInteger)segment;
{
  return [[_buttons objectAtIndex:(XPUInteger)segment] image];
}

-(void)setImage:(NSImage*)image forSegment:(XPInteger)segment;
{
  XPInteger count = (XPInteger)[_buttons count];
  NSButton *button = nil;
  if (segment < count) {
    [[_buttons objectAtIndex:(XPUInteger)segment] setImage:image];
  } else {
    button = [self __insertButtonAtIndex:segment];
    [button setImage:image];
  }
}

-(IBAction)__selectedSegmentChanged:(NSButton*)sender;
{
  XPInteger index = (XPInteger)[_buttons indexOfObject:sender];
  XPLogAssrt1(index != (XPUInteger)NSNotFound, @"[UNKNOWN] Sender(%@)", sender);
	XPLogAssrt([self action], @"Selector was NULL");
  [self setSelectedSegment:index];
  [self sendAction:[self action] to:[self target]];
}

-(NSButton*)__insertButtonAtIndex:(XPInteger)index;
{
  NSButton *button = [[NSButton alloc] initWithFrame:NSZeroRect];
  [_buttons insertObject:button atIndex:(XPUInteger)index];
  
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  [button setButtonType:XPButtonTypePushOnPushOff];
  [button setImagePosition:NSImageAbove];
  [button setAction:@selector(__selectedSegmentChanged:)];
  [button setTarget:self];
  
  [self __recalculateFrames];
  [self setSelectedSegment:(XPInteger)_selectedSegment];
  [self addSubview:button];
  return button;
}

-(void)__recalculateFrames;
{
  const XPFloat kPad = 4;
  XPUInteger index = 0;
  NSRect myBounds = [self bounds];
  NSRect buttonFrame = myBounds;
  XPUInteger count = [_buttons count];
  
  buttonFrame.size.width = floor(myBounds.size.width/count) - (kPad/2);
  for (index=0; index<count; index++) {
    buttonFrame.origin.x = (buttonFrame.size.width*index) + (kPad*index);
    [[_buttons objectAtIndex:index] setFrame:MATH_rectByAdjustingAquaButtonRect(buttonFrame)];
  }
}

-(void)dealloc;
{
  [_buttons release];
  _buttons = nil;
  [super dealloc];
}

@end

@implementation NSControl (MATHAccessoryWindows)

+(NSButton*)MATH_keypadButtonOfKind:(MATHKeypadButtonKind)kind;
{
  NSButton *button = [[[NSButton alloc] initWithFrame:MATH_rectForKeypadButtonOfKind(kind)] autorelease];
  [button setTitle:MATH_titleForKeypadButtonOfKind(kind)];
  [button setKeyEquivalent:MATH_keyForKeypadButtonOfKind(kind)];
  [button setTag:kind];
  [button setAction:@selector(keypadAppend:)];
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  return button;
}

+(NSButton*)MATH_settingsButtonWithFrame:(NSRect)frame
                                   title:(NSString*)title
                                  action:(SEL)action
                                     tag:(XPInteger)tag;
{
  NSButton *button = [[[NSButton alloc] initWithFrame:frame] autorelease];
  [button setTitle:title];
  [button setAction:action];
  [button setTag:tag];
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  return button;
}

+(NSColorWell*)MATH_colorWellWithFrame:(NSRect)frame
                                  kind:(MATHColorWellKind)kind;
{
  NSColorWell *well = [[[NSColorWell alloc] initWithFrame:frame] autorelease];
  [well setTag:kind];
  [well setAction:@selector(writeColor:)];
  return well;
}

+(NSTextField*)MATH_labelWithFrame:(NSRect)frame;
{
  NSTextField *label = [[[NSTextField alloc] initWithFrame:frame] autorelease];
  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setEditable:NO];
  [label setSelectable:NO];
  return label;
}

+(NSTextField*)MATH_textFieldWithFrame:(NSRect)frame
                                target:(id)target
                                action:(SEL)action;
{
  NSTextField *textField = [[[NSTextField alloc] initWithFrame:frame] autorelease];
  BOOL isEditable = target != nil || action != NULL;
  
  [textField setEditable:isEditable];
  if (isEditable) {
    [textField setTarget:target];
    [textField setAction:action];
  }
  
#ifdef XPSupportsAttractiveRoundTextFields
  [textField XP_setBezelStyle:XPTextFieldRoundedBezel];
#endif
  
  return textField;
}

-(id)MATH_sizeToFitVertically;
{
  NSRect original = [self frame];
  NSRect new = NSZeroRect;
  [self sizeToFit];
  new = [self frame];
  new.size.width = original.size.width;
  [self setFrame:new];
  return self;
}

-(id)MATH_setObjectValue:(id)objectValue
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

@implementation NSView (MATHAccessoryWindows)

+(NSBox*)MATH_lineWithFrame:(NSRect)frame;
{
  NSBox *view = [[[NSBox alloc] initWithFrame:frame] autorelease];
  [view XP_setBoxType:XPBoxSeparator];
  [view setTitlePosition:NSNoTitle];
  return view;
}

-(id)MATH_setAutoresizingMask:(XPUInteger)mask;
{
  [self setAutoresizingMask:mask];
  return self;
}

@end

@implementation NSImageView (MATHAccessoryWindows)

+(NSImageView*)MATH_imageViewWithOrigin:(NSPoint)origin
                   sizedToFitImageNamed:(NSString*)imageName;
{
  NSImage     *image = [NSImage imageNamed:imageName];
  NSRect       frame = NSMakeRect(origin.x, origin.y, [image size].width, [image size].height);
  NSImageView *view  = [[[NSImageView alloc] initWithFrame:frame] autorelease];
  XPParameterRaise(image);
  [view setImage:image];
  return view;
}

+(NSImageView*)MATH_imageViewWithFrame:(NSRect)frame
                            imageNamed:(NSString*)imageName;
{
  NSImage     *image = [NSImage imageNamed:imageName];
  NSImageView *view  = [[[NSImageView alloc] initWithFrame:frame] autorelease];
  XPParameterRaise(image);
  [view setImage:image];
  return view;
}

-(NSImageView*)MATH_setImageFrameStyle:(NSImageFrameStyle)imageFrameStyle;
{
  [self setImageFrameStyle:imageFrameStyle];
  return self;
}

@end

@implementation NSImage (MATHAccessoryWindows)
-(NSImage*)MATH_setTemplate:(BOOL)flag;
{
#ifndef AFF_NSImageTemplateNone
  [self setTemplate:flag];
#endif
  return self;
}
@end

NSRect MATH_rectForKeypadButtonOfKind(MATHKeypadButtonKind kind)
{
  XPFloat kWinPad  = MATHAccessoryWindowKeypadWindowPadding;
  XPFloat kBtnVPad = MATHAccessoryWindowKeypadWindowButtonVPadding;
  XPFloat kBtnHPad = MATHAccessoryWindowKeypadWindowButtonHPadding;
  XPFloat kGrpVPad = MATHAccessoryWindowKeypadWindowGroupSpacing;
  NSSize  kBtnSize = MATHAccessoryWindowKeypadWindowButtonSize;
  
  XPInteger column     = -1;
  XPInteger row        = -1;
  XPFloat   rowPadding = 0;
  NSRect    output     = NSZeroRect;
  
  switch (kind) {
    case MATHKeypadButtonKind1:
    case MATHKeypadButtonKindNegative:
    case MATHKeypadButtonKind4:
    case MATHKeypadButtonKind7:
    case MATHKeypadButtonKindAdd:
    case MATHKeypadButtonKindMultiply:
    case MATHKeypadButtonKindPower:
    case MATHKeypadButtonKindDelete:
      column = 0;
      break;
    case MATHKeypadButtonKindEqual:
    case MATHKeypadButtonKind0:
    case MATHKeypadButtonKind2:
    case MATHKeypadButtonKind5:
    case MATHKeypadButtonKind8:
    case MATHKeypadButtonKindSubtract:
    case MATHKeypadButtonKindDivide:
    case MATHKeypadButtonKindRoot:
      column = 1;
      break;
    case MATHKeypadButtonKindDecimal:
    case MATHKeypadButtonKind3:
    case MATHKeypadButtonKind6:
    case MATHKeypadButtonKind9:
    case MATHKeypadButtonKindBRight:
    case MATHKeypadButtonKindBLeft:
    case MATHKeypadButtonKindLog:
      column = 2;
      break;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHAccessoryWindowKeypadViewKind(%d)", (int)kind);
      break;
  }
  
  switch (kind) {
    case MATHKeypadButtonKindDelete:
    case MATHKeypadButtonKindEqual:
      row = 0;
      break;
    case MATHKeypadButtonKindNegative:
    case MATHKeypadButtonKind0:
    case MATHKeypadButtonKindDecimal:
      row = 1;
      break;
    case MATHKeypadButtonKind1:
    case MATHKeypadButtonKind2:
    case MATHKeypadButtonKind3:
      row = 2;
      break;
    case MATHKeypadButtonKind4:
    case MATHKeypadButtonKind5:
    case MATHKeypadButtonKind6:
      row = 3;
      break;
    case MATHKeypadButtonKind7:
    case MATHKeypadButtonKind8:
    case MATHKeypadButtonKind9:
      row = 4;
      break;
    case MATHKeypadButtonKindAdd:
    case MATHKeypadButtonKindSubtract:
    case MATHKeypadButtonKindBRight:
      row = 5;
      break;
    case MATHKeypadButtonKindMultiply:
    case MATHKeypadButtonKindDivide:
    case MATHKeypadButtonKindBLeft:
      row = 6;
      break;
    case MATHKeypadButtonKindPower:
    case MATHKeypadButtonKindRoot:
    case MATHKeypadButtonKindLog:
      row = 7;
      break;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHAccessoryWindowKeypadViewKind(%d)", (int)kind);
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
  output.size = kind == MATHKeypadButtonKindEqual
              ? NSMakeSize((kBtnSize.width * 2) + kBtnHPad, kBtnSize.height)
              : kBtnSize;
  return MATH_rectByAdjustingAquaButtonRect(output);
}

NSRect MATH_rectByAdjustingAquaButtonRect(NSRect rect)
{
#ifndef AFF_UIStyleAquaNone
  XPFloat xPad = 2;
  XPFloat yPad = 2;
  return NSMakeRect(rect.origin.x-xPad,
                    rect.origin.y-yPad,
                    rect.size.width+xPad*2,
                    rect.size.height+yPad*2);
#else
  return rect;
#endif
}

NSString *MATH_titleForKeypadButtonOfKind(MATHKeypadButtonKind kind)
{
  switch (kind) {
    case MATHKeypadButtonKind1:
    case MATHKeypadButtonKind2:
    case MATHKeypadButtonKind3:
    case MATHKeypadButtonKind4:
    case MATHKeypadButtonKind5:
    case MATHKeypadButtonKind6:
    case MATHKeypadButtonKind7:
    case MATHKeypadButtonKind8:
    case MATHKeypadButtonKind9:
      return [NSString stringWithFormat:@"%d", (int)kind];
    case MATHKeypadButtonKind0:
      return @"0";
    case MATHKeypadButtonKindNegative:
      return @"-";
    case MATHKeypadButtonKindDecimal:
      return @".";
    case MATHKeypadButtonKindDelete:
#ifdef AFF_UnicodeUINone
      return @"<-";
#else
      return [NSString stringWithFormat:@"%C", 0x2190];
#endif
    case MATHKeypadButtonKindEqual:
      return @"=";
    case MATHKeypadButtonKindAdd:
      return @"+";
    case MATHKeypadButtonKindSubtract:
      return @"-";
    case MATHKeypadButtonKindBRight:
      return @")";
    case MATHKeypadButtonKindMultiply:
      return @"*";
    case MATHKeypadButtonKindDivide:
      return @"/";
    case MATHKeypadButtonKindBLeft:
      return @"(";
    case MATHKeypadButtonKindPower:
      return @"^";
    case MATHKeypadButtonKindRoot:
#ifdef AFF_UnicodeUINone
      return @"root";
#else
      return [NSString stringWithFormat:@"%C", 0x221A];
#endif
    case MATHKeypadButtonKindLog:
      return @"log";
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHAccessoryWindowKeypadViewKind(%d)", (int)kind);
      return [NSString stringWithFormat:@"%d", (int)kind];
  }
}

NSString *MATH_keyForKeypadButtonOfKind(MATHKeypadButtonKind kind)
{
  switch (kind) {
    case MATHKeypadButtonKindDelete:
      return @"\b";
    case MATHKeypadButtonKindRoot:
      return @"r";
    case MATHKeypadButtonKindLog:
      return @"l";
    default:
      return MATH_titleForKeypadButtonOfKind(kind);
  }
}

NSString *MATH_localizedStringForKind(MATHResetButtonKind kind)
{
  switch (kind) {
    case MATHResetButtonKindUIStyle:
      return [Localized titleTheme];
    case MATHResetButtonKindWaitTime:
      return [Localized titleSolvingDelay];
    case MATHResetButtonKindMathFont:
      return [Localized titleMathText];
    case MATHResetButtonKindOtherFont:
    case MATHResetButtonKindOtherTextColor:
      return [Localized titleNormalText];
    case MATHResetButtonKindErrorFont:
    case MATHResetButtonKindErrorTextColor:
      return [Localized titleErrorText];
    case MATHResetButtonKindOperandColor:
      return [Localized titleOperand];
    case MATHResetButtonKindOperatorColor:
      return [Localized titleOperator];
    case MATHResetButtonKindSolutionColor:
      return [Localized titleSolution];
    case MATHResetButtonKindPreviousSolutionColor:
      return [Localized  titleCarryover];
    case MATHResetButtonKindInsertionPointColor:
      return [Localized titleInsertionPoint];
    case MATHResetButtonKindBackgroundColor:
      return [Localized titleBackground];
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHResetButtonKind(%d)", (int)kind);
      return @"Unknown";
  }
}

MATHResetButtonKind MATH_resetButtonKindForColorWellKind(MATHColorWellKind kind)
{
  switch (kind) {
    case MATHColorWellKindOperandLight:
    case MATHColorWellKindOperandDark:
      return MATHResetButtonKindOperandColor;
    case MATHColorWellKindOperatorLight:
    case MATHColorWellKindOperatorDark:
      return MATHResetButtonKindOperatorColor;
    case MATHColorWellKindSolutionLight:
    case MATHColorWellKindSolutionDark:
      return MATHResetButtonKindSolutionColor;
    case MATHColorWellKindSolutionSecondaryLight:
    case MATHColorWellKindSolutionSecondaryDark:
      return MATHResetButtonKindPreviousSolutionColor;
    case MATHColorWellKindOtherTextLight:
    case MATHColorWellKindOtherTextDark:
      return MATHResetButtonKindOtherTextColor;
    case MATHColorWellKindErrorTextLight:
    case MATHColorWellKindErrorTextDark:
      return MATHResetButtonKindErrorTextColor;
    case MATHColorWellKindInsertionPointLight:
    case MATHColorWellKindInsertionPointDark:
      return MATHResetButtonKindInsertionPointColor;
    case MATHColorWellKindBackgroundLight:
    case MATHColorWellKindBackgroundDark:
      return MATHResetButtonKindBackgroundColor;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHColorWellKind(%d)", (int)kind);
      return MATHResetButtonKindUnknown;
  }
}

MATHResetButtonKind MATH_resetButtonKindForFontSettingKind(MATHThemeFont kind)
{
  switch (kind) {
    case MATHThemeFontMath:
      return MATHResetButtonKindMathFont;
    case MATHThemeFontOther:
      return MATHResetButtonKindOtherFont;
    case MATHThemeFontError:
      return MATHResetButtonKindErrorFont;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHThemeFont(%d)", (int)kind);
      return MATHResetButtonKindUnknown;
  }
}
