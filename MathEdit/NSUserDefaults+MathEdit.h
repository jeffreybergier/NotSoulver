//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
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
-(NSString*)MATH_savePanelLastDirectory;
-(BOOL)MATH_setSavePanelLastDirectory:(NSString*)newValue;
-(NSTimeInterval)MATH_waitTimeForRendering;
-(BOOL)MATH_setWaitTimeForRendering:(NSTimeInterval)newValue;

// MARK: Accessory Window Visibility
-(SVRSettingSelection)MATH_settingsSelection;
-(BOOL)MATH_setSettingsSelection:(SVRSettingSelection)newValue;
-(BOOL)MATH_visibilityForWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;
-(BOOL)MATH_setVisibility:(BOOL)isVisible forWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;

// MARK: Theming
-(void)__postChangeNotification;
/// Returns the preference for user interface style (this should only be used by the settings window)
-(XPUserInterfaceStyle)MATH_userInterfaceStyleSetting;
-(BOOL)MATH_setUserInterfaceStyleSetting:(XPUserInterfaceStyle)style;
/// Returns the apparant user interface style
-(XPUserInterfaceStyle)MATH_userInterfaceStyle;
-(NSColor*)MATH_colorForTheme:(SVRThemeColor)theme;
-(NSColor*)MATH_colorForTheme:(SVRThemeColor)theme
                    withStyle:(XPUserInterfaceStyle)style;
-(BOOL)MATH_setColor:(NSColor*)color
            forTheme:(SVRThemeColor)theme
           withStyle:(XPUserInterfaceStyle)style;
-(NSFont*)MATH_fontForTheme:(SVRThemeFont)theme;
-(BOOL)MATH_setFont:(NSFont*)font
           forTheme:(SVRThemeFont)theme;
-(NSString*)__MATH_keyForThemeColor:(SVRThemeColor)theme
                          withStyle:(XPUserInterfaceStyle)style;
-(NSString*)__MATH_keyForThemeFont:(SVRThemeFont)theme;

// MARK: Configuration
-(void)MATH_configure;
+(NSDictionary*)__MATH_standardDictionary;
@end

#ifdef AFF_ObjCNSMethodSignatureUndocumentedClassMethod
// TODO: HACK Silences Warning in OpenStep
// This method is not declared in the header in OpenStep
// but it does respond to this methid and it works fine.
// So this category method silences the warning.
@interface NSMethodSignature (CrossPlatform)
+(NSMethodSignature*)signatureWithObjCTypes:(const char*)types;
@end
#endif

#define Localized [LocalizedProxy sharedProxy]
@interface LocalizedProxy: NSProxy
+(LocalizedProxy*)sharedProxy;
-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
-(void)forwardInvocation:(NSInvocation*)invocation;
@end

