#import <AppKit/AppKit.h>
#import "NSUserDefaults+Soulver.h"
#import "XPCrossPlatform.h"

@interface SVRSettingsViewController: NSResponder
{
  mm_unretain IBOutlet NSWindow *_window;
  mm_retain   IBOutlet NSView   *_groupGeneralView;
  mm_retain   IBOutlet NSView   *_groupColorView;
  mm_retain   IBOutlet NSView   *_groupFontView;
  mm_unretain IBOutlet NSColorWell *_wellDarkBackground;
  mm_unretain IBOutlet NSColorWell *_wellDarkError;
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
  mm_unretain IBOutlet NSTextField *_fieldTime;
  mm_unretain IBOutlet NSTextField *_fieldTextMath;
  mm_unretain IBOutlet NSTextField *_fieldTextOther;
  mm_unretain IBOutlet NSTextField *_fieldTextError;
  mm_unretain IBOutlet NSPopUpButton *_popUpTheme;
}

-(void)awakeFromNib;
-(void)configureWellTags;
-(void)populateUI;
-(NSString*)__descriptionForFont:(NSFont*)font;

-(IBAction)choiceChanged:(NSPopUpButton*)sender;
-(IBAction)themeChanged:(NSPopUpButton*)sender;
-(IBAction)colorChanged:(NSColorWell*)sender;
-(IBAction)timeChanged:(NSTextField*)sender;
-(IBAction)fontChangeRequest:(NSButton*)sender;
// FirstResponder message from NSFontManager
-(IBAction)changeFont:(NSFontManager*)sender;

-(IBAction)fontReset:(NSButton*)sender;
-(IBAction)colorReset:(NSButton*)sender;
-(IBAction)timeReset:(NSButton*)sender;

-(BOOL)decodeThemeColor:(SVRThemeColor*)colorPointer
         interfaceStyle:(XPUserInterfaceStyle*)stylePointer
          fromColorWell:(NSColorWell*)sender;

-(BOOL)decodeThemeColor:(SVRThemeColor*)colorPointer
        fromResetButton:(NSButton*)sender;

-(BOOL)decodeThemeFont:(SVRThemeFont*)fontPointer
            fromButton:(NSButton*)sender;


@end
