//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "SVRAppDelegate.h"
#import "SVRDocument.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRAppDelegate

-(id)init;
{
  self = [super init];
  XPParameterRaise(self);
  _openDocuments = [NSMutableSet new];
  _accessoryWindowsOwner = nil; // Set in applicationWillFinishLaunching:
  return self;
}

-(SVRAccessoryWindowsOwner*)accessoryWindowsOwner;
{
  return [[_accessoryWindowsOwner retain] autorelease];
}

-(IBAction)toggleKeypadPanel:(id)sender;
{
  [[self accessoryWindowsOwner] toggleKeypadPanel:sender];
}

-(IBAction)showSettingsWindow:(id)sender;
{
  [[self accessoryWindowsOwner] showSettingsWindow:sender];
}

-(IBAction)showAboutWindow:(id)sender;
{
  [[self accessoryWindowsOwner] showAboutWindow:sender];
}

-(void)dealloc;
{
  XPLogDebug1(@"<%@>", XPPointerString(self));
  [_openDocuments release];
  [_accessoryWindowsOwner release];
  _openDocuments = nil;
  _accessoryWindowsOwner = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end


@implementation SVRAppDelegate (NSApplicationDelegate)

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  Class myClass = [self class];
  // Configure the title of the app
  [[app mainMenu] setTitle:[Localized titleAppName]];
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  // Prepare FontManager
  [NSFontManager setFontManagerFactory:[SVRFontManager class]];
  // Load Accessory Windows Nib
  _accessoryWindowsOwner = [[SVRAccessoryWindowsOwner alloc] init];
  XPParameterRaise(_accessoryWindowsOwner);
  // Configure Accessory Windows for state restoration
  [[_accessoryWindowsOwner aboutWindow   ] XP_setRestorationClass:myClass];
  [[_accessoryWindowsOwner keypadPanel   ] XP_setRestorationClass:myClass];
  [[_accessoryWindowsOwner settingsWindow] XP_setRestorationClass:myClass];
  // Announce
  XPLogDebug(@"");
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Observe Dark Mode
  [self beginObservingEffectiveAppearance:app];
#ifndef XPSupportsNSDocument
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__windowWillCloseNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
  }
#endif
#ifdef XPSupportsStateRestoration
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishRestoringWindows:)
                                                 name:NSApplicationDidFinishRestoringWindowsNotification
                                               object:nil];
#endif
  // Restore state on older systems
  [[self accessoryWindowsOwner] legacy_restoreWindowVisibility];
  // Announce
  XPLogDebug(@"");
}

-(void)applicationWillTerminate:(NSNotification*)aNotification;
{
  [self endObservingEffectiveAppearance:[aNotification object]];
}

-(BOOL)applicationOpenUntitledFile:(NSApplication*)sender;
{
#ifdef XPSupportsStateRestoration
  // After 10.7 an open panel is expected to open
  [[NSDocumentController sharedDocumentController] openDocument:sender];
  return YES;
#elif XPSupportsNSDocument >= 1
  // Between 10.0 and 10.7, a new blank document is expected to open,
  // and this is handled automatically by NSDocument
  return NO;
#else
  // In OpenStep a new document is expected,
  // but this has to be done manually
  [self __newDocument:sender];
  return YES;
#endif
}

@end

@implementation SVRAppDelegate (PreDocument)

-(NSMutableSet*)openDocuments;
{
  return [[_openDocuments retain] autorelease];
}

-(IBAction)__newDocument:(id)sender
{
  XPDocument document = [[[SVRDocument alloc] init] autorelease];
  [document XP_setFileType:SVRDocumentModelRepDisk];
  [document XP_setFileExtension:SVRDocumentModelExtension];
  [document XP_showWindows];
  [[self openDocuments] addObject:document];
}

-(IBAction)__openDocument:(id)sender;
{
  NSArray *filenames = nil;
  NSEnumerator *e = nil;
  XPURL *nextF = nil;
  XPDocument nextC = nil;

  filenames = XPRunOpenPanel(SVRDocumentModelExtension);
  if ([filenames count] == 0) { XPLogDebug(@"Open Cancelled"); return; }
  e = [filenames objectEnumerator];
  while ((nextF = [e nextObject])) {
    nextC = [[self openDocuments] member:nextF];
    if (!nextC) {
      nextC = [[[SVRDocument alloc] initWithContentsOfURL:nextF
                                                   ofType:SVRDocumentModelRepDisk
                                                    error:NULL] autorelease];
      [[self openDocuments] addObject:nextC];
    }
    [nextC XP_showWindows];
  }
}

-(BOOL)__applicationShouldTerminate:(NSApplication *)sender;
{
  XPAlertReturn alertResult = NSNotFound;
  BOOL aDocumentNeedsSaving = NO;
  NSEnumerator *e = nil;
  XPDocument next = nil;

  // Check all documents
  e = [[self openDocuments] objectEnumerator];
  while ((next = [e nextObject])) {
    aDocumentNeedsSaving = [next XP_isDocumentEdited];
    if (aDocumentNeedsSaving) { break; }
  }

  // Ask the user if they want to quit
  if (!aDocumentNeedsSaving) { return YES; }
  alertResult = XPRunQuitAlert();
  switch (alertResult) {
    case XPAlertReturnDefault:
      return [self __applicationShouldTerminateAfterReviewingAllDocuments:sender];
    case XPAlertReturnAlternate: return YES;
    case XPAlertReturnOther:     return NO;
    default:
      XPLogAssrt1(NO, @"[FAIL] XPAlertReturn(%d)", (int)alertResult);
      return NO;
  }
}