@interface LocalizedProxy (LocalizedStringKey)
-(NSString*)titleAppName;
-(NSString*)titleQuit;
-(NSString*)titleUntitled;
-(NSString*)titleAlert;
-(NSString*)titleClose;
-(NSString*)titleAbout;
-(NSString*)titleKeypad;
-(NSString*)titleSettings;
-(NSString*)titleGeneral;
-(NSString*)titleColors;
-(NSString*)titleFonts;
-(NSString*)titleAutomatic;
-(NSString*)titleLight;
-(NSString*)titleDark;
-(NSString*)titleTheme;
-(NSString*)titleSolvingDelay;
-(NSString*)titleMathText;
-(NSString*)titleNormalText;
-(NSString*)titleErrorText;
-(NSString*)titleOperand;
-(NSString*)titleOperator;
-(NSString*)titleSolution;
-(NSString*)titleCarryover;
-(NSString*)titleInsertionPoint;
-(NSString*)titleBackground;
-(NSString*)phraseEditedWindows;
-(NSString*)phraseSaveChangesTo;
-(NSString*)phraseRevertChangesTo;
-(NSString*)phraseErrorInvalidCharacter;
-(NSString*)phraseErrorMismatchedBrackets;
-(NSString*)phraseErrorMissingOperand;
-(NSString*)phraseErrorDivideByZero;
-(NSString*)phraseErrorNaN;
-(NSString*)phraseErrorInfinite;
-(NSString*)phraseErrorImaginary;
-(NSString*)phraseErrorIndexZero;
-(NSString*)phraseErrorArgumentNegative;
-(NSString*)phraseErrorBaseNegative;
-(NSString*)phraseErrorBaseOne;
-(NSString*)phraseSourceRepositoryURL;
-(NSString*)phraseCopyWebURLToClipboard;
-(NSString*)phraseAboutTagline;
-(NSString*)phraseAboutDedication;
-(NSString*)phraseAboutParagraph;
-(NSString*)verbSet;
-(NSString*)verbReset;
-(NSString*)verbViewSource;
-(NSString*)verbReviewUnsaved;
-(NSString*)verbQuitAnyway;
-(NSString*)verbCancel;
-(NSString*)verbSave;
-(NSString*)verbRevert;
-(NSString*)verbDontSave;
-(NSString*)verbCopyToClipboard;
-(NSString*)verbDontCopy;
-(NSString*)imageAboutPortrait;
-(NSString*)imageNeXTLogo;
-(NSString*)imageNeXTTagline;
-(NSString*)imageThemeAuto;
-(NSString*)imageThemeLight;
-(NSString*)imageThemeDark;
-(NSString*)menuAppAbout;
-(NSString*)menuAppSettings;
-(NSString*)menuAppServices;
-(NSString*)menuAppHideSelf;
-(NSString*)menuAppHideOthers;
-(NSString*)menuAppShowAll;
-(NSString*)menuAppQuit;
-(NSString*)menuAppHideLegacy;
-(NSString*)menuAppQuitLegacy;
-(NSString*)menuAppInfoLegacy;
-(NSString*)menuHelp;
-(NSString*)menuFile;
-(NSString*)menuFileNew;
-(NSString*)menuFileOpen;
-(NSString*)menuFileClose;
-(NSString*)menuFileSave;
-(NSString*)menuFileSaveAll;
-(NSString*)menuFileDuplicate;
-(NSString*)menuFileSaveAs;
-(NSString*)menuFileRename;
-(NSString*)menuFileMoveTo;
-(NSString*)menuFileRevertTo;
-(NSString*)menuFileLastSavedVersion;
-(NSString*)menuFileBrowseAllVersions;
-(NSString*)menuEdit;
-(NSString*)menuEditUndo;
-(NSString*)menuEditRedo;
-(NSString*)menuEditCut;
-(NSString*)menuEditCopy;
-(NSString*)menuEditCutUnsolved;
-(NSString*)menuEditCopyUnsolved;
-(NSString*)menuEditPaste;
-(NSString*)menuEditDelete;
-(NSString*)menuEditSelectAll;
-(NSString*)menuEditFind;
-(NSString*)menuEditFindNext;
-(NSString*)menuEditFindPrevious;
-(NSString*)menuEditFindUseSelection;
-(NSString*)menuEditFindScroll;
-(NSString*)menuEditSpelling;
-(NSString*)menuEditSpellingShow;
-(NSString*)menuEditSpellingCheckNow;
-(NSString*)menuEditSpellingCheckWhileTyping;
-(NSString*)menuEditSpellingCheckGrammar;
-(NSString*)menuEditSpellingAutoCorrect;
-(NSString*)menuEditSubstitutions;
-(NSString*)menuEditSubstitutionsShow;
-(NSString*)menuEditSubstitutionsSmartCopyPaste;
-(NSString*)menuEditSubstitutionsSmartQuotes;
-(NSString*)menuEditSubstitutionsSmartDashes;
-(NSString*)menuEditSubstitutionsSmartLinks;
-(NSString*)menuEditSubstitutionsDataDetectors;
-(NSString*)menuEditSubstitutionsTextReplacements;
-(NSString*)menuEditTransformations;
-(NSString*)menuEditTransformationsUpperCase;
-(NSString*)menuEditTransformationsLowerCase;
-(NSString*)menuEditTransformationsCapitalize;
-(NSString*)menuEditSpeech;
-(NSString*)menuEditSpeechStart;
-(NSString*)menuEditSpeechStop;
-(NSString*)menuView;
-(NSString*)menuViewActualSize;
-(NSString*)menuViewZoomIn;
-(NSString*)menuViewZoomOut;
-(NSString*)menuWindow;
-(NSString*)menuWindowShowKeypad;
@end
