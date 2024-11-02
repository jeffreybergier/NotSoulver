#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

@interface SVRSettingsViewController: NSResponder
{
  mm_unretain IBOutlet NSWindow  *_window;
  mm_retain   IBOutlet NSView    *_groupGeneralView;
  mm_retain   IBOutlet NSView    *_groupColorView;
  mm_retain   IBOutlet NSView    *_groupFontView;
  mm_unretain IBOutlet NSControl *_settingsChooser;
  mm_unretain IBOutlet NSControl *_wellDarkBackground;
  mm_unretain IBOutlet NSControl *_wellDarkInsertionPoint;
  mm_unretain IBOutlet NSControl *_wellDarkOperand;
  mm_unretain IBOutlet NSControl *_wellDarkOperator;
  mm_unretain IBOutlet NSControl *_wellDarkOther;
  mm_unretain IBOutlet NSControl *_wellDarkParenthesis;
  mm_unretain IBOutlet NSControl *_wellDarkSolution;
  mm_unretain IBOutlet NSControl *_wellLightBackground;
  mm_unretain IBOutlet NSControl *_wellLightError;
  mm_unretain IBOutlet NSControl *_wellLightInsertionPoint;
  mm_unretain IBOutlet NSControl *_wellLightOperand;
  mm_unretain IBOutlet NSControl *_wellLightOperator;
  mm_unretain IBOutlet NSControl *_wellLightOther;
  mm_unretain IBOutlet NSControl *_wellLightParenthesis;
  mm_unretain IBOutlet NSControl *_wellLightSolution;
}

-(void)awakeFromNib;
-(IBAction)choiceChanged:(NSControl*)sender;
-(IBAction)valueChanged:(NSControl*)sender;
-(IBAction)valueReset:(NSControl*)sender;



@end
