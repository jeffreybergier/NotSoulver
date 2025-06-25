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

SVRAppDelegate *_sharedDelegate = nil;

@implementation SVRAppDelegate

+(id)sharedDelegate;
{
  if (!_sharedDelegate) {
    _sharedDelegate = [[SVRAppDelegate alloc] init];
  }
  XPParameterRaise(_sharedDelegate);
  return _sharedDelegate;
}

-(id)init;
{
  self = [super init];
  XPParameterRaise(self);
  _menus = [NSMutableArray new];
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

-(IBAction)openSourceRepository:(id)sender;
{
  BOOL success = NO;
  XPAlertReturn copyToClipboard = XPAlertReturnError;
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSString *webURLToOpen = [Localized phraseSourceRepositoryURL];
  success = [ws XP_openWebURL:webURLToOpen];
  if (success) { return; }
  NSBeep();
  copyToClipboard = XPRunCopyWebURLToPasteboardAlert(webURLToOpen);
  switch (copyToClipboard) {
    case XPAlertReturnDefault:
      [pb declareTypes:[NSArray arrayWithObject:XPPasteboardTypeString] owner:self];
      success = [pb setString:webURLToOpen forType:XPPasteboardTypeString];
      XPLogAssrt1(success, @"[NSPasteboard setString:%@", webURLToOpen);
      return;
    default:
      XPLogDebug1(@"[Cancelled] [NSPasteboard setString:%@", webURLToOpen);
      return;
  }
}

-(void)dealloc;
{
  XPLogDebug1(@"<%@>", XPPointerString(self));
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_menus autorelease];
  [_openDocuments autorelease];
  [_accessoryWindowsOwner autorelease];
  _menus = nil;
  _openDocuments = nil;
  _accessoryWindowsOwner = nil;
  [super dealloc];
}

@end


@implementation SVRAppDelegate (NSApplicationDelegate)

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Set the menu
  [app setMainMenu:[SVRMainMenu newMainMenu:_menus]];
  // Configure the title of the app
  // TODO: Figure out why this is always the app name
  //[[app mainMenu] setTitle:@"ZZZ"];//[Localized titleAppName]];
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  // Prepare FontManager
  [NSFontManager setFontManagerFactory:[SVRFontManager class]];
  // Load Accessory Windows Nib
  _accessoryWindowsOwner = [[SVRAccessoryWindowsOwner alloc] init];
  XPParameterRaise(_accessoryWindowsOwner);
  // Announce
  XPLogDebug(@"");
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Observe Dark Mode
  [self beginObservingEffectiveAppearance:app];
#if XPSupportsNSDocument == 0
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__windowWillCloseNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
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
  [_sharedDelegate release];
  _sharedDelegate = nil;
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

-(BOOL)__applicationOpenUntitledFile:(NSApplication*)sender;
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
  } else {
    XPLogDebug1(@"Not a document window(%@)", window);
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
-(BOOL)applicationOpenUntitledFile:(NSApplication*)sender;
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
                 completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
{
  SVRAppDelegate *delegate = (SVRAppDelegate*)[[NSApplication sharedApplication] delegate];
  SVRAccessoryWindowsOwner *owner = [delegate accessoryWindowsOwner];
  XPParameterRaise(owner);
  [owner __restoreWindowWithIdentifier:identifier
                                 state:state
                     completionHandler:completionHandler];
}

@end

@implementation SVRMainMenu: NSObject
+(NSMenu*)newMainMenu:(NSMutableArray*)storage;
{
  NSMenu *mainMenu = [[[NSMenu alloc] initWithTitle:@"MainMenu"] autorelease];
  [storage addObject:mainMenu];
  
#ifdef XPSupportsApplicationMenu
  [self __buildAppMenuInMainMenu:mainMenu storage:storage];
#else
  [self __buildInfoMenuInMainMenu:mainMenu storage:storage];
#endif
  
  [self __buildFileMenuInMainMenu:mainMenu storage:storage];
  [self __buildEditMenuInMainMenu:mainMenu storage:storage];
  
#ifndef XPSupportsApplicationMenu
  [self __buildTrailingMenuInMainMenu:mainMenu storage:storage];
#endif
    
  return mainMenu;
}

+(void)__buildAppMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenuItem *item = nil;
	// TODO: On 10.4 and older the app menus appears as a second menu
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"MENU-Soulver"] autorelease];
  NSMenu *servicesMenu = [[[NSMenu alloc] initWithTitle:@"MENU-Services"] autorelease];
  
  [storage addObject:menu];
  [storage addObject:servicesMenu];
  
	// TODO: On 10.4 and older the app menus appears as a second menu
  item = [mainMenu addItemWithTitle:@"ITEM-Soulver" action:NULL keyEquivalent:@""];
  [mainMenu setSubmenu:menu forItem:item];

  [menu addItemWithTitle:@"About [Not]Soulver" action:@selector(showAboutWindow:) keyEquivalent:@""];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:[@"Settings" SVR_stringByAppendingEllipsis] action:@selector(showSettingsWindow:) keyEquivalent:@","];
  [menu XP_addSeparatorItem];
  item = [menu addItemWithTitle:@"ITEM-Services" action:NULL keyEquivalent:@""];
  [menu setSubmenu:servicesMenu forItem:item];
  [[NSApplication sharedApplication] setServicesMenu:servicesMenu];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:@"Hide [Not]Soulver" action:@selector(hide:) keyEquivalent:@"h"];
  item = [menu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagCommand|XPEventModifierFlagOption];
  [menu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:@"Quit [Not]Soulver" action:@selector(terminate:) keyEquivalent:@"q"];
}

