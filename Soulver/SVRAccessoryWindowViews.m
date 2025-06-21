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
  [self addSubview:[NSImageView SVR_imageViewWithOrigin:kTagLineOrigin
                                   sizedToFitImageNamed:[Localized imageNeXTTagline]]];
  
  // Dedication Text
  [self addSubview:[[NSTextField SVR_labelWithFrame:kDedicationTextFrame]
                                 SVR_setObjectValue:[Localized phraseAboutDedication]
                                               font:[NSFont systemFontOfSize:10]
                                          alignment:XPTextAlignmentLeft]];
  
  // View Source Button
  _viewSourceButton = [[[self class] __viewSourceButtonWithFrame:SVR_rectByAdjustingAquaButtonRect(kViewSourceButtonFrame)
                                                           title:[Localized verbViewSource]
                                                      imageNamed:[Localized imageNeXTLogo]]
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
                                  SVR_setObjectValue:[Localized phraseAboutTagline]
                                                font:[NSFont systemFontOfSize:16]
                                           alignment:XPTextAlignmentCenter]
                             SVR_setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable]];
  
  // Add Title Label
  [self addSubview:[[[NSTextField SVR_labelWithFrame:kTitleTextFrame]
                                  SVR_setObjectValue:[Localized titleAppName]
                                                font:[NSFont boldSystemFontOfSize:36]
                                           alignment:XPTextAlignmentCenter]
                             SVR_setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable]];
  
  // Add Portrait Image View
  [self addSubview:[[[NSImageView SVR_imageViewWithFrame:kPortraitImageView
                                              imageNamed:[Localized imageAboutPortrait]]
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

// MARK: SVRAccessoryWindowSettingsView

@implementation SVRAccessoryWindowsSettingsGeneralView

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
  SVRResetButtonKind kind = SVRResetButtonKindUnknown;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  
  // User Interface Style Selector
  kind = SVRResetButtonKindUIStyle;
  [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                  SVR_setObjectValue:SVR_localizedStringForKind(kind)
                                                font:nil
                                           alignment:XPTextAlignmentLeft]
                             SVR_sizeToFitVertically]];
  
  _selectorControl = [[[XPSegmentedControl alloc] initWithFrame:sgmntRect] autorelease];
  [_selectorControl setSegmentCount:3];
  [_selectorControl setLabel:[Localized titleAutomatic] forSegment:0];
  [_selectorControl setLabel:[Localized titleLight    ] forSegment:1];
  [_selectorControl setLabel:[Localized titleDark     ] forSegment:2];
  [_selectorControl setImage:[[NSImage imageNamed:@"ThemeAuto" ] SVR_setTemplate:YES] forSegment:0];
  [_selectorControl setImage:[[NSImage imageNamed:@"ThemeLight"] SVR_setTemplate:YES] forSegment:1];
  [_selectorControl setImage:[[NSImage imageNamed:@"ThemeDark" ] SVR_setTemplate:YES] forSegment:2];
  [_selectorControl setAction:SVR_selectorOfKind(SVRSelectorKindWriteUserInterfaceStyle)];
  [self addSubview:_selectorControl];
  
  // Adjust frames
  kind = SVRResetButtonKindWaitTime;
  labelRect.origin.y = slidrRect.origin.y+kSlidrH+4;
  
  // Wait Time Slider
  [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                  SVR_setObjectValue:SVR_localizedStringForKind(kind)
                                                font:nil
                                           alignment:XPTextAlignmentLeft]
                             SVR_sizeToFitVertically]];
  
  _delayLabel = [NSTextField SVR_textFieldWithFrame:delayRect
                                             target:nil
                                             action:NULL];
  [_delayLabel setAlignment:XPTextAlignmentCenter];
  [self addSubview:_delayLabel];
  
  _delaySlider = [[[NSSlider alloc] initWithFrame:slidrRect] autorelease];
  [_delaySlider setMinValue:0];
  [_delaySlider setMaxValue:10];
  [_delaySlider setAction:SVR_selectorOfKind(SVRSelectorKindWriteWaitTime)];
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

@implementation SVRAccessoryWindowsSettingsColorsView

