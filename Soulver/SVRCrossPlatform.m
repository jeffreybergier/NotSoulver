/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "SVRCrossPlatform.h"

@implementation XPLog

+(void)raise;
{
  [NSException raise:@"XPLogExceptionMissingFormatString" format:@""];
}

+(void)always:(NSString*)formatString, ...;
{
  va_list args;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  NSLogv(formatString, args);
  va_end(args);
}

+(void)debug:(NSString*)formatString, ...;
{
#if DEBUG
  va_list args;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  NSLogv(formatString, args);
  va_end(args);
#endif
}

+(void)pause:(NSString*)formatString, ...;
{
#if DEBUG
  va_list args;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  NSLogv(formatString, args);
  va_end(args);
#endif
}

+(void)excess:(NSString*)formatString, ...;
{
#if DEBUG && EXCESS
  va_list args;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  NSLogv(formatString, args);
  va_end(args);
#endif
}
@end

@implementation NSNumber (CrossPlatform)
+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
{
#if OS_OPENSTEP
  return [NSNumber numberWithInt:integer];
#else
  return [NSNumber numberWithInteger:integer];
#endif
}
@end
