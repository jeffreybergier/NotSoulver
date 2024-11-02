#import <AppKit/AppKit.h>

@interface SVRSettingsViewController: NSResponder
{
  id _groupGeneralView;
  id _groupColorView;
  id _groupFontView;
  id _settingsChooser;
  id _wellDarkBackground;
  id _wellDarkInsertionPoint;
  id _wellDarkOperand;
  id _wellDarkOperator;
  id _wellDarkOther;
  id _wellDarkParenthesis;
  id _wellDarkSolution;
  id _wellLightBackground;
  id _wellLightError;
  id _wellLightInsertionPoint;
  id _wellLightOperand;
  id _wellLightOperator;
  id _wellLightOther;
  id _wellLightParenthesis;
  id _wellLightSolution;
}
-(void)choiceChanged:(id)sender;
-(void)valueChanged:(id)sender;
-(void)valueReset:(id)sender;

@end
