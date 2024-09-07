/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "SVRCrossPlatform.h"

@implementation XPLog

+(void)load;
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
  [XPLog alwys:@"ALWYS"];
  [XPLog debug:@"DEBUG"];
  [XPLog extra:@"EXTRA"];
  [XPLog pause:@"PAUSE"];
  [pool release];
}

+(void)alwys:(NSString*)formatString, ...;
{
  va_list args;
  NSString *newFormat;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  newFormat = [@"LOG-ALWYS: " stringByAppendingString:formatString];
  NSLogv(newFormat, args);
  va_end(args);
}

+(void)debug:(NSString*)formatString, ...;
{
#if DEBUG
  va_list args;
  NSString *newFormat;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  newFormat = [@"LOG-DEBUG: " stringByAppendingString:formatString];
  NSLogv(newFormat, args);
  va_end(args);
#endif
}

+(void)extra:(NSString*)formatString, ...;
{
#if DEBUG && EXTRA
  va_list args;
  NSString *newFormat;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  newFormat = [@"LOG-EXTRA: " stringByAppendingString:formatString];
  NSLogv(newFormat, args);
  va_end(args);
#endif
}

+(void)pause:(NSString*)formatString, ...;
{
#if DEBUG
  va_list args;
  NSString *newFormat;
  if (!formatString) { [self raise]; }
  va_start(args, formatString);
  newFormat = [@"LOG-PAUSE: " stringByAppendingString:formatString];
  NSLogv(newFormat, args);
  va_end(args);
#endif
}

+(void)raise;
{
  [NSException raise:@"XPLogExceptionMissingFormatString" format:@""];
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
