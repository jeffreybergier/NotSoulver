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

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "NSUserDefaults+MathEdit.h"

// MARK: View Enumerations

typedef XP_ENUM(XPInteger, MATHColorWellKind) {
  MATHColorWellKindUnknown,
  MATHColorWellKindOperandLight,
  MATHColorWellKindOperandDark,
  MATHColorWellKindOperatorLight,
  MATHColorWellKindOperatorDark,
  MATHColorWellKindSolutionLight,
  MATHColorWellKindSolutionDark,
  MATHColorWellKindSolutionSecondaryLight,
  MATHColorWellKindSolutionSecondaryDark,
  MATHColorWellKindOtherTextLight,
  MATHColorWellKindOtherTextDark,
  MATHColorWellKindErrorTextLight,
  MATHColorWellKindErrorTextDark,
  MATHColorWellKindInsertionPointLight,
  MATHColorWellKindInsertionPointDark,
  MATHColorWellKindBackgroundLight,
  MATHColorWellKindBackgroundDark,
};

typedef XP_ENUM(XPInteger, MATHResetButtonKind) {
  MATHResetButtonKindUnknown,
  MATHResetButtonKindUIStyle,
  MATHResetButtonKindWaitTime,
  MATHResetButtonKindMathFont,
  MATHResetButtonKindOtherFont,
  MATHResetButtonKindErrorFont,
  MATHResetButtonKindOperandColor,
  MATHResetButtonKindOperatorColor,
  MATHResetButtonKindSolutionColor,
  MATHResetButtonKindPreviousSolutionColor,
  MATHResetButtonKindOtherTextColor,
  MATHResetButtonKindErrorTextColor,
  MATHResetButtonKindInsertionPointColor,
  MATHResetButtonKindBackgroundColor
};

typedef XP_ENUM(XPInteger, MATHKeypadButtonKind) {
  MATHKeypadButtonKindUnknown,
  MATHKeypadButtonKind1,
  MATHKeypadButtonKind2,
  MATHKeypadButtonKind3,
  MATHKeypadButtonKind4,
  MATHKeypadButtonKind5,
  MATHKeypadButtonKind6,
  MATHKeypadButtonKind7,
  MATHKeypadButtonKind8,
  MATHKeypadButtonKind9,
  MATHKeypadButtonKind0,
  MATHKeypadButtonKindNegative,
  MATHKeypadButtonKindDecimal,
  MATHKeypadButtonKindDelete,
  MATHKeypadButtonKindEqual,
  MATHKeypadButtonKindAdd,
  MATHKeypadButtonKindSubtract,
  MATHKeypadButtonKindBRight,
  MATHKeypadButtonKindMultiply,
  MATHKeypadButtonKindDivide,
  MATHKeypadButtonKindBLeft,
  MATHKeypadButtonKindPower,
  MATHKeypadButtonKindRoot,
  MATHKeypadButtonKindLog
};

static const XPFloat MATHAccessoryWindowKeypadWindowPadding        = 6;
static const NSSize  MATHAccessoryWindowKeypadWindowButtonSize     = {40, 32};
static const XPFloat MATHAccessoryWindowKeypadWindowGroupSpacing   = 8;
static const XPFloat MATHAccessoryWindowKeypadWindowButtonVPadding = 4;
static const XPFloat MATHAccessoryWindowKeypadWindowButtonHPadding = 4;

// MARK: MATHAccessoryWindowKeypadView

@interface MATHAccessoryWindowKeypadView: NSView
{
  mm_unretain NSButton *_equalButton;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSButton*)equalButton;
@end

// MARK: MATHAccessoryWindowAboutView

@interface MATHAccessoryWindowAboutView: NSView
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

// MARK: MATHAccessoryWindowSettingsView

@class XPSegmentedControl;

@interface MATHAccessoryWindowsSettingsGeneralView: NSView
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

