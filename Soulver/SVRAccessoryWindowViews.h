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

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "NSUserDefaults+Soulver.h"

// MARK: View Enumerations

typedef XP_ENUM(XPInteger, SVRSelectorKind) {
  SVRSelectorKindUnknown,
  SVRSelectorKindReset,
  SVRSelectorKindKeypadAppend,
  SVRSelectorKindWriteColor,
  SVRSelectorKindWriteWaitTime,
  SVRSelectorKindWriteUserInterfaceStyle,
  SVRSelectorKindPresentFontPanel
};

typedef XP_ENUM(XPInteger, SVRColorWellKind) {
  SVRColorWellKindUnknown,
  SVRColorWellKindOperandLight,
  SVRColorWellKindOperandDark,
  SVRColorWellKindOperatorLight,
  SVRColorWellKindOperatorDark,
  SVRColorWellKindSolutionLight,
  SVRColorWellKindSolutionDark,
  SVRColorWellKindSolutionSecondaryLight,
  SVRColorWellKindSolutionSecondaryDark,
  SVRColorWellKindOtherTextLight,
  SVRColorWellKindOtherTextDark,
  SVRColorWellKindErrorTextLight,
  SVRColorWellKindErrorTextDark,
  SVRColorWellKindInsertionPointLight,
  SVRColorWellKindInsertionPointDark,
  SVRColorWellKindBackgroundLight,
  SVRColorWellKindBackgroundDark,
};

typedef XP_ENUM(XPInteger, SVRResetButtonKind) {
  SVRResetButtonKindUnknown,
  SVRResetButtonKindUIStyle,
  SVRResetButtonKindWaitTime,
  SVRResetButtonKindMathFont,
  SVRResetButtonKindOtherFont,
  SVRResetButtonKindErrorFont,
  SVRResetButtonKindOperandColor,
  SVRResetButtonKindOperatorColor,
  SVRResetButtonKindSolutionColor,
  SVRResetButtonKindPreviousSolutionColor,
  SVRResetButtonKindOtherTextColor,
  SVRResetButtonKindErrorTextColor,
  SVRResetButtonKindInsertionPointColor,
  SVRResetButtonKindBackgroundColor
};

typedef XP_ENUM(XPInteger, SVRKeypadButtonKind) {
  SVRKeypadButtonKindUnknown,
  SVRKeypadButtonKind1,
  SVRKeypadButtonKind2,
  SVRKeypadButtonKind3,
  SVRKeypadButtonKind4,
  SVRKeypadButtonKind5,
  SVRKeypadButtonKind6,
  SVRKeypadButtonKind7,
  SVRKeypadButtonKind8,
  SVRKeypadButtonKind9,
  SVRKeypadButtonKind0,
  SVRKeypadButtonKindNegative,
  SVRKeypadButtonKindDecimal,
  SVRKeypadButtonKindDelete,
  SVRKeypadButtonKindEqual,
  SVRKeypadButtonKindAdd,
  SVRKeypadButtonKindSubtract,
  SVRKeypadButtonKindBRight,
  SVRKeypadButtonKindMultiply,
  SVRKeypadButtonKindDivide,
  SVRKeypadButtonKindBLeft,
  SVRKeypadButtonKindPower,
  SVRKeypadButtonKindRoot,
  SVRKeypadButtonKindLog
};

static const XPFloat SVRAccessoryWindowKeypadWindowPadding        = 6;
static const NSSize  SVRAccessoryWindowKeypadWindowButtonSize     = {40, 32};
static const XPFloat SVRAccessoryWindowKeypadWindowGroupSpacing   = 8;
static const XPFloat SVRAccessoryWindowKeypadWindowButtonVPadding = 4;
static const XPFloat SVRAccessoryWindowKeypadWindowButtonHPadding = 4;

// MARK: SVRAccessoryWindowKeypadView

@interface SVRAccessoryWindowKeypadView: NSView
{
  mm_unretain NSButton *_equalButton;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSButton*)equalButton;
@end

// MARK: SVRAccessoryWindowAboutView

@interface SVRAccessoryWindowAboutView: NSView
{
  mm_unretain NSTextView *_textView;
  mm_unretain NSButton   *_viewSourceButton;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSTextView*)textView;
-(NSButton*)viewSourceButton;
+(NSScrollView*)__scrollViewWithFrame:(NSRect)frame
                             textView:(NSTextView**)inoutTextView;
+(NSButton*)__viewSourceButtonWithFrame:(NSRect)frame
                                  title:(NSString*)title
                             imageNamed:(NSString*)imageName;
@end

// MARK: SVRAccessoryWindowSettingsView

@class XPSegmentedControl;

