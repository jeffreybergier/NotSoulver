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

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

extern NSString * const SVRThemeDidChangeNotificationName;

#ifdef NS_ENUM
typedef NS_ENUM(XPInteger, SVRThemeColor) {
  SVRThemeColorOperand = 0,
  SVRThemeColorOperator = 1,
  SVRThemeColorBracket = 2,
  SVRThemeColorSolution = 3,
  SVRThemeColorSolutionSecondary = 4,
  SVRThemeColorErrorText = 5,
  SVRThemeColorOtherText = 6,
  SVRThemeColorBackground = 7,
  SVRThemeColorInsertionPoint = 8
};
#else
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
#endif

#ifdef NS_ENUM
typedef NS_ENUM(XPInteger, SVRThemeFont) {
  SVRThemeFontOther = 0,
  SVRThemeFontMath = 1,
  SVRThemeFontError = 2
};
#else
typedef enum {
  SVRThemeFontOther = 0,
  SVRThemeFontMath = 1,
  SVRThemeFontError = 2
} SVRThemeFont;
#endif

#ifdef NS_ENUM
typedef NS_ENUM(XPInteger, SVRAccessoryWindow) {
  SVRAccessoryWindowSettings = 0,
  SVRAccessoryWindowAbout = 1,
  SVRAccessoryWindowKeypad = 2,
  SVRAccessoryWindowNone = 3
};
#else
typedef enum {
  SVRAccessoryWindowSettings = 0,
  SVRAccessoryWindowAbout = 1,
  SVRAccessoryWindowKeypad = 2,
  SVRAccessoryWindowNone = 3
} SVRAccessoryWindow;
#endif

@interface NSUserDefaults (Soulver)

// MARK: Get Right Instance
+(NSUserDefaults*)SVR_userDefaults;
+(NSUserDefaults*)__SVR_testingUserDefaults;

// MARK: Basics
-(NSString*)SVR_savePanelLastDirectory;
-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
-(NSTimeInterval)SVR_waitTimeForRendering;
-(BOOL)SVR_setWaitTimeForRendering:(NSTimeInterval)newValue;

// MARK: Accessory Window Visibility
+(NSString*)SVR_frameKeyForWindow:(SVRAccessoryWindow)window;
-(BOOL)SVR_visibilityForWindow:(SVRAccessoryWindow)window;
-(BOOL)SVR_setVisibility:(BOOL)isVisible forWindow:(SVRAccessoryWindow)window;

// MARK: Theming
-(void)__postChangeNotification;
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
@end

@interface Localized: NSObject
+(NSString*)titleAppName;
+(NSString*)titleQuit;
+(NSString*)titleUntitled;
+(NSString*)titleAlert;
+(NSString*)titleClose;
+(NSString*)phraseEditedWindows;
+(NSString*)phraseSaveChangesTo;
+(NSString*)phraseRevertChangesTo;
+(NSString*)phraseErrorInvalidCharacter;
+(NSString*)phraseErrorMismatchedBrackets;
+(NSString*)phraseErrorMissingOperand;
+(NSString*)phraseErrorDividByZero;
+(NSString*)phraseErrorNaN;
+(NSString*)phraseErrorInfinite;
+(NSString*)phraseErrorImaginary;
+(NSString*)phraseErrorIndexZero;
+(NSString*)phraseErrorArgumentNegative;
+(NSString*)phraseErrorBaseNegative;
+(NSString*)phraseErrorBaseOne;
+(NSString*)phraseSourceRepositoryURL;
+(NSString*)phraseCopyWebURLToClipboard;
+(NSString*)aboutParagraph;
+(NSString*)verbReviewUnsaved;
+(NSString*)verbQuitAnyway;
+(NSString*)verbCancel;
+(NSString*)verbSave;
+(NSString*)verbRevert;
+(NSString*)verbDontSave;
+(NSString*)verbCopyToClipboard;
+(NSString*)verbDontCopy;
@end
