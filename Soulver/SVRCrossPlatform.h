/* SVRCrossPlatform.h created by me on Fri 06-Sep-2024 */

#import <AppKit/AppKit.h>

/// MARK: Simple Typedefs
#if OS_OPENSTEP
typedef int XPInteger;
typedef unsigned int XPUInteger;
#define XPPasteboardTypeRTF NSRTFPboardType
#define XPRTFTextDocumentType @"NSRTF"
#define XPDocumentTypeDocumentAttribute @"NSDocumentType"
#else
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
#define XPPasteboardTypeRTF NSPasteboardTypeRTF
#define XPRTFTextDocumentType NSRTFTextDocumentType
#define XPDocumentTypeDocumentAttribute NSDocumentTypeDocumentAttribute
#endif

@interface XPLog: NSObject
/// Always does an NSLog
+(void)alwys:(NSString*)formatString, ...;
/// NSLog when in DEBUG or EXTRA flag found
+(void)debug:(NSString*)formatString, ...;
/// NSLog only when DEBUG and EXTRA flag found
/// Requires `-DEXTRA` CFLAG option in GCC
+(void)extra:(NSString*)formatString, ...;
/// Requires `fb +[XPLog pause:]` in GDB to Pause Debugger
+(void)pause:(NSString*)formatString, ...;
/// Raises an exception with format (crashes in production)
+(void)error:(NSString*)formatString, ...;
@end

@interface NSNumber (CrossPlatform)
+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
@end

#if OS_OPENSTEP
/// These match XPAlertButtonDefault
/// NSAlertDefaultReturn
typedef enum {
  XPAlertReturnDefault   = (XPInteger)1,
  XPAlertReturnAlternate = (XPInteger)0,
  XPAlertReturnOther     = (XPInteger)-1,
  XPAlertReturnError     = (XPInteger)-2
} XPAlertReturn;
#else
typedef NS_ENUM(XPInteger, XPAlertReturn) {
  XPAlertReturnDefault   =  1,
  XPAlertReturnAlternate =  0,
  XPAlertReturnOther     = -1,
  XPAlertReturnError     = -2
};
#endif

@interface XPAlert: NSObject

+(XPAlertReturn)runAppModalWithTitle:(NSString*)title
                             message:(NSString*)message
                       defaultButton:(NSString*)defaultButton
                     alternateButton:(NSString*)alternateButton
                         otherButton:(NSString*)otherButton;
/// Returns ENUM NSAlertDefaultReturn
+(XPAlertReturn)runSheetModalForWindow:(NSWindow*)window
                             withTitle:(NSString*)title
                               message:(NSString*)message
                         defaultButton:(NSString*)defaultButton
                       alternateButton:(NSString*)alternateButton
                           otherButton:(NSString*)otherButton;

@end

@interface XPSavePanel: NSObject
+(NSString*)lastDirectory;
+(void)setLastDirectory:(NSString*)lastDirectory;
/// Returns nil if user cancels
+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window;
/// Returns nil if user cancels
+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window
                                     withExistingFilename:(NSString*)filename;
@end

@interface XPOpenPanel: XPSavePanel
/// Returns empty array if user cancels
+(NSArray*)filenamesByRunningAppModalOpenPanel;
/// Returns empty array if user cancels
+(NSArray*)filenamesByRunningAppModalOpenPanelWithExistingFilename:(NSString*)filename;
@end

@interface NSUserDefaults (Soulver)
-(NSString*)savePanelLastDirectory;
-(BOOL)setSavePanelLastDirectory:(NSString*)newValue;
+(NSDictionary*)standardDictionary;
@end

@interface NSAttributedString (Pasteboard)
-(NSData*)SVR_pasteboardRepresentation;
@end

@interface NSPasteboard (Pasteboard)
-(void)SVR_configure;
-(BOOL)SVR_setAttributedString:(NSAttributedString*)aString;
@end