-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kVPad = 32;
  XPFloat kYOrigin = frameRect.size.height-48;
  NSRect resetRect = NSMakeRect(frameRect.size.width-50, kYOrigin,   50,                   30);
  NSRect darkkRect = NSMakeRect(resetRect.origin.x-50-4, kYOrigin,   50,                   30);
  NSRect lightRect = NSMakeRect(darkkRect.origin.x-50-4, kYOrigin,   50,                   30);
  NSRect labelRect = NSMakeRect(frameRect.origin.x,      kYOrigin+4, lightRect.origin.x-4,  0);
  SVRColorWellKind colorKind = SVRColorWellKindUnknown;
  SVRResetButtonKind resetKind = SVRResetButtonKindUnknown;
  NSColorWell *colorWell = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _colorWells = [NSMutableDictionary new];
  
  for (colorKind =SVRColorWellKindOperandLight;
       colorKind<=SVRColorWellKindBackgroundDark;
       colorKind++)
  {
    resetKind = SVR_resetButtonKindForColorWellKind(colorKind);
    if (colorKind % 2) {
      [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                      SVR_setObjectValue:SVR_localizedStringForKind(resetKind)
                                                    font:nil
                                               alignment:XPTextAlignmentRight]
                                 SVR_sizeToFitVertically]];
      colorWell = [NSColorWell SVR_colorWellWithFrame:lightRect kind:colorKind];
      [self addSubview:colorWell];
      labelRect.origin.y -= kVPad;
      lightRect.origin.y -= kVPad;
    } else {
      [self addSubview:[NSButton SVR_settingsButtonWithFrame:SVR_rectByAdjustingAquaButtonRect(resetRect)
                                                       title:[Localized verbReset]
                                                      action:SVR_selectorOfKind(SVRSelectorKindReset)
                                                         tag:resetKind]];
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
                                  SVR_setObjectValue:[Localized titleLight]
                                                font:[NSFont systemFontOfSize:10]
                                           alignment:XPTextAlignmentCenter]
                             SVR_sizeToFitVertically]];
  [self addSubview:[[[NSTextField SVR_labelWithFrame:darkkRect]
                                  SVR_setObjectValue:[Localized titleDark]
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

@implementation SVRAccessoryWindowsSettingsFontsView
-(id)initWithFrame:(NSRect)frameRect;
{
  XPFloat kLabelYOffset = 32;
  XPFloat kYOrigin = frameRect.size.height-kLabelYOffset-16;
  XPFloat kVPad = kLabelYOffset + 22;
  NSRect resetRect = NSMakeRect(frameRect.size.width-50, kYOrigin,               50,                   30);
  NSRect setttRect = NSMakeRect(resetRect.origin.x-50-4, kYOrigin,               50,                   30);
  NSRect fieldRect = NSMakeRect(frameRect.origin.x,      kYOrigin,               setttRect.origin.x-4, 30);
  NSRect labelRect = NSMakeRect(frameRect.origin.x,      kYOrigin+kLabelYOffset, setttRect.origin.x-4,  0);
  SVRThemeFont fontKind = SVRThemeFontUnknown;
  SVRResetButtonKind resetKind = SVRResetButtonKindUnknown;
  NSTextField *textField = nil;
  
  self = [super initWithFrame:frameRect];
  XPParameterRaise(self);
  _textFields = [NSMutableDictionary new];
  
  for (fontKind =SVRThemeFontMath;
       fontKind<=SVRThemeFontError;
       fontKind++)
  {
    resetKind = SVR_resetButtonKindForFontSettingKind(fontKind);
    
    // Label
    [self addSubview:[[[NSTextField SVR_labelWithFrame:labelRect]
                                    SVR_setObjectValue:SVR_localizedStringForKind(resetKind)
                                                  font:nil
                                             alignment:XPTextAlignmentLeft]
                               SVR_sizeToFitVertically]];
    
    // TextField
    textField = [NSTextField SVR_textFieldWithFrame:fieldRect
                                             target:nil
                                             action:NULL];
    [self setTextField:textField forKind:fontKind];
    [self addSubview:textField];
    
    // Buttons
    [self addSubview:[NSButton SVR_settingsButtonWithFrame:SVR_rectByAdjustingAquaButtonRect(setttRect)
                                                     title:[Localized verbSet]
                                                    action:SVR_selectorOfKind(SVRSelectorKindPresentFontPanel)
                                                       tag:fontKind]];
    [self addSubview:[NSButton SVR_settingsButtonWithFrame:SVR_rectByAdjustingAquaButtonRect(resetRect)
                                                     title:[Localized verbReset]
                                                    action:SVR_selectorOfKind(SVRSelectorKindReset)
                                                       tag:resetKind]];
    
    // Adjust frames
    labelRect.origin.y -= kVPad;
    fieldRect.origin.y -= kVPad;
    setttRect.origin.y -= kVPad;
    resetRect.origin.y -= kVPad;
  }
  
  return self;
}

-(NSTextField*)textFieldOfKind:(SVRThemeFont)kind;
{
  NSTextField *textField = [_textFields objectForKey:[NSNumber XP_numberWithInteger:kind]];
  XPParameterRaise(textField);
  return textField;
}

-(void)setTextField:(NSTextField*)textField
            forKind:(SVRThemeFont)kind;
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
  return _selectedSegment;
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
  _selectedSegment = _selection;
}

-(NSString*)labelForSegment:(XPInteger)segment;
{
  return [[_buttons objectAtIndex:segment] title];
}

-(void)setLabel:(NSString*)label forSegment:(XPInteger)segment;
{
  XPInteger count = (XPInteger)[_buttons count];
  NSButton *button = nil;
  if (segment < count) {
    [[_buttons objectAtIndex:segment] setTitle:label];
  } else {
    button = [self __newButtonAtIndex:segment];
    [button setTitle:label];
  }
}

-(NSImage*)imageForSegment:(XPInteger)segment;
{
  return [[_buttons objectAtIndex:segment] image];
}

-(void)setImage:(NSImage*)image forSegment:(XPInteger)segment;
{
  XPInteger count = (XPInteger)[_buttons count];
  NSButton *button = nil;
  if (segment < count) {
    [[_buttons objectAtIndex:segment] setImage:image];
  } else {
    button = [self __newButtonAtIndex:segment];
    [button setImage:image];
  }
}

-(IBAction)__selectedSegmentChanged:(NSButton*)sender;
{
  XPUInteger index = [_buttons indexOfObject:sender];
  XPLogAssrt1(index != (XPUInteger)NSNotFound, @"[UNKNOWN] Sender(%@)", sender);
	XPLogAssrt([self action], @"Selector was NULL");
  [self setSelectedSegment:index];
  [self sendAction:[self action] to:[self target]];
}

-(NSButton*)__newButtonAtIndex:(XPInteger)index;
{
  NSButton *button = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
  [_buttons insertObject:button atIndex:index];
  
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  [button setButtonType:XPButtonTypePushOnPushOff];
  [button setImagePosition:NSImageAbove];
  [button setAction:@selector(__selectedSegmentChanged:)];
  [button setTarget:self];
  
  [self __recalculateFrames];
  [self setSelectedSegment:_selectedSegment];
  [self addSubview:button];
  return button;
}

-(void)__recalculateFrames;
{
  const XPFloat kPad = 4;
  XPInteger index = 0;
  NSRect myBounds = [self bounds];
  NSRect buttonFrame = myBounds;
  XPInteger count = [_buttons count];
  
  buttonFrame.size.width = floor(myBounds.size.width/count) - (kPad/2);
  for (index=0; index<count; index++) {
    buttonFrame.origin.x = (buttonFrame.size.width*index) + (kPad*index);
    [[_buttons objectAtIndex:index] setFrame:SVR_rectByAdjustingAquaButtonRect(buttonFrame)];
  }
}

-(void)dealloc;
{
  [_buttons release];
  _buttons = nil;
  [super dealloc];
}

@end

@implementation NSControl (SVRAccessoryWindows)

+(NSButton*)SVR_keypadButtonOfKind:(SVRKeypadButtonKind)kind;
{
  NSButton *button = [[[NSButton alloc] initWithFrame:SVR_rectForKeypadButtonOfKind(kind)] autorelease];
  [button setTitle:SVR_titleForKeypadButtonOfKind(kind)];
  [button setKeyEquivalent:SVR_keyForKeypadButtonOfKind(kind)];
  [button setTag:kind];
  [button setAction:SVR_selectorOfKind(SVRSelectorKindKeypadAppend)];
  [button XP_setBezelStyle:XPBezelStyleFlexiblePush];
  return button;
}

+(NSButton*)SVR_settingsButtonWithFrame:(NSRect)frame
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

+(NSColorWell*)SVR_colorWellWithFrame:(NSRect)frame
                                 kind:(SVRColorWellKind)kind;
{
  NSColorWell *well = [[[NSColorWell alloc] initWithFrame:frame] autorelease];
  [well setTag:kind];
  [well setAction:SVR_selectorOfKind(SVRSelectorKindWriteColor)];
  return well;
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

+(NSTextField*)SVR_textFieldWithFrame:(NSRect)frame
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

@implementation NSImage (SVRAccessoryWindows)
-(NSImage*)SVR_setTemplate:(BOOL)flag;
{
#ifdef XPSupportsTemplateImage
  [self setTemplate:flag];
#endif
  return self;
}
@end

SEL SVR_selectorOfKind(SVRSelectorKind kind)
{
  SEL output = NULL;
  switch (kind) {
    case SVRSelectorKindReset:
      output = NSSelectorFromString(@"reset:");
      break;
    case SVRSelectorKindKeypadAppend:
      output = NSSelectorFromString(@"keypadAppend:");
      break;
    case SVRSelectorKindWriteColor:
      output = NSSelectorFromString(@"writeColor:");
      break;
    case SVRSelectorKindWriteWaitTime:
      output = NSSelectorFromString(@"writeWaitTime:");
      break;
    case SVRSelectorKindWriteUserInterfaceStyle:
      output = NSSelectorFromString(@"writeUserInterfaceStyle:");
      break;
    case SVRSelectorKindPresentFontPanel:
      output = NSSelectorFromString(@"presentFontPanel:");
      break;
    default:
      output = NULL;
  }
  XPCLogAssrt1(output!=NULL, @"[UNKNOWN] SVRSelectorKind(%d)", (int)kind);
  return output;
}

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
  return SVR_rectByAdjustingAquaButtonRect(output);
}

NSRect SVR_rectByAdjustingAquaButtonRect(NSRect rect)
{
#if XPUserInterface == XPUserInterfaceAqua
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

NSString *SVR_localizedStringForKind(SVRResetButtonKind kind)
{
  switch (kind) {
    case SVRResetButtonKindUIStyle:
      return [Localized titleTheme];
    case SVRResetButtonKindWaitTime:
      return [Localized titleSolvingDelay];
    case SVRResetButtonKindMathFont:
      return [Localized titleMathText];
    case SVRResetButtonKindOtherFont:
    case SVRResetButtonKindOtherTextColor:
      return [Localized titleNormalText];
    case SVRResetButtonKindErrorFont:
    case SVRResetButtonKindErrorTextColor:
      return [Localized titleErrorText];
    case SVRResetButtonKindOperandColor:
      return [Localized titleOperand];
    case SVRResetButtonKindOperatorColor:
      return [Localized titleOperator];
    case SVRResetButtonKindSolutionColor:
      return [Localized titleSolution];
    case SVRResetButtonKindPreviousSolutionColor:
      return [Localized  titleCarryover];
    case SVRResetButtonKindInsertionPointColor:
      return [Localized titleInsertionPoint];
    case SVRResetButtonKindBackgroundColor:
      return [Localized titleBackground];
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

SVRResetButtonKind SVR_resetButtonKindForFontSettingKind(SVRThemeFont kind)
{
  switch (kind) {
    case SVRThemeFontMath:
      return SVRResetButtonKindMathFont;
    case SVRThemeFontOther:
      return SVRResetButtonKindOtherFont;
    case SVRThemeFontError:
      return SVRResetButtonKindErrorFont;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRThemeFont(%d)", (int)kind);
      return SVRResetButtonKindUnknown;
  }
}