@interface SVRAccessoryWindowsSettingsGeneralView: NSView
{
  mm_unretain XPSegmentedControl *_selectorControl;
  mm_unretain NSTextField *_delayLabel;
  mm_unretain NSSlider *_delaySlider;
}
-(id)initWithFrame:(NSRect)frameRect;
-(XPSegmentedControl*)themeSelector;
-(NSTextField*)delayLabel;
-(NSSlider*)delaySlider;
@end

@interface SVRAccessoryWindowsSettingsColorsView: NSView
{
  mm_new NSMutableDictionary *_colorWells;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSColorWell*)colorWellOfKind:(SVRColorWellKind)kind;
-(void)setColorWell:(NSColorWell*)colorWell
            forKind:(SVRColorWellKind)kind;
@end

@interface SVRAccessoryWindowsSettingsFontsView: NSView
{
  mm_new NSMutableDictionary *_textFields;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSTextField*)textFieldOfKind:(SVRThemeFont)kind;
-(void)setTextField:(NSTextField*)textField
            forKind:(SVRThemeFont)kind;
@end

@interface XPSegmentedControl: NSControl
{
  mm_new NSMutableArray *_buttons;
  XPUInteger _selectedSegment;
}
-(id)initWithFrame:(NSRect)frameRect;
/// Ignored in XPSegmentedControl but required in NSSegmentedControl
-(void)setSegmentCount:(XPInteger)_;
-(XPInteger)selectedSegment;
-(void)setSelectedSegment:(XPInteger)selection;
-(NSString*)labelForSegment:(XPInteger)segment;
-(void)setLabel:(NSString*)label forSegment:(XPInteger)segment;
-(NSImage*)imageForSegment:(XPInteger)segment;
-(void)setImage:(NSImage*)image forSegment:(XPInteger)segment;
-(IBAction)__selectedSegmentChanged:(NSButton*)sender;
-(NSButton*)__newButtonAtIndex:(XPInteger)index;
-(void)__recalculateFrames;
@end

@interface NSControl (SVRAccessoryWindows)
+(NSButton*)SVR_keypadButtonOfKind:(SVRKeypadButtonKind)kind;
+(NSButton*)SVR_settingsButtonWithFrame:(NSRect)frame
                                  title:(NSString*)title
                                 action:(SEL)action
                                    tag:(XPInteger)tag;
+(NSColorWell*)SVR_colorWellWithFrame:(NSRect)frame
                                 kind:(SVRColorWellKind)kind;
+(NSTextField*)SVR_labelWithFrame:(NSRect)frame;
+(NSTextField*)SVR_textFieldWithFrame:(NSRect)frame
                               target:(id)target
                               action:(SEL)action;
-(id)SVR_sizeToFitVertically;
-(id)SVR_setObjectValue:(id)objectValue
                   font:(NSFont*)font
              alignment:(NSTextAlignment)alignment;
@end

@interface NSView (SVRAccessoryWindows)
+(NSBox*)SVR_lineWithFrame:(NSRect)frame;
-(id)SVR_setAutoresizingMask:(XPUInteger)mask;
@end

@interface NSImageView (SVRAccessoryWindows)
+(NSImageView*)SVR_imageViewWithOrigin:(NSPoint)origin
                  sizedToFitImageNamed:(NSString*)imageName;
+(NSImageView*)SVR_imageViewWithFrame:(NSRect)frame
                           imageNamed:(NSString*)imageName;
-(NSImageView*)SVR_setImageFrameStyle:(NSImageFrameStyle)imageFrameStyle;
@end

@interface NSImage (SVRAccessoryWindows)
-(NSImage*)SVR_asTemplateImage;
@end

@interface NSCell (CrossPlatform)
-(void)XP_setSendsActionOnEndEditing:(BOOL)sendsAction;
@end

SEL SVR_selectorOfKind(SVRSelectorKind kind);
NSRect SVR_rectForKeypadButtonOfKind(SVRKeypadButtonKind kind);
NSRect SVR_rectByAdjustingAquaButtonRect(NSRect rect);
NSString *SVR_titleForKeypadButtonOfKind(SVRKeypadButtonKind kind);
NSString *SVR_keyForKeypadButtonOfKind(SVRKeypadButtonKind kind);
NSString *SVR_localizedStringForKind(SVRResetButtonKind kind);
SVRResetButtonKind SVR_resetButtonKindForColorWellKind(SVRColorWellKind kind);
SVRResetButtonKind SVR_resetButtonKindForFontSettingKind(SVRThemeFont kind);
XPBezelStyle SVR_keypadButtonStyle(void);
XPBezelStyle SVR_settingsButtonStyle(void);
XPBezelStyle SVR_aboutButtonStyle(void);
