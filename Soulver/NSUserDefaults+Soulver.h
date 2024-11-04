/* NSUserDefaults+Soulver.h created by me on Sat 12-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

typedef enum {
  SVRThemeColorOperand = 0,
  SVRThemeColorOperator = 1,
  SVRThemeColorBracket = 2,
  SVRThemeColorSolution = 3,
  SVRThemeColorSolutionSecondary = 4,
  SVRThemeColorErrorText = 5,
  SVRThemeColorOtherText = 6,
  SVRThemeColorBackground = 7,
  SVRThemeColorInsertionPoint = 8
} SVRThemeColor;

typedef enum {
  SVRThemeFontOther = 0,
  SVRThemeFontMath = 1,
  SVRThemeFontError = 2
} SVRThemeFont;

typedef enum {
  SVRAccessoryWindowSettings = 0,
  SVRAccessoryWindowAbout = 1,
  SVRAccessoryWindowKeypad = 2,
  SVRAccessoryWindowNone = 3
} SVRAccessoryWindow;

@interface NSUserDefaults (Soulver)
// MARK: Basics
-(NSString*)SVR_savePanelLastDirectory;
-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
-(NSTimeInterval)SVR_waitTimeForRendering;
-(BOOL)SVR_setWaitTimeForRendering:(NSTimeInterval)newValue;
-(XPLocale*)SVR_decimalNumberLocale;

// MARK: Accessory Window Visibility
+(NSString*)SVR_frameKeyForWindow:(SVRAccessoryWindow)window;
-(BOOL)SVR_visibilityForWindow:(SVRAccessoryWindow)window;
-(BOOL)SVR_setVisibility:(BOOL)isVisible forWindow:(SVRAccessoryWindow)window;

// MARK: Theming
-(XPUserInterfaceStyle)SVR_userInterfaceStyle;
-(BOOL)SVR_setUserInterfaceStyle:(XPUserInterfaceStyle)style;
-(NSColor*)SVR_colorForTheme:(SVRThemeColor)theme;
-(NSColor*)SVR_colorForTheme:(SVRThemeColor)theme
                   withStyle:(XPUserInterfaceStyle)style;
-(BOOL)SVR_setColor:(NSColor*)color
           forTheme:(SVRThemeColor)theme
          withStyle:(XPUserInterfaceStyle)style;
-(NSFont*)SVR_fontForTheme:(SVRThemeFont)theme;
-(BOOL)SVR_setFont:(NSFont*)font
          forTheme:(SVRThemeFont)theme;
-(NSString*)__SVR_keyForThemeColor:(SVRThemeColor)theme
                         withStyle:(XPUserInterfaceStyle)style;
-(NSString*)__SVR_keyForThemeFont:(SVRThemeFont)theme;

// MARK: Configuration
-(void)SVR_configure;
+(NSDictionary*)__SVR_standardDictionary;
+(XPLocale*)__SVR_legacyDecimalNumberLocale;
@end
