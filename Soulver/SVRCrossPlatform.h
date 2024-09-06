/* SVRCrossPlatform.h created by me on Fri 06-Sep-2024 */

#import <AppKit/AppKit.h>

/// MARK: Simple Typedefs
#if OS_OPENSTEP
typedef int XPInteger;
typedef uint XPUInteger;
#else
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
#endif

@interface XPLog: NSObject
/// Always does an NSLog
+(void)always:(NSString*)formatString, ...;
/// NSLog when in DEBUG
+(void)debug:(NSString*)formatString, ...;
/// NSLog when in DEBUG and also pauses debugger
/// Requires `fb [XPLog pause]` in GDB
+(void)pause:(NSString*)formatString, ...;
/// NSLog only when DEBUG and EXCESS flag found
/// Requires `-DEXCESS` CFLAG option in GCC
+(void)excess:(NSString*)formatString, ...;
@end
