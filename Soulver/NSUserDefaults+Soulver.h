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

typedef XP_ENUM(XPInteger, SVRSettingSelection) {
  SVRSettingSelectionGeneral = 0,
  SVRSettingSelectionColors = 1,
  SVRSettingSelectionFonts = 2,
};

typedef XP_ENUM(XPInteger, SVRThemeColor) {
  SVRThemeColorOperandText = 0,
  SVRThemeColorOperatorText = 1,
  SVRThemeColor_UNUSED_ = 2,
  SVRThemeColorSolution = 3,
  SVRThemeColorSolutionSecondary = 4,
  SVRThemeColorErrorText = 5,
  SVRThemeColorOtherText = 6,
  SVRThemeColorBackground = 7,
  SVRThemeColorInsertionPoint = 8
};

typedef XP_ENUM(XPInteger, SVRThemeFont) {
  SVRThemeFontUnknown = 0,
  SVRThemeFontMath = 1,
  SVRThemeFontOther = 2,
  SVRThemeFontError = 3
};

@interface NSUserDefaults (Soulver)

// MARK: Basics
-(NSString*)SVR_savePanelLastDirectory;
-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
-(NSTimeInterval)SVR_waitTimeForRendering;
-(BOOL)SVR_setWaitTimeForRendering:(NSTimeInterval)newValue;

// MARK: Accessory Window Visibility
-(SVRSettingSelection)SVR_settingsSelection;
-(BOOL)SVR_setSettingsSelection:(SVRSettingSelection)newValue;
-(BOOL)SVR_visibilityForWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;
-(BOOL)SVR_setVisibility:(BOOL)isVisible forWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;

// MARK: Theming
-(void)__postChangeNotification;
/// Returns the preference for user interface style (this should only be used by the settings window)
-(XPUserInterfaceStyle)SVR_userInterfaceStyleSetting;
-(BOOL)SVR_setUserInterfaceStyleSetting:(XPUserInterfaceStyle)style;
/// Returns the apparant user interface style
-(XPUserInterfaceStyle)SVR_userInterfaceStyle;
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
+(NSString*)titleAbout;
+(NSString*)titleKeypad;
+(NSString*)titleSettings;
+(NSString*)titleGeneral;
+(NSString*)titleColors;
+(NSString*)titleFonts;
+(NSString*)titleAutomatic;
+(NSString*)titleLight;
+(NSString*)titleDark;
+(NSString*)titleTheme;
+(NSString*)titleSolvingDelay;
+(NSString*)titleMathText;
+(NSString*)titleNormalText;
+(NSString*)titleErrorText;
+(NSString*)titleOperand;
+(NSString*)titleOperator;
+(NSString*)titleSolution;
+(NSString*)titleCarryover;
+(NSString*)titleInsertionPoint;
+(NSString*)titleBackground;
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
+(NSString*)phraseAboutTagline;
+(NSString*)phraseAboutDedication;
+(NSString*)aboutParagraph;
+(NSString*)verbSet;
+(NSString*)verbReset;
+(NSString*)verbViewSource;
+(NSString*)verbReviewUnsaved;
+(NSString*)verbQuitAnyway;
+(NSString*)verbCancel;
+(NSString*)verbSave;
+(NSString*)verbRevert;
+(NSString*)verbDontSave;
+(NSString*)verbCopyToClipboard;
+(NSString*)verbDontCopy;
+(NSString*)imageAboutPortrait;
+(NSString*)imageNeXTLogo;
+(NSString*)imageNeXTTagline;
+(NSString*)imageThemeAuto;
+(NSString*)imageThemeLight;
+(NSString*)imageThemeDark;
+(NSString*)menuAppAbout;
+(NSString*)menuAppSettings;
+(NSString*)menuAppServices;
+(NSString*)menuAppHideSelf;
+(NSString*)menuAppHideOthers;
+(NSString*)menuAppShowAll;
+(NSString*)menuAppQuit;
+(NSString*)menuAppHideLegacy;
+(NSString*)menuAppQuitLegacy;
+(NSString*)menuAppInfoLegacy;
+(NSString*)menuHelp;
+(NSString*)menuFile;
+(NSString*)menuFileNew;
+(NSString*)menuFileOpen;
+(NSString*)menuFileClose;
+(NSString*)menuFileSave;
+(NSString*)menuFileSaveAll;
+(NSString*)menuFileDuplicate;
+(NSString*)menuFileSaveAs;
+(NSString*)menuFileRename;
+(NSString*)menuFileMoveTo;
+(NSString*)menuFileRevertTo;
+(NSString*)menuFileLastSavedVersion;
+(NSString*)menuFileBrowseAllVersions;
+(NSString*)menuEdit;
+(NSString*)menuEditUndo;
+(NSString*)menuEditRedo;
+(NSString*)menuEditCut;
+(NSString*)menuEditCopy;
+(NSString*)menuEditCutUnsolved;
+(NSString*)menuEditCopyUnsolved;
+(NSString*)menuEditPaste;
+(NSString*)menuEditDelete;
+(NSString*)menuEditSelectAll;
+(NSString*)menuEditFind;
+(NSString*)menuEditFindNext;
+(NSString*)menuEditFindPrevious;
+(NSString*)menuEditFindUseSelection;
+(NSString*)menuEditFindScroll;
+(NSString*)menuEditSpelling;
+(NSString*)menuEditSpellingShow;
+(NSString*)menuEditSpellingCheckNow;
+(NSString*)menuEditSpellingCheckWhileTyping;
+(NSString*)menuEditSpellingCheckGrammar;
+(NSString*)menuEditSpellingAutoCorrect;
+(NSString*)menuEditSubstitutions;
+(NSString*)menuEditSubstitutionsShow;
+(NSString*)menuEditSubstitutionsSmartCopyPaste;
+(NSString*)menuEditSubstitutionsSmartQuotes;
+(NSString*)menuEditSubstitutionsSmartDashes;
+(NSString*)menuEditSubstitutionsSmartLinks;
+(NSString*)menuEditSubstitutionsDataDetectors;
+(NSString*)menuEditSubstitutionsTextReplacements;
+(NSString*)menuEditTransformations;
+(NSString*)menuEditTransformationsUpperCase;
+(NSString*)menuEditTransformationsLowerCase;
+(NSString*)menuEditTransformationsCapitalize;
+(NSString*)menuEditSpeech;
+(NSString*)menuEditSpeechStart;
+(NSString*)menuEditSpeechStop;
+(NSString*)menuView;
+(NSString*)menuViewActualSize;
+(NSString*)menuViewZoomIn;
+(NSString*)menuViewZoomOut;
+(NSString*)menuWindow;
+(NSString*)menuWindowShowKeypad;

+(BOOL)respondsToSelector:(SEL)aSelector;
@end

@interface LocalizedProxy: NSProxy
+(LocalizedProxy*)sharedProxy;
-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
-(void)forwardInvocation:(NSInvocation*)invocation;
@end
