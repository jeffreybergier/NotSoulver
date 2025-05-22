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

#import "SVRSettingsViewController.h"
#import "SVRAccessoryWindowsOwner.h"

@implementation SVRSettingsViewController

-(void)awakeFromNib;
{
  // Configure Responder Chain
  [self setNextResponder:[_window nextResponder]];
  [_window setNextResponder:self];
  
  // Retain these views so I can remove them from the view hierarchy ad-hoc
  [_groupFontView retain];
  [_groupColorView retain];
  [_groupGeneralView retain];
  
  // Configure the screen
  [self choiceChanged:nil];
  [self populateUI];
  [self configureWellTags];
  
  // Announce
  NSLog(@"%@ awakeFromNib", self);
}

-(void)configureWellTags;
{
  // Uses Bitwise Packing to store both enumerations within the tag.
  // I got the info for how to do this from ChatGPT so can't provide attributions :-/
  short int dkBG = (SVRThemeColorBackground        & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkER = (SVRThemeColorErrorText         & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkIP = (SVRThemeColorInsertionPoint    & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkOD = (SVRThemeColorOperandText       & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkOR = (SVRThemeColorOperatorText      & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkOT = (SVRThemeColorOtherText         & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkPS = (SVRThemeColorSolutionSecondary & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int dkSL = (SVRThemeColorSolution          & 0xFF) | ((XPUserInterfaceStyleDark  & 0xFF) << 8);
  short int ltBG = (SVRThemeColorBackground        & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltER = (SVRThemeColorErrorText         & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltIP = (SVRThemeColorInsertionPoint    & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltOD = (SVRThemeColorOperandText       & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltOR = (SVRThemeColorOperatorText      & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltOT = (SVRThemeColorOtherText         & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltPS = (SVRThemeColorSolutionSecondary & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  short int ltSL = (SVRThemeColorSolution          & 0xFF) | ((XPUserInterfaceStyleLight & 0xFF) << 8);
  
  [_wellDarkBackground      setTag:dkBG];
  [_wellDarkError           setTag:dkER];
  [_wellDarkInsertionPoint  setTag:dkIP];
  [_wellDarkOperand         setTag:dkOD];
  [_wellDarkOperator        setTag:dkOR];
  [_wellDarkOther           setTag:dkOT];
  [_wellDarkPrevious        setTag:dkPS];
  [_wellDarkSolution        setTag:dkSL];
  [_wellLightBackground     setTag:ltBG];
  [_wellLightError          setTag:ltER];
  [_wellLightInsertionPoint setTag:ltIP];
  [_wellLightOperand        setTag:ltOD];
  [_wellLightOperator       setTag:ltOR];
  [_wellLightOther          setTag:ltOT];
  [_wellLightPrevious       setTag:ltPS];
  [_wellLightSolution       setTag:ltSL];
}

-(void)populateUI;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSFont *currentFont = nil;
  NSAttributedString *currentFontString = nil;
  NSMutableDictionary *currentFontAttribs = [[NSMutableDictionary new] autorelease];
  
  // TODO: Add memory for panel selected in settings
  // [_popUpPage selectItemAtIndex:[ud SVR_selectedSettingsPage]];
  
  // Configure theme
  [_popUpTheme selectItemAtIndex:[ud SVR_userInterfaceStyleSetting]];
  
  // Dark Theme Colors
  [_wellDarkBackground     setColor:[ud SVR_colorForTheme:SVRThemeColorBackground
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkError          setColor:[ud SVR_colorForTheme:SVRThemeColorErrorText
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkInsertionPoint setColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkOperand        setColor:[ud SVR_colorForTheme:SVRThemeColorOperandText
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkOperator       setColor:[ud SVR_colorForTheme:SVRThemeColorOperatorText
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkOther          setColor:[ud SVR_colorForTheme:SVRThemeColorOtherText
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkPrevious       setColor:[ud SVR_colorForTheme:SVRThemeColorSolutionSecondary
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkSolution       setColor:[ud SVR_colorForTheme:SVRThemeColorSolution
                                                withStyle:XPUserInterfaceStyleDark]];
  // Light Theme Colors
  [_wellLightBackground     setColor:[ud SVR_colorForTheme:SVRThemeColorBackground
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightError          setColor:[ud SVR_colorForTheme:SVRThemeColorErrorText
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightInsertionPoint setColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightOperand        setColor:[ud SVR_colorForTheme:SVRThemeColorOperandText
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightOperator       setColor:[ud SVR_colorForTheme:SVRThemeColorOperatorText
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightOther          setColor:[ud SVR_colorForTheme:SVRThemeColorOtherText
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightPrevious       setColor:[ud SVR_colorForTheme:SVRThemeColorSolutionSecondary
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightSolution       setColor:[ud SVR_colorForTheme:SVRThemeColorSolution
                                                 withStyle:XPUserInterfaceStyleLight]];
  // Time Text Field
  [_fieldTime setStringValue:[NSString stringWithFormat:@"%.1f", [ud SVR_waitTimeForRendering]]];
  
  // Configure Math Text Font Field
  currentFont = [ud SVR_fontForTheme:SVRThemeFontMath];
  [currentFontAttribs setObject:currentFont forKey:NSFontAttributeName];
  currentFontString = [[[NSAttributedString alloc] initWithString:[self __descriptionForFont:currentFont]
                                                       attributes:currentFontAttribs] autorelease];
  [_fieldTextMath setAttributedStringValue:currentFontString];
  
  // Configure Other Text Font Field
  currentFont = [ud SVR_fontForTheme:SVRThemeFontOther];
  [currentFontAttribs setObject:currentFont forKey:NSFontAttributeName];
  currentFontString = [[[NSAttributedString alloc] initWithString:[self __descriptionForFont:currentFont]
                                                       attributes:currentFontAttribs] autorelease];
  [_fieldTextOther setAttributedStringValue:currentFontString];
  
  // Configure Error Text Font Field
  currentFont = [ud SVR_fontForTheme:SVRThemeFontError];
  [currentFontAttribs setObject:currentFont forKey:NSFontAttributeName];
  currentFontString = [[[NSAttributedString alloc] initWithString:[self __descriptionForFont:currentFont]
                                                       attributes:currentFontAttribs] autorelease];
  [_fieldTextError setAttributedStringValue:currentFontString];
}

-(NSString*)__descriptionForFont:(NSFont*)font;
{
  return [NSString stringWithFormat:@"%@ - %.1f", [font displayName], [font pointSize]];
}

-(void)choiceChanged:(NSPopUpButton*)sender;
{
  NSView *contentView = [_window contentView];
  XPInteger selection = (sender) ? [sender indexOfSelectedItem] : 0;
      
  [_groupFontView removeFromSuperview];
  [_groupColorView removeFromSuperview];
  [_groupGeneralView removeFromSuperview];
  
  switch (selection) {
    case 0: // General
      [contentView addSubview:_groupGeneralView];
      break;
    case 1: // Colors
      [contentView addSubview:_groupColorView];
      break;
    case 2: // Fonts
      [contentView addSubview:_groupFontView];
      break;
    default:
      return;
  }
}

-(IBAction)themeChanged:(NSPopUpButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle newStyle = [sender indexOfSelectedItem];
  switch (newStyle) {
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleDark:
      [ud SVR_setUserInterfaceStyleSetting:newStyle];
      break;
    default:
      XPLogAssrt1(NO, @"XPUserInterfaceStyle(%d)", (int)newStyle);
      break;
  }
}

-(IBAction)colorChanged:(NSColorWell*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRThemeColor color = -2;
  XPUserInterfaceStyle style = -2;
  NSColor *wellColor = [sender color];
  BOOL decoded = [self decodeThemeColor:&color
                         interfaceStyle:&style
                          fromColorWell:sender];
  XPLogAssrt(decoded, @"[FAIL] decodeThemeColor:interfaceStyle:fromColorWell:");
  [ud SVR_setColor:wellColor forTheme:color withStyle:style];
}

-(IBAction)timeChanged:(NSTextField*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPFloat userTime = [sender floatValue];
  XPFloat newUDTime;
  [ud SVR_setWaitTimeForRendering:userTime];
  newUDTime = [ud SVR_waitTimeForRendering];
  if (userTime != newUDTime) {
    [sender setTextColor:[ud SVR_colorForTheme:SVRThemeColorErrorText]];
    NSBeep();
  } else {
    [sender setTextColor:[NSColor controlTextColor]];
  }
}

-(IBAction)fontChangeRequest:(NSButton*)sender;
{
  BOOL decoded = NO;
  SVRThemeFont theme = -1;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRFontManager *fm = (SVRFontManager*)[NSFontManager sharedFontManager];
  XPLogAssrt1([fm isKindOfClass:[SVRFontManager class]], @"%@ is not SVRFontManager", fm);
  decoded = [self decodeThemeFont:&theme fromButton:sender];
  XPLogAssrt(decoded, @"[FAIL] decodeThemFont:fromButton:");
  [fm setSelectedFont:[ud SVR_fontForTheme:theme] isMultiple:NO];
  [fm setThemeFont:theme];
  [fm orderFrontFontPanel:sender];
}

-(IBAction)changeFont:(NSFontManager*)sender;
{
  NSFont *font = nil;
  SVRThemeFont theme = -1;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if (![sender isKindOfClass:[SVRFontManager class]]) { XPLogRaise(@""); return; }
  font = [sender convertFont:[sender selectedFont]];
  theme = [(SVRFontManager*)sender themeFont];
  [ud SVR_setFont:font forTheme:theme];
  [[sender fontPanel:NO] performClose:sender];
  [self populateUI];
  XPLogDebug(@"");
}

-(IBAction)fontReset:(NSButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRThemeFont font = -2;
  BOOL decoded = [self decodeThemeFont:&font fromButton:sender];
  if (!decoded) { XPLogDebug1(@"fontReset:%@ Failed", sender); return; }
  [ud SVR_setFont:nil forTheme:font];
  [self populateUI];
  XPLogDebug(@"");
}

-(IBAction)colorReset:(NSButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRThemeColor color = -2;
  BOOL decoded = [self decodeThemeColor:&color fromResetButton:sender];
  if (!decoded) { XPLogDebug1(@"colorReset:%@ Failed", sender); return; }
  [ud SVR_setColor:nil forTheme:color withStyle:XPUserInterfaceStyleLight];
  [ud SVR_setColor:nil forTheme:color withStyle:XPUserInterfaceStyleDark];
  [self populateUI];
  XPLogDebug(@"");
}

-(IBAction)timeReset:(NSButton*)sender;
{
  [_fieldTime setTextColor:[NSColor controlTextColor]];
  [[NSUserDefaults standardUserDefaults] SVR_setWaitTimeForRendering:-1];
  [self populateUI];
  XPLogDebug(@"");
}

-(BOOL)decodeThemeColor:(SVRThemeColor*)colorPointer
         interfaceStyle:(XPUserInterfaceStyle*)stylePointer
          fromColorWell:(NSColorWell*)sender;
{
  // See configureWellTags for more info about this bitwise packing
  short int packed = (short int)[sender tag];
  SVRThemeColor color = packed & 0xFF;
  XPUserInterfaceStyle style = (packed >> 8) & 0xFF;
  
  // Set Defaults for Failure
  *colorPointer = -1;
  *stylePointer = -1;
  
  // Do basic validation of the received values
  switch (color) {
    case SVRThemeColorOperandText:
    case SVRThemeColorOperatorText:
    case SVRThemeColorSolution:
    case SVRThemeColorSolutionSecondary:
    case SVRThemeColorErrorText:
    case SVRThemeColorOtherText:
    case SVRThemeColorBackground:
    case SVRThemeColorInsertionPoint:
      *colorPointer = color;
      break;
    default:
      return NO;
  }
  switch (style) {
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleDark:
      *stylePointer = style;
      break;
    case XPUserInterfaceStyleUnspecified:
    default:
      return NO;
  }
  return YES;
}

-(BOOL)decodeThemeColor:(SVRThemeColor*)colorPointer
        fromResetButton:(NSButton*)sender;
{
  SVRThemeColor tag = [sender tag];
  switch (tag) {
    case SVRThemeColorOperandText:
    case SVRThemeColorOperatorText:
    case SVRThemeColorSolution:
    case SVRThemeColorSolutionSecondary:
    case SVRThemeColorErrorText:
    case SVRThemeColorOtherText:
    case SVRThemeColorBackground:
    case SVRThemeColorInsertionPoint:
      *colorPointer = tag;
      return YES;
    default:
      *colorPointer = -1;
      return NO;
  }
}

-(BOOL)decodeThemeFont:(SVRThemeFont*)fontPointer
            fromButton:(NSButton*)sender;
{
  SVRThemeFont tag = [sender tag];
  switch (tag) {
    case SVRThemeFontOther:
    case SVRThemeFontMath:
    case SVRThemeFontError:
      *fontPointer = tag;
      return YES;
    default:
      *fontPointer = -1;
      return NO;
  }
}

-(void)dealloc;
{
  XPLogExtra1(@"%p", self);
  [_groupGeneralView release];
  [_groupColorView release];
  [_groupFontView release];
  _groupFontView = nil;
  _groupColorView = nil;
  _groupGeneralView = nil;
  _window = nil;
  _wellDarkBackground = nil;
  _wellDarkError = nil;
  _wellDarkInsertionPoint = nil;
  _wellDarkOperand = nil;
  _wellDarkOperator = nil;
  _wellDarkOther = nil;
  _wellDarkPrevious = nil;
  _wellDarkSolution = nil;
  _wellLightBackground = nil;
  _wellLightError = nil;
  _wellLightInsertionPoint = nil;
  _wellLightOperand = nil;
  _wellLightOperator = nil;
  _wellLightOther = nil;
  _wellLightPrevious = nil;
  _wellLightSolution = nil;
  _fieldTime = nil;
  _fieldTextMath = nil;
  _fieldTextOther = nil;
  _fieldTextError = nil;
  _popUpTheme = nil;
  [super dealloc];
}

@end
