/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "SVRCrossPlatform.h"
#import "SVRMathString.h"

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
  return [[NSUserDefaults standardUserDefaults] savePanelLastDirectory];
}

+(void)setLastDirectory:(NSString*)lastDirectory;
{
  [[NSUserDefaults standardUserDefaults] setSavePanelLastDirectory:lastDirectory];
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


NSString *XPUserDefaultsSavePanelLastDirectory = @"kSavePanelLastDirectory";

@implementation NSUserDefaults (Soulver)

-(NSString*)savePanelLastDirectory;
{
  return [self objectForKey:XPUserDefaultsSavePanelLastDirectory];
}

-(BOOL)setSavePanelLastDirectory:(NSString*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsSavePanelLastDirectory];
  return [self synchronize];
}

+(NSDictionary*)standardDictionary;
{
  NSArray *keys;
  NSArray *vals;
  
  keys = [NSArray arrayWithObjects:
          XPUserDefaultsSavePanelLastDirectory,
          nil];
  vals = [NSArray arrayWithObjects:
          NSHomeDirectory(),
          nil];
  
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

@end

@implementation NSAttributedString (Pasteboard)

-(NSData*)SVR_pasteboardRepresentation;
{
  NSDictionary *attribs = [NSDictionary dictionaryWithObject:XPRTFTextDocumentType
                                                      forKey:XPDocumentTypeDocumentAttribute];
  return [self RTFFromRange:NSMakeRange(0, [self length]) documentAttributes:attribs];
}
@end

@implementation NSPasteboard (Pasteboard)

-(BOOL)SVR_setAttributedString:(NSAttributedString*)aString;
{
  BOOL success = NO;
  NSData *data = [aString SVR_pasteboardRepresentation];
  if (!data) {
    [XPLog pause:@"%@ Fail: RTFRepresentation", self];
    return success;
  }
  [self declareTypes:[NSArray arrayWithObjects:XPPasteboardTypeRTF, XPPasteboardTypeString, nil] owner:nil];
  success = [self setData:data forType:XPPasteboardTypeRTF];
  success = success && [self setString:[aString string] forType:XPPasteboardTypeString];
  if (!success) {
    [XPLog pause:@"%@ Fail: PBSetData: %@", self, data];
  }
  return success;
}

-(BOOL)SVR_setMathString:(SVRMathString*)aString;
{
  NSString *toPboard;
  BOOL success = NO;
  
  toPboard = [aString stringValue];
  [self declareTypes:[NSArray arrayWithObjects:XPPasteboardTypeString, nil] owner:nil];
  success = [self setString:toPboard forType:XPPasteboardTypeString];
  
  if (!success) {
    [XPLog pause:@"%@ Fail: PBSetString: %@", self, toPboard];
  }
  return success;
}

-(SVRMathString*)SVR_mathString;
{
  NSString *type;
  NSString *fromPboard = nil;
  NSEnumerator *e = [[self types] objectEnumerator];
  
  while ((type = [e nextObject])) {
    fromPboard = [self stringForType:type];
    if (fromPboard) {
      [XPLog debug:@"%@ stringForType: %@: %@", self, type, fromPboard];
      break;
    }
  }
  
  // TODO: Trim newlines from string ends after 10.3 Panther
  if (!fromPboard) { return nil; }
  fromPboard = [fromPboard SVR_stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([fromPboard length] == 0) { return nil; }	
  
  return [SVRMathString mathStringWithString:fromPboard];
}

@end

@implementation NSString (CrossPlatform)
-(NSString*)SVR_stringByTrimmingCharactersInSet:(NSCharacterSet*)set;
{
#if OS_OPENSTEP
  // Make a manual implementation?
  return self;
#else
  return [self stringByTrimmingCharactersInSet:set];
#endif
}
@end

@implementation NSBundle (CrossPlatform)
-(BOOL)SVR_loadNibNamed:(NSString*)nibName
                  owner:(id)owner
        topLevelObjects:(NSArray**)topLevelObjects;
{
#if OS_OPENSTEP
  return [[self class] loadNibNamed:nibName owner:owner];
#else
  return [self loadNibNamed:nibName owner:owner topLevelObjects:topLevelObjects];
#endif
}
@end
