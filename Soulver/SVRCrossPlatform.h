/* SVRCrossPlatform.h created by me on Fri 06-Sep-2024 */

#import <AppKit/AppKit.h>

/// MARK: Simple Typedefs
#if OS_OPENSTEP
typedef int XPInteger;
typedef unsigned int XPUInteger;
#else
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
#endif

@interface XPLog: NSObject
/// Always does an NSLog
+(void)alwys:(NSString*)formatString, ...;
/// NSLog when in DEBUG
+(void)debug:(NSString*)formatString, ...;
/// NSLog only when DEBUG and EXCESS flag found
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