+(void)__buildInfoMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"MENU-Info"] autorelease];
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:@"ITEM-Info" action:NULL keyEquivalent:@""];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];

  [menu addItemWithTitle:[@"Info" SVR_stringByAppendingEllipsis] action:@selector(showAboutWindow:) keyEquivalent:@""];
  [menu addItemWithTitle:[@"Settings" SVR_stringByAppendingEllipsis] action:@selector(showSettingsWindow:) keyEquivalent:@","];
  [menu addItemWithTitle:[@"Help" SVR_stringByAppendingEllipsis] action:@selector(openSourceRepository:) keyEquivalent:@"?"];
}

+(void)__buildFileMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"MENU-File"] autorelease];
  NSMenu *submenu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:@"ITEM-File" action:NULL keyEquivalent:@""];
  XPParameterRaise(item);
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  
  [menu addItemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n"];
  [menu addItemWithTitle:[@"Open" SVR_stringByAppendingEllipsis] action:@selector(openDocument:) keyEquivalent:@"o"];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
  [menu addItemWithTitle:[@"Save" SVR_stringByAppendingEllipsis] action:@selector(newDocument:) keyEquivalent:@"s"];
  [menu addItemWithTitle:[@"Save All" SVR_stringByAppendingEllipsis] action:@selector(saveAllDocuments:) keyEquivalent:@""];
  item = [menu addItemWithTitle:[@"Duplicate" SVR_stringByAppendingEllipsis] action:@selector(duplicateDocument:) keyEquivalent:@"s"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  item = [menu addItemWithTitle:[@"Save As" SVR_stringByAppendingEllipsis] action:@selector(saveDocumentAs:) keyEquivalent:@"s"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand|XPEventModifierFlagOption];
  [menu addItemWithTitle:[@"Rename" SVR_stringByAppendingEllipsis] action:@selector(renameDocument:) keyEquivalent:@""];
  [menu addItemWithTitle:[@"Move To" SVR_stringByAppendingEllipsis] action:@selector(moveDocument:) keyEquivalent:@""];
  item = [menu addItemWithTitle:@"ITEM-Revert To" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"MENU-Revert To"] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:@"Last Saved Version" action:@selector(revertDocumentToSaved:) keyEquivalent:@""];
  [submenu addItemWithTitle:[@"Browse All Versions" SVR_stringByAppendingEllipsis] action:@selector(browseDocumentVersions:) keyEquivalent:@""];
}

