/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "SVRCrossPlatform.h"

@implementation XPLog

+(void)alwys:(NSString*)_formatString, ...;
{
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-ALWYS: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
}

+(void)debug:(NSString*)_formatString, ...;
{
#if DEBUG || EXTRA
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-DEBUG: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
#endif
}

+(void)extra:(NSString*)_formatString, ...;
{
#if DEBUG && EXTRA
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-EXTRA: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
#endif
}

+(void)pause:(NSString*)_formatString, ...;
{
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-PAUSE: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
}

+(void)error:(NSString*)_formatString, ...;
{
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO ERROR PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-ERROR: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  [NSException raise:@"SVRException" format:formatString arguments:args];
  va_end(args);
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

@implementation XPAlert

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wformat-security"
+(XPInteger)runAppModalWithTitle:(NSString*)title
                         message:(NSString*)message
                   defaultButton:(NSString*)defaultButton
                 alternateButton:(NSString*)alternateButton
                     otherButton:(NSString*)otherButton;
{
  return NSRunAlertPanel(title,
                         message,
                         defaultButton,
                         alternateButton,
                         otherButton);
}

+(XPInteger)runSheetModalForWindow:(NSWindow*)window
                         withTitle:(NSString*)title
                           message:(NSString*)message
                     defaultButton:(NSString*)defaultButton
                   alternateButton:(NSString*)alternateButton
                       otherButton:(NSString*)otherButton;
{
  // TODO: Implement hack to work with MacOSX
  // ChatGPT explains how, but I can't find a google link
  return NSRunAlertPanel(title,
                         message,
                         defaultButton,
                         alternateButton,
                         otherButton);
}
#pragma clang diagnostic pop

@end

@implementation XPOpenPanel
+(NSArray*)filenamesByRunningAppModalOpenPanel;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  XPInteger result;
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setAllowsMultipleSelection:YES];
  result = [panel runModalForDirectory:nil
                                  file:nil
                                 types:[NSArray arrayWithObject:@"solv"]];
  switch (result) {
    case NSOKButton:     return [panel filenames];
    case NSCancelButton: return [[NSArray new] autorelease];
    default: [XPLog error:@"Impossible XPOpenPanel result: %lu", result]; return nil;
  }
#pragma clang diagnostic pop
}
@end

@implementation XPSavePanel
+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window;
{
  return nil;
}
@end