-(BOOL)__applicationShouldTerminateAfterReviewingAllDocuments:(NSApplication*)sender;
{
  NSEnumerator *e = [[self openDocuments] objectEnumerator];
  XPDocument next = nil;

  // Try to close all documents (asking the user to save them)
  while ((next = [e nextObject])) {
    [[next XP_windowForSheet] performClose:sender];
  }

  // Iterate again and check if are unsaved changes
  e = [[self openDocuments] objectEnumerator];
  while ((next = [e nextObject])) {
    if ([next XP_isDocumentEdited]) {
      return NO;
    }
  }

  // If we made it this far, then everything is saved
  return YES;
}

-(BOOL)__application:(NSApplication *)sender openFile:(NSString*)filename;
{
  SVRDocument *document = [[self openDocuments] member:filename];
  if (!document) {
    document = [[[SVRDocument alloc] initWithContentsOfURL:(XPURL*)filename
                                                    ofType:SVRDocumentModelRepDisk
                                                     error:NULL] autorelease];
    [[self openDocuments] addObject:document];
  }
  [[document XP_windowForSheet] makeKeyAndOrderFront:sender];
  return YES;
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  id document = [window delegate];
  if (document) {
    [[self openDocuments] removeObject:document];
  }
}

// MARK: Pre-NSDocument Stubs
#if XPSupportsNSDocument == 0
-(IBAction)newDocument:(id)sender;
{
  [self __newDocument:sender];
}
-(IBAction)openDocument:(id)sender;
{
  [self __openDocument:sender];
}
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
{
  return [self __applicationShouldTerminate:sender];
}
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
{
  return [self __application:sender openFile:filename];
}
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
{
  return [self __applicationOpenUntitledFile:sender];
}
#else

#endif

@end

NSString * const SVRApplicationEffectiveAppearanceKeyPath = @"effectiveAppearance";

@implementation SVRAppDelegate (DarkModeObserving)

-(void)beginObservingEffectiveAppearance:(NSApplication*)app;
{
#ifdef XPSupportsDarkMode
  [app addObserver:self 
        forKeyPath:SVRApplicationEffectiveAppearanceKeyPath
           options:NSKeyValueObservingOptionNew
           context:NULL];
#else
  XPLogDebug(@"System does not support dark mode");
#endif
}

-(void)endObservingEffectiveAppearance:(NSApplication*)app;
{
#ifdef XPSupportsDarkMode
  [app removeObserver:self
           forKeyPath:SVRApplicationEffectiveAppearanceKeyPath];
#endif
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context;
{
#ifdef XPSupportsDarkMode
  if ([keyPath isEqualToString:SVRApplicationEffectiveAppearanceKeyPath]) {
    XPLogDebug(@"effectiveAppearance: Changed");
    [[NSNotificationCenter defaultCenter] postNotificationName:SVRThemeDidChangeNotificationName
                                                        object:[NSUserDefaults standardUserDefaults]];
  } else {
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
#endif
}

@end

@implementation SVRAppDelegate (StateRestoration)

-(void)applicationDidFinishRestoringWindows:(NSNotification*)aNotification;
{
  // Overrides macOS behavior when restoring state where only
  // 1 or even 0 windows appear in front of the previously active
  // app window. I find this behavior very strange.
  NSApplication *app = [aNotification object];
  NSArray *windows = [app windows];
  NSEnumerator *e = [windows objectEnumerator];
  NSWindow *window = nil;
  XPLogAssrt1([app isKindOfClass:[NSApplication class]], @"%@ was not NSApplication", app);
  while ((window = [e nextObject])) {
    if ([window isVisible]) {
      // This behavior is different... for some reason.
      // In 10.8 orderFrontRegardless is needed.
      // In 10.15 15, orderFront: is needed.
#ifndef MAC_OS_X_VERSION_10_14
      [window orderFrontRegardless];
#else
      [window orderFront:app];
#endif
    }
  }
}

-(BOOL)applicationSupportsSecureRestorableState:(NSApplication*)app;
{
  return YES;
}

+(void)restoreWindowWithIdentifier:(NSString*)identifier
                             state:(NSCoder*)state
                 completionHandler:(XPWindowStationCompletionHandler)completionHandler;
{
  SVRAppDelegate *delegate = (SVRAppDelegate*)[[NSApplication sharedApplication] delegate];
  SVRAccessoryWindowsOwner *owner = [delegate accessoryWindowsOwner];
  XPParameterRaise(owner);
  [owner __restoreWindowWithIdentifier:identifier
                                 state:state
                     completionHandler:completionHandler];
}

@end
