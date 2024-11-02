#import <AppKit/AppKit.h>
#import "NSUserDefaults+Soulver.h"
#import "XPCrossPlatform.h"

@interface SVRSettingsViewController: NSResponder
{
  mm_unretain IBOutlet NSWindow *_window;
  mm_retain   IBOutlet NSView   *_groupGeneralView;
  mm_retain   IBOutlet NSView   *_groupColorView;
  mm_retain   IBOutlet NSView   *_groupFontView;
  mm_unretain IBOutlet NSPopUpButton *_settingsChooser;
  mm_unretain IBOutlet NSColorWell *_wellDarkBackground;
  mm_unretain IBOutlet NSColorWell *_wellDarkInsertionPoint;
  mm_unretain IBOutlet NSColorWell *_wellDarkOperand;
  mm_unretain IBOutlet NSColorWell *_wellDarkOperator;
  mm_unretain IBOutlet NSColorWell *_wellDarkOther;
  mm_unretain IBOutlet NSColorWell *_wellDarkParenthesis;
  mm_unretain IBOutlet NSColorWell *_wellDarkSolution;
  mm_unretain IBOutlet NSColorWell *_wellLightBackground;
  mm_unretain IBOutlet NSColorWell *_wellLightError;
  mm_unretain IBOutlet NSColorWell *_wellLightInsertionPoint;
  mm_unretain IBOutlet NSColorWell *_wellLightOperand;
  mm_unretain IBOutlet NSColorWell *_wellLightOperator;
  mm_unretain IBOutlet NSColorWell *_wellLightOther;
  mm_unretain IBOutlet NSColorWell *_wellLightParenthesis;
  mm_unretain IBOutlet NSColorWell *_wellLightSolution;
}

-(void)awakeFromNib;

-(IBAction)choiceChanged:(NSPopUpButton*)sender;
-(IBAction)fontChangeRequest:(NSButton*)sender;
-(IBAction)colorChanged:(NSColorWell*)sender;
-(IBAction)timeChanged:(NSTextField*)sender;
-(IBAction)themeChanged:(NSPopUpButton*)sender;

-(IBAction)fontReset:(NSButton*)sender;
-(IBAction)colorReset:(NSButton*)sender;
-(IBAction)timeReset:(NSButton*)sender;

-(BOOL)themeColor:(SVRThemeColor*)colorPointer
   interfaceStyle:(XPUserInterfaceStyle*)stylePointer
     forColorWell:(NSColorWell*)sender;

-(BOOL)themeFont:(SVRThemeFont*)fontPointer
       forButton:(NSButton*)sender;


@end
