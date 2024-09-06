/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "SVRCrossPlatform.h"

@implementation XPLog

+(void)always:(NSString*)formatString, ...;
{
  va_list args;
  va_start(args, formatString);
  NSLog(formatString, args);
  va_end(args);
}

+(void)debug:(NSString*)formatString, ...;
{
#if DEBUG
  va_list args;
  va_start(args, formatString);
  NSLog(formatString, args);
  va_end(args);
#endif
}

+(void)pause:(NSString*)formatString, ...;
{
#if DEBUG
  va_list args;
  va_start(args, formatString);
  NSLog(formatString, args);
  va_end(args);
#endif
}

+(void)excess:(NSString*)formatString, ...;
{
#if DEBUG && EXCESS
  va_list args;
  va_start(args, formatString);
  NSLog(formatString, args);
  va_end(args);
#endif
}
@end
