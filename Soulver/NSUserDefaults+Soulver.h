/* NSUserDefaults+Soulver.h created by me on Sat 12-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

// TODO: Implement from here ---->
typedef enum SVRThemeTarget: XPInteger {
  SVRThemeTargetOperand,
  SVRThemeTargetOperator,
  SVRThemeTargetBracket,
  SVRThemeTargetSolution,
  SVRThemeTargetSolutionSecondary,
  SVRThemeTargetOther,
  SVRThemeTargetBackground
} SVRThemeTarget;

@interface SVRTheme: NSObject
{
  NSUserDefaults *_ud;
  XPUserInterfaceStyle _style;
}

+(id)currentTheme;
-(XPColor*)colorForTarget:(SVRThemeTarget)target;
-(BOOL)setColor:(XPColor*)color forTarget:(SVRThemeTarget)target;
-(NSFont*)fontForTarget:(SVRThemeTarget)target;
-(BOOL)setFont:(NSFont*)font forTarget:(SVRThemeTarget)target;

@end

typedef enum SVRAccessoryWindow: XPInteger {
  SVRAccessoryWindowSettings,
  SVRAccessoryWindowAbout,
  SVRAccessoryWindowKeypad
} SVRAccessoryWindow;

@interface NSUserDefaults (Soulver)
-(NSString*)SVR_frameKeyForWindow:(SVRAccessoryWindow)window;
-(NSString*)SVR_visibilityForWindow:(SVRAccessoryWindow)window;
-(BOOL)SVR_setVisibility:(BOOL)isVisible forWindow:(SVRAccessoryWindow)window;
// TODO: To here <---------

-(NSString*)SVR_savePanelLastDirectory;
-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
-(XPColor*)SVR_colorForSolutionPrimary;
-(BOOL)SVR_setColorForSolutionPrimary:(XPColor*)newValue;
-(XPColor*)SVR_colorForSolutionSecondary;
-(BOOL)SVR_setColorForSolutionSecondary:(XPColor*)newValue;
-(XPColor*)SVR_colorForError;
-(BOOL)SVR_setColorForError:(XPColor*)newValue;
-(XPColor*)SVR_colorForBracket;
-(BOOL)SVR_setColorForBracket:(XPColor*)newValue;
-(XPColor*)SVR_colorForOperator;
-(BOOL)SVR_setColorForOperator:(XPColor*)newValue;
-(XPColor*)SVR_colorForNumeral;
-(BOOL)SVR_setColorForNumeral:(XPColor*)newValue;
-(XPColor*)SVR_colorForText;
-(BOOL)SVR_setColorForText:(XPColor*)newValue;
-(NSFont*)SVR_fontForText;
-(BOOL)SVR_setFontForText:(NSFont*)newValue;
-(BOOL)SVR_settingsWindowVisible;
-(BOOL)SVR_setSettingsWindowVisible:(BOOL)isVisible;
-(BOOL)SVR_aboutWindowVisible;
-(BOOL)SVR_setAboutWindowVisible:(BOOL)isVisible;
-(BOOL)SVR_keypadPanelVisible;
-(BOOL)SVR_setKeypadPanelVisible:(BOOL)isVisible;
-(NSTimeInterval)SVR_waitTimeForRendering;
-(BOOL)SVR_setWaitTimeForRendering:(NSTimeInterval)newValue;
-(XPLocale*)SVR_decimalNumberLocale;
-(void)SVR_configure;
// MARK: Private
+(NSDictionary*)__SVR_standardDictionary;
+(XPLocale*)__SVR_legacyDecimalNumberLocale;
@end
