#import "SVRSettingsViewController.h"

@implementation SVRSettingsViewController

-(void)awakeFromNib;
{
  [_groupFontView retain];
  [_groupColorView retain];
  [_groupGeneralView retain];
  
  [self choiceChanged:_settingsChooser];
  NSLog(@"%@ awakeFromNib", self);
}

-(void)choiceChanged:(NSPopUpButton*)sender;
{
  NSView *contentView = [_window contentView];
  XPInteger selection = [sender indexOfSelectedItem];
  
  [XPLog debug:@"choiceChanged:%@(%ld)", sender, selection];
  
  return;
  
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

-(IBAction)fontChangeRequest:(NSButton*)sender;
{
  NSLog(@"fontChangeRequest:%@", sender);
}

-(IBAction)colorChanged:(NSColorWell*)sender;
{
  NSLog(@"colorChanged:%@", sender);
}

-(IBAction)timeChanged:(NSTextField*)sender;
{
  NSLog(@"timeChanged:%@", sender);
}

-(IBAction)themeChanged:(NSPopUpButton*)sender;
{
  NSLog(@"themeChanged:%@", sender);
}

-(IBAction)fontReset:(NSButton*)sender;
{
  NSLog(@"fontReset:%@", sender);
}

-(IBAction)colorReset:(NSButton*)sender;
{
  NSLog(@"colorReset:%@", sender);
}

-(IBAction)timeReset:(NSButton*)sender;
{
  NSLog(@"timeReset:%@", sender);
}

-(BOOL)themeColor:(SVRThemeColor*)colorPointer
   interfaceStyle:(XPUserInterfaceStyle*)stylePointer
     forColorWell:(NSColorWell*)sender;
{
  *colorPointer = -2;
  *stylePointer = -2;
  
  if        (sender == _wellDarkBackground) {
    *colorPointer = SVRThemeColorBackground;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellDarkInsertionPoint) {
    *colorPointer = SVRThemeColorInsertionPoint;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellDarkOperand) {
    *colorPointer = SVRThemeColorOperand;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellDarkOperator) {
    *colorPointer = SVRThemeColorOperator;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellDarkOther) {
    *colorPointer = SVRThemeColorOtherText;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellDarkParenthesis) {
    *colorPointer = SVRThemeColorBracket;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellDarkSolution) {
    *colorPointer = SVRThemeColorSolution;
    *stylePointer = XPUserInterfaceStyleDark;
    return YES;
  } else if (sender == _wellLightBackground) {
    *colorPointer = SVRThemeColorBackground;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightError) {
    *colorPointer = SVRThemeColorErrorText;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightInsertionPoint) {
    *colorPointer = SVRThemeColorInsertionPoint;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightOperand) {
    *colorPointer = SVRThemeColorOperand;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightOperator) {
    *colorPointer = SVRThemeColorOperator;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightOther) {
    *colorPointer = SVRThemeColorOtherText;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightParenthesis) {
    *colorPointer = SVRThemeColorBracket;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  } else if (sender == _wellLightSolution) {
    *colorPointer = SVRThemeColorSolution;
    *stylePointer = XPUserInterfaceStyleLight;
    return YES;
  }
  return NO;
}

-(BOOL)themeFont:(SVRThemeFont*)fontPointer
       forButton:(NSButton*)sender;
{
  return NO;
}

@end