@interface MATHAccessoryWindowsSettingsColorsView: NSView
{
  mm_new NSMutableDictionary *_colorWells;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSColorWell*)colorWellOfKind:(MATHColorWellKind)kind;
-(void)setColorWell:(NSColorWell*)colorWell
            forKind:(MATHColorWellKind)kind;
@end

@interface MATHAccessoryWindowsSettingsFontsView: NSView
{
  mm_new NSMutableDictionary *_textFields;
}
-(id)initWithFrame:(NSRect)frameRect;
-(NSTextField*)textFieldOfKind:(MATHThemeFont)kind;
-(void)setTextField:(NSTextField*)textField
            forKind:(MATHThemeFont)kind;
@end

@interface XPSegmentedControl: NSControl
{
  mm_new NSMutableArray *_buttons;
  XPUInteger _selectedSegment;
}
// This is needed on older systems to ensure that
// Target and Action are properly stored
+(Class)cellClass;
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
-(NSButton*)__insertButtonAtIndex:(XPInteger)index;
-(void)__recalculateFrames;
@end

@interface NSControl (MATHAccessoryWindows)
+(NSButton*)MATH_keypadButtonOfKind:(MATHKeypadButtonKind)kind;
+(NSButton*)MATH_settingsButtonWithFrame:(NSRect)frame
                                   title:(NSString*)title
                                  action:(SEL)action
                                     tag:(XPInteger)tag;
+(NSColorWell*)MATH_colorWellWithFrame:(NSRect)frame
                                  kind:(MATHColorWellKind)kind;
+(NSTextField*)MATH_labelWithFrame:(NSRect)frame;
+(NSTextField*)MATH_textFieldWithFrame:(NSRect)frame
                                target:(id)target
                                action:(SEL)action;
-(id)MATH_sizeToFitVertically;
-(id)MATH_setObjectValue:(id)objectValue
                    font:(NSFont*)font
               alignment:(NSTextAlignment)alignment;
@end

@interface NSView (MATHAccessoryWindows)
+(NSBox*)MATH_lineWithFrame:(NSRect)frame;
-(id)MATH_setAutoresizingMask:(XPUInteger)mask;
@end

@interface NSImageView (MATHAccessoryWindows)
+(NSImageView*)MATH_imageViewWithOrigin:(NSPoint)origin
                   sizedToFitImageNamed:(NSString*)imageName;
+(NSImageView*)MATH_imageViewWithFrame:(NSRect)frame
                            imageNamed:(NSString*)imageName;
-(NSImageView*)MATH_setImageFrameStyle:(NSImageFrameStyle)imageFrameStyle;
@end

@interface NSImage (MATHAccessoryWindows)
-(NSImage*)MATH_setTemplate:(BOOL)flag;
@end

@interface NSCell (CrossPlatform)
-(void)XP_setSendsActionOnEndEditing:(BOOL)sendsAction;
@end

NSRect MATH_rectForKeypadButtonOfKind(MATHKeypadButtonKind kind);
NSRect MATH_rectByAdjustingAquaButtonRect(NSRect rect);
NSString *MATH_titleForKeypadButtonOfKind(MATHKeypadButtonKind kind);
NSString *MATH_keyForKeypadButtonOfKind(MATHKeypadButtonKind kind);
NSString *MATH_localizedStringForKind(MATHResetButtonKind kind);
MATHResetButtonKind MATH_resetButtonKindForColorWellKind(MATHColorWellKind kind);
MATHResetButtonKind MATH_resetButtonKindForFontSettingKind(MATHThemeFont kind);

// These are not implemented, but silence compiler warnings
@interface NSResponder (MATHIBActions)
-(IBAction)openSourceRepository:(id)sender;
-(IBAction)presentFontPanel:(id)sender;
-(IBAction)writeUserInterfaceStyle:(id)sender;
-(IBAction)writeColor:(id)sender;
-(IBAction)writeWaitTime:(id)sender;
-(IBAction)keypadAppend:(id)sender;
-(IBAction)reset:(id)sender;
@end