+(void)__buildEditMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"MENU-Edit"] autorelease];
  NSMenu *submenu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:@"ITEM-Edit" action:NULL keyEquivalent:@""];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  
  [menu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
  item = [menu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"z"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:@"Cut" action:@selector(cutUniversal:) keyEquivalent:@"x"];
  [menu addItemWithTitle:@"Copy" action:@selector(copyUniversal:) keyEquivalent:@"c"];
  item = [menu addItemWithTitle:@"Cut Unsolved" action:@selector(cutUnsolved:) keyEquivalent:@"x"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  item = [menu addItemWithTitle:@"Copy Unsolved" action:@selector(copyUnsolved:) keyEquivalent:@"c"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  [menu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
  [menu addItemWithTitle:@"Delete" action:@selector(delete:) keyEquivalent:@""];
  [menu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
  [menu XP_addSeparatorItem];
  // TODO: Add Insert, Attach Files, Add Link
  // Find Submenu
  item = [menu addItemWithTitle:@"ITEM-Find" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"MENU-Find"] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  item = [submenu addItemWithTitle:[@"Find" SVR_stringByAppendingEllipsis] action:@selector(performFindPanelAction:) keyEquivalent:@"f"];
  [item setTag:XPFindPanelActionShowFindPanel];
  item = [submenu addItemWithTitle:@"Find Next" action:@selector(performFindPanelAction:) keyEquivalent:@"g"];
  [item setTag:XPFindPanelActionNext];
  item = [submenu addItemWithTitle:@"Find Previous" action:@selector(performFindPanelAction:) keyEquivalent:@"d"];
  [item setTag:XPFindPanelActionPrevious];
  item = [submenu addItemWithTitle:@"Use Selection for Find" action:@selector(performFindPanelAction:) keyEquivalent:@"e"];
  [item setTag:XPFindPanelActionSetFindString];
  [submenu addItemWithTitle:@"Scroll to Selection" action:@selector(centerSelectionInVisibleArea:) keyEquivalent:@"j"];
  // Spelling Submenu
  item = [menu addItemWithTitle:@"ITEM-Spelling" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"MENU-Spelling"] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:@"Show Spelling and Grammar" action:@selector(showGuessPanel:) keyEquivalent:@":"];
  [submenu addItemWithTitle:@"Check Document Now" action:@selector(checkSpelling:) keyEquivalent:@";"];
  [submenu XP_addSeparatorItem];
  [submenu addItemWithTitle:@"Check Spelling While Typing" action:@selector(toggleContinuousSpellChecking:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Check Grammar With Spelling" action:@selector(toggleGrammarChecking:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Correct Spelling Automatically" action:@selector(toggleAutomaticSpellingCorrection:) keyEquivalent:@""];
  // Substitutions Submenu
  item = [menu addItemWithTitle:@"ITEM-Substitutions" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"MENU-Substitutions"] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:@"Show Substitutions" action:@selector(orderFrontSubstitutionsPanel:) keyEquivalent:@""];
  [submenu XP_addSeparatorItem];
  [submenu addItemWithTitle:@"Smart Copy/Paste" action:@selector(toggleSmartInsertDelete:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Smart Quotes" action:@selector(toggleAutomaticQuoteSubstitution:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Smart Dashes" action:@selector(toggleAutomaticDashSubstitution:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Smart Links" action:@selector(toggleAutomaticLinkDetection:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Data Detectors" action:@selector(toggleAutomaticDataDetection:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Text Replacement" action:@selector(toggleAutomaticTextReplacement:) keyEquivalent:@""];
  // Transformations Submenu
  item = [menu addItemWithTitle:@"ITEM-Transformations" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"MENU-Transformations"] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:@"Make Upper Case" action:@selector(uppercaseWord:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Make Lower Case" action:@selector(lowercaseWord:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Capitalize" action:@selector(capitalizeWord:) keyEquivalent:@""];
  // Speech Submenu
  item = [menu addItemWithTitle:@"ITEM-Speech" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"MENU-Speech"] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:@"Start Speaking" action:@selector(startSpeaking:) keyEquivalent:@""];
  [submenu addItemWithTitle:@"Stop Speaking" action:@selector(stopSpeaking:) keyEquivalent:@""];
}

+(void)__buildTrailingMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenuItem *item = nil;
  NSMenu *servicesMenu = [[[NSMenu alloc] init] autorelease];
  
  [storage addObject:servicesMenu];
  
  item = [mainMenu addItemWithTitle:@"Services" action:NULL keyEquivalent:@""];
  [mainMenu setSubmenu:servicesMenu forItem:item];
  [[NSApplication sharedApplication] setServicesMenu:servicesMenu];
  [mainMenu addItemWithTitle:@"Hide" action:@selector(hide:) keyEquivalent:@"h"];
  [mainMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
}

@end

@implementation NSMenu (CrossPlatform)
-(void)XP_addSeparatorItem;
{
#ifdef MAC_OS_X_VERSION_10_2
  [self addItem:[NSMenuItem separatorItem]];
#endif
}
@end

@implementation NSString (SVRMainMenu)
-(NSString*)SVR_stringByAppendingEllipsis;
{
#ifdef XPSupportsUnicodeUI
  return [self stringByAppendingFormat:@"%C", 0x2026];
#else
  return [self stringByAppendingString:@"..."];
#endif
}
@end
