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
+(XPAlertReturn)runAppModalWithTitle:(NSString*)title
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

+(XPAlertReturn)runSheetModalForWindow:(NSWindow*)window
                             withTitle:(NSString*)title
                               message:(NSString*)message
                         defaultButton:(NSString*)defaultButton
                       alternateButton:(NSString*)alternateButton
                           otherButton:(NSString*)otherButton;
{
  // TODO: Update to use sheets in Mac OS X
  return NSRunAlertPanel(title,
                         message,
                         defaultButton,
                         alternateButton,
                         otherButton);
}
#pragma clang diagnostic pop

@end

@implementation XPSavePanel

+(NSString*)lastDirectory;
{
  return [[XPUserDefaults standardUserDefaults] savePanelLastDirectory];
}

+(void)setLastDirectory:(NSString*)lastDirectory;
{
  [[XPUserDefaults standardUserDefaults] setSavePanelLastDirectory:lastDirectory];
}

+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window;
{
  return [self filenameByRunningSheetModalSavePanelForWindow:window
                                        withExistingFilename:nil];
}

+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window
                                     withExistingFilename:(NSString*)_filename;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  XPInteger result;
  // OpenStep documentation clearly states that empty string is OK but NIL is not
  NSString *filename = (_filename) ? _filename : @"";
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setRequiredFileType:@"solv"];
  result = [panel runModalForDirectory:[self lastDirectory] file:filename];
  [self setLastDirectory:[panel directory]];
  switch (result) {
    case NSOKButton:     return [panel filename];
    case NSCancelButton: return nil;
    default: [XPLog error:@"Impossible NSSavePanel result: %lu", result]; return nil;
  }
#pragma clang diagnostic pop
}
@end

@implementation XPOpenPanel
+(NSArray*)filenamesByRunningAppModalOpenPanel;
{
  return [self filenamesByRunningAppModalOpenPanelWithExistingFilename:nil];
}

+(NSArray*)filenamesByRunningAppModalOpenPanelWithExistingFilename:(NSString*)filename;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  XPInteger result;
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setAllowsMultipleSelection:YES];
  result = [panel runModalForDirectory:[self lastDirectory]
                                  file:filename // Unlike NSSavePanel, this can be NIL
                                 types:[NSArray arrayWithObject:@"solv"]];
  [self setLastDirectory:[panel directory]];
  switch (result) {
    case NSOKButton:     return [panel filenames];
    case NSCancelButton: return [[NSArray new] autorelease];
    default: [XPLog error:@"Impossible NSOpenPanel result: %lu", result]; return nil;
  }
#pragma clang diagnostic pop
}
@end

XPUserDefaults *XPUserDefaultsStandardUserDefaults = nil;
NSString *XPUserDefaultsStorageFilename = @"kUserDefaultsStorageFilename";
NSString *XPUserDefaultsSavePanelLastDirectory = @"kSavePanelLastDirectory";

@implementation XPUserDefaults

-(NSString*)storageFilename;
{
  return [_storage objectForKey:XPUserDefaultsStorageFilename];
}

-(NSString*)savePanelLastDirectory;
{
  return [_storage objectForKey:XPUserDefaultsSavePanelLastDirectory];
}

-(BOOL)setSavePanelLastDirectory:(NSString*)newValue;
{
  if (newValue) {
    [_storage setObject:newValue forKey:XPUserDefaultsSavePanelLastDirectory];
  } else {
    [_storage removeObjectForKey:XPUserDefaultsSavePanelLastDirectory];
  }
  return [self synchronize];
}

-(BOOL)synchronize;
{
  BOOL success = NO;
  NSString *filename = [self storageFilename];
  NSString *directory = [filename stringByDeletingLastPathComponent];
  NSFileManager *fm = [NSFileManager defaultManager];
  
  success = [fm createDirectoryAtPath:directory attributes:nil];
  if (!success) { [XPLog extra:@"%@ Failed: synchronize: directory %@", self, directory]; }
  success = [_storage writeToFile:[self storageFilename] atomically:YES];
  if (!success) { [XPLog pause:@"%@ Failed: synchronize: write: %@", self, filename]; }
  return success;
}

-(id)init;
{
  NSMutableDictionary *storage;
  self = [super init];
  storage = [[XPUserDefaults standardDictionaryOnDisk] mutableCopy];
  if (!storage) {
    storage = [[XPUserDefaults standardDictionary] mutableCopy];
  }
  _storage = storage;
  return self;
}

+(XPUserDefaults*)standardUserDefaults;
{
  if (!XPUserDefaultsStandardUserDefaults) {
    XPUserDefaultsStandardUserDefaults = [[self alloc] init];
  }
  return XPUserDefaultsStandardUserDefaults;
}

+(NSDictionary*)standardDictionaryOnDisk;
{
  NSString *filename = [[self standardDictionary] objectForKey:XPUserDefaultsStorageFilename];
  NSDictionary* output = [NSDictionary dictionaryWithContentsOfFile:filename];
  if (!output) { [XPLog debug:@"%@ Failed: onDiskStorage: %@", self, filename]; }
  return output;
}

+(NSDictionary*)standardDictionary;
{
  NSArray *keys;
  NSArray *vals;
  
  // TODO: Replace NSHomeDirectory with NSStandardLibraryPaths
  keys = [NSArray arrayWithObjects:
          XPUserDefaultsStorageFilename,
          XPUserDefaultsSavePanelLastDirectory,
          nil];
  vals = [NSArray arrayWithObjects:
          [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/NotSoulver/Preferences.plist"],
          NSHomeDirectory(),
          nil];
  
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

- (void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_storage release];
  _storage = nil;
  [super dealloc];
}

@end
