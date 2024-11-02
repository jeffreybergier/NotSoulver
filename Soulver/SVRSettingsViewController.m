#import "SVRSettingsViewController.h"

@implementation SVRSettingsViewController

-(void)awakeFromNib;
{
  [_groupFontView retain];
  [_groupColorView retain];
  [_groupGeneralView retain];
  
  [self choiceChanged:nil];
  [self populateUI];
  
  NSLog(@"%@ awakeFromNib", self);
}

-(void)populateUI;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  // Dark Theme Colors
  [_wellDarkBackground setColor:[ud SVR_colorForTheme:SVRThemeColorBackground
                                            withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkError setColor:[ud SVR_colorForTheme:SVRThemeColorErrorText
                                       withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkInsertionPoint setColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint
                                                withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkOperand setColor:[ud SVR_colorForTheme:SVRThemeColorOperand
                                         withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkOperator setColor:[ud SVR_colorForTheme:SVRThemeColorOperator
                                          withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkOther setColor:[ud SVR_colorForTheme:SVRThemeColorOtherText
                                       withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkParenthesis setColor:[ud SVR_colorForTheme:SVRThemeColorBracket
                                             withStyle:XPUserInterfaceStyleDark]];
  [_wellDarkSolution setColor:[ud SVR_colorForTheme:SVRThemeColorSolution
                                          withStyle:XPUserInterfaceStyleDark]];
  // Light Theme Colors
  [_wellLightBackground setColor:[ud SVR_colorForTheme:SVRThemeColorBackground
                                             withStyle:XPUserInterfaceStyleLight]];
  [_wellLightError setColor:[ud SVR_colorForTheme:SVRThemeColorErrorText
                                        withStyle:XPUserInterfaceStyleLight]];
  [_wellLightInsertionPoint setColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint
                                                 withStyle:XPUserInterfaceStyleLight]];
  [_wellLightOperand setColor:[ud SVR_colorForTheme:SVRThemeColorOperand
                                          withStyle:XPUserInterfaceStyleLight]];
  [_wellLightOperator setColor:[ud SVR_colorForTheme:SVRThemeColorOperator
                                           withStyle:XPUserInterfaceStyleLight]];
  [_wellLightOther setColor:[ud SVR_colorForTheme:SVRThemeColorOtherText
                                        withStyle:XPUserInterfaceStyleLight]];
  [_wellLightParenthesis setColor:[ud SVR_colorForTheme:SVRThemeColorBracket
                                              withStyle:XPUserInterfaceStyleLight]];
  [_wellLightSolution setColor:[ud SVR_colorForTheme:SVRThemeColorSolution
                                           withStyle:XPUserInterfaceStyleLight]];
  // Font Text Fields
  [_fieldTextMath setStringValue:[NSString stringWithFormat:@"%@",
    [self __descriptionForFont:[ud SVR_fontForTheme:SVRThemeFontMath]]]
  ];
  [_fieldTextOther setStringValue:[NSString stringWithFormat:@"%@",
    [self __descriptionForFont:[ud SVR_fontForTheme:SVRThemeFontOther]]]
  ];
  [_fieldTextError setStringValue:[NSString stringWithFormat:@"%@",
    [self __descriptionForFont:[ud SVR_fontForTheme:SVRThemeFontError]]]
  ];
  // Time Text Field
  [_fieldTime setStringValue:[NSString stringWithFormat:@"%.1f", [ud SVR_waitTimeForRendering]]];
}

-(NSString*)__descriptionForFont:(NSFont*)font;
{
  return [NSString stringWithFormat:@"%@ - %.1f", [font displayName], [font pointSize]];
}

-(void)choiceChanged:(NSPopUpButton*)sender;
{
  NSView *contentView = [_window contentView];
  XPInteger selection = (sender) ? [sender indexOfSelectedItem] : 0;
  
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

-(IBAction)themeChanged:(NSPopUpButton*)sender;
{
  NSLog(@"themeChanged:%@", sender);
}

-(IBAction)colorChanged:(NSColorWell*)sender;
{
  NSLog(@"colorChanged:%@", sender);
}

-(IBAction)timeChanged:(NSTextField*)sender;
{
  NSLog(@"timeChanged:%@", sender);
}

-(IBAction)fontChangeRequest:(NSButton*)sender;
{
  NSLog(@"fontChangeRequest:%@", sender);
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
        forSender:(id)sender;
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
       forSender:(id)sender;
{
  return NO;
}

-(void)dealloc;
{
  [XPLog debug:@"DEALLOC:%@", self];
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
  _wellDarkParenthesis = nil;
  _wellDarkSolution = nil;
  _wellLightBackground = nil;
  _wellLightError = nil;
  _wellLightInsertionPoint = nil;
  _wellLightOperand = nil;
  _wellLightOperator = nil;
  _wellLightOther = nil;
  _wellLightParenthesis = nil;
  _wellLightSolution = nil;
  _fieldTime = nil;
  _fieldTextMath = nil;
  _fieldTextOther = nil;
  _fieldTextError = nil;
  _popUpTheme = nil;
  [super dealloc];
}

@end
