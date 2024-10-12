/* NSUserDefaults+Soulver.h created by me on Sat 12-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

@interface NSUserDefaults (Soulver)
-(NSString*)SVR_savePanelLastDirectory;
-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
-(XPColor*)SVR_colorForSolutionPrimary;
-(BOOL)SVR_setColorForSolutionPrimary:(XPColor*)newValue;
-(XPColor*)SVR_backgroundColorForSolutionPrimary;
-(BOOL)SVR_setBackgroundColorForSolutionPrimary:(XPColor*)newValue;
-(XPColor*)SVR_colorForSolutionSecondary;
-(BOOL)SVR_setColorForSolutionSecondary:(XPColor*)newValue;
-(XPColor*)SVR_colorForBracket;
-(BOOL)SVR_setColorForBracket:(XPColor*)newValue;
-(XPColor*)SVR_colorForOperator;
-(BOOL)SVR_setColorForOperator:(XPColor*)newValue;
-(XPColor*)SVR_colorForNumeral;
-(BOOL)SVR_setColorForNumeral:(XPColor*)newValue;
-(XPColor*)SVR_colorForText;
-(BOOL)SVR_setColorForText:(XPColor*)newValue;
// TODO: These are fake and not stored in UserDefaults
-(NSFont*)SVR_fontForText;
-(BOOL)SVR_setFontForText:(NSFont*)newValue;
-(NSDictionary*)SVR_operatorDecodeMap;
-(NSDictionary*)SVR_operatorEncodeMap;
-(NSNumber*)SVR_errorMismatchedBrackets;
-(NSNumber*)SVR_errorInvalidCharacter;
-(NSNumber*)SVR_errorMissingNumber;
-(NSNumber*)SVR_errorPatching;
-(XPLocale*)SVR_decimalNumberLocale;
-(void)SVR_configure;
// MARK: Private
+(NSDictionary*)__SVR_standardDictionary;
+(XPLocale*)__SVR_legacyDecimalNumberLocale;
+(NSDictionary*)__SVR_standardOperatorDecodeMap;
+(NSDictionary*)__SVR_standardOperatorEncodeMap;
@end
