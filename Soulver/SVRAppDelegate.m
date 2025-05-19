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
  NSCParameterAssert(self);
  _openDocuments = [NSMutableSet new];
  _accessoryWindowsOwner = nil; // Set in applicationDidFinishLaunching:
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
  XPLogExtra1(@"%p", self);
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
  // Configure the title of the app
  [[app mainMenu] setTitle:[Localized titleAppName]];
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  // Prepare FontManager
  [NSFontManager setFontManagerFactory:[SVRFontManager class]];
  // Announce
  XPLogDebug1(@"%@ applicationWillFinishLaunching:", self);
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Configure Accessory Windows
  _accessoryWindowsOwner = [[SVRAccessoryWindowsOwner alloc] init];
  // Observe Dark Mode
  [self beginObservingEffectiveAppearance:app];
  
  if (!NSClassFromString(@"NSDocument")) {
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__windowWillCloseNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
  }
  // Announce
  XPLogDebug1(@"%@ applicationDidFinishLaunching:", self);
}

-(void)applicationWillTerminate:(NSNotification*)aNotification;
{
  [self endObservingEffectiveAppearance:[aNotification object]];
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
  if ([filenames count] == 0) { XPLogDebug1(@"%@ Open Cancelled", self); return; }
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
      XPLogRaise2(@"%@ Unexpected alert result: %ld", self, alertResult);
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

-(BOOL)__applicationOpenUntitledFile:(NSApplication *)sender;
{
  [self __newDocument:sender];
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
  XPLogDebug1(@"%@: effectiveAppearance: System does not support dark mode", app);
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
  if ([keyPath isEqualToString:SVRApplicationEffectiveAppearanceKeyPath]) {
    XPLogAlwys1(@"%@: effectiveAppearance: Changed", object);
    [[NSNotificationCenter defaultCenter] postNotificationName:SVRThemeDidChangeNotificationName
                                                        object:[NSUserDefaults standardUserDefaults]];
  } else {
#ifdef XPSupportsDarkMode
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
#endif
  }
}

@end

@implementation SVRAppDelegate (StateRestoration)

-(BOOL)applicationSupportsSecureRestorableState:(NSApplication*)app;
{
  return YES;
}

@end
