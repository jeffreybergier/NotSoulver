//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "MATHAppDelegate.h"
#import "MATHDocument.h"
#import "NSUserDefaults+MathEdit.h"

@implementation MATHAppDelegate

+(id)sharedDelegate;
{
  static MATHAppDelegate *sharedInstance = nil;
#ifdef AFF_ObjCNoDispatch
  if (sharedInstance == nil) {
    sharedInstance = [[MATHAppDelegate alloc] init];
  }
#else
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MATHAppDelegate alloc] init];
  });
#endif
  XPParameterRaise(sharedInstance);
  return sharedInstance;
}

-(id)init;
{
  self = [super init];
  XPParameterRaise(self);
  _openDocuments = [NSMutableSet new];
  _accessoryWindowsOwner = nil; // Set in applicationWillFinishLaunching:
#ifdef AFF_MainMenuNotRetainedBySystem
  _menus = [NSMutableArray new];
#else
  _menus = nil;
#endif
  return self;
}

-(MATHAccessoryWindowsOwner*)accessoryWindowsOwner;
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

-(IBAction)openWelcomeDocument:(id)sender;
{
  NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Welcome to MathEdit!" ofType:@"mtxt"];
  XPLogAssrt(fileName, @"[MISSING] Welcome Document");
#ifdef AFF_NSDocumentNone
  [self application:[NSApplication sharedApplication] openFile:filename];
#else
  // TODO: Fix this deprecation
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfFile:fileName display:YES];
#endif
}

-(void)dealloc;
{
  XPLogDebug1(@"<%@>", XPPointerString(self));
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_openDocuments autorelease];
  [_accessoryWindowsOwner autorelease];
  _openDocuments = nil;
  _accessoryWindowsOwner = nil;
#ifdef AFF_MainMenuNotRetainedBySystem
  [_menus autorelease];
  _menus = nil;
#endif
  [super dealloc];
}

@end


@implementation MATHAppDelegate (NSApplicationDelegate)

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Build the menu
  [app setMainMenu:[NSMenu MATH_mainMenuWithApp:app storage:_menus]];
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] MATH_configure];
  // Prepare FontManager
  [NSFontManager setFontManagerFactory:[MATHFontManager class]];
  // Load Accessory Windows Nib
  _accessoryWindowsOwner = [[MATHAccessoryWindowsOwner alloc] init];
  XPParameterRaise(_accessoryWindowsOwner);
  // Announce
  XPLogDebug(@"");
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Observe Dark Mode
  [self beginObservingEffectiveAppearance:app];
#ifdef AFF_NSDocumentNone
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__windowWillCloseNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
#endif
#ifndef AFF_StateRestorationNone
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

@end

@implementation MATHAppDelegate (PreDocument)

-(NSMutableSet*)openDocuments;
{
  return [[_openDocuments retain] autorelease];
}

-(IBAction)__newDocument:(id)sender
{
  XPDocument *document = [[[MATHDocument alloc] init] autorelease];
  [document setFileType:MATHDocumentModelRepDisk];
  [document MATH_setRequiredFileType:MATHDocumentModelExtension];
  [document showWindows];
  [[self openDocuments] addObject:document];
}

-(IBAction)__openDocument:(id)sender;
{
  NSArray *filenames = nil;
  NSEnumerator *e = nil;
  id nextF = nil;
  XPDocument *nextC = nil;

  filenames = XPRunOpenPanel(MATHDocumentModelExtension);
  if ([filenames count] == 0) { XPLogDebug(@"Open Cancelled"); return; }
  e = [filenames objectEnumerator];
  while ((nextF = [e nextObject])) {
    nextC = [[self openDocuments] member:nextF];
    if (!nextC) {
      nextC = [[[MATHDocument alloc] MATH_initWithContentsOfFileObject:nextF
                                                                ofType:MATHDocumentModelRepDisk
                                                                 error:NULL] autorelease];
      [[self openDocuments] addObject:nextC];
    }
    [nextC showWindows];
  }
}

-(BOOL)__applicationShouldTerminate:(NSApplication *)sender;
{
  XPAlertReturn alertResult = NSNotFound;
  BOOL aDocumentNeedsSaving = NO;
  NSEnumerator *e = nil;
  XPDocument *next = nil;

  // Check all documents
  e = [[self openDocuments] objectEnumerator];
  while ((next = [e nextObject])) {
    aDocumentNeedsSaving = [next isDocumentEdited];
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
  XPDocument *next = nil;

  // Try to close all documents (asking the user to save them)
  while ((next = [e nextObject])) {
    [[next MATH_windowForSheet] performClose:sender];
  }

  // Iterate again and check if are unsaved changes
  e = [[self openDocuments] objectEnumerator];
  while ((next = [e nextObject])) {
    if ([next isDocumentEdited]) {
      return NO;
    }
  }

  // If we made it this far, then everything is saved
  return YES;
}

-(BOOL)__application:(NSApplication *)sender openFile:(NSString*)filename;
{
  MATHDocument *document = [[self openDocuments] member:filename];
  if (!document) {
    document = [[[MATHDocument alloc] MATH_initWithContentsOfFileObject:filename
                                                                 ofType:MATHDocumentModelRepDisk
                                                                  error:NULL] autorelease];
    [[self openDocuments] addObject:document];
  }
  [[document MATH_windowForSheet] makeKeyAndOrderFront:sender];
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

// MARK: Pre-NSDocument AppDelegate Methods
#ifdef AFF_NSDocumentNone
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

NSString * const MATHApplicationEffectiveAppearanceKeyPath = @"effectiveAppearance";

@implementation MATHAppDelegate (DarkModeObserving)

-(void)beginObservingEffectiveAppearance:(NSApplication*)app;
{
#ifndef AFF_UIStyleDarkModeNone
  [app addObserver:self
        forKeyPath:MATHApplicationEffectiveAppearanceKeyPath
           options:NSKeyValueObservingOptionNew
           context:NULL];
#endif
}

-(void)endObservingEffectiveAppearance:(NSApplication*)app;
{
#ifndef AFF_UIStyleDarkModeNone
  [app removeObserver:self
           forKeyPath:MATHApplicationEffectiveAppearanceKeyPath];
#endif
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context;
{
#ifndef AFF_UIStyleDarkModeNone
  if ([keyPath isEqualToString:MATHApplicationEffectiveAppearanceKeyPath]) {
    XPLogDebug(@"effectiveAppearance: Changed");
    [[NSNotificationCenter defaultCenter] postNotificationName:MATHThemeDidChangeNotificationName
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

@implementation MATHAppDelegate (StateRestoration)

-(void)applicationDidFinishRestoringWindows:(NSNotification*)aNotification;
{
}

-(BOOL)applicationSupportsSecureRestorableState:(NSApplication*)app;
{
  return YES;
}

+(void)restoreWindowWithIdentifier:(NSString*)identifier
                             state:(NSCoder*)state
                 completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
{
  MATHAppDelegate *delegate = (MATHAppDelegate*)[[NSApplication sharedApplication] delegate];
  MATHAccessoryWindowsOwner *owner = [delegate accessoryWindowsOwner];
  XPParameterRaise(owner);
  [owner __restoreWindowWithIdentifier:identifier
                                 state:state
                     completionHandler:completionHandler];
}

@end

@implementation NSMenu (AppDelegate)
+(NSMenu*)MATH_mainMenuWithApp:(NSApplication*)app
                       storage:(NSMutableArray*)storage;
{
  NSMenu *mainMenu = [[[NSMenu alloc] initWithTitle:[Localized titleAppName]] autorelease];
  [storage addObject:mainMenu];
  
#ifdef AFF_MainMenuNoApplicationMenu
  [self __buildInfoMenuInMainMenu:mainMenu storage:storage];
#else
  [self __buildAppMenuInMainMenu:mainMenu
                     application:app
                         storage:storage];
#endif
  
  [self __buildFileMenuInMainMenu:mainMenu storage:storage];
  [self __buildEditMenuInMainMenu:mainMenu storage:storage];
  [self __buildViewMenuInMainMenu:mainMenu storage:storage];
  [self __buildWindowsMenuInMainMenu:mainMenu 
                                 app:app
                             storage:storage];
  
#ifdef AFF_MainMenuNoApplicationMenu
  [self __buildTrailingMenuInMainMenu:mainMenu
                                  app:app
                              storage:storage];
#else
  [self __buildHelpMenuInMainMenu:mainMenu storage:storage];
#endif
    
  return mainMenu;
}

+(void)__buildAppMenuInMainMenu:(NSMenu*)mainMenu
                    application:(NSApplication*)app
                        storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenu *submenu = nil;
  NSMenuItem *item = nil;
  
  // Application menu
  item = [mainMenu addItemWithTitle:NSLocalizedString(@"MENU-App", @"This menu title is not shown") action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"ITEM-App", @"This menu title is not shown")] autorelease];
  [storage addObject:menu];
  [mainMenu setSubmenu:menu forItem:item];
#ifdef AFF_MainMenuRequiresSetAppleMenu
  // This Hack is credited to Jeff Johnson.
  // I couldn't have gotten menus to work in Tiger or Jaguar without you!
  // https://lapcatsoftware.com/blog/2007/06/04/working-without-a-nib-part-2-also-also-wik/
  [app performSelector:@selector(setAppleMenu:) withObject:menu];
#endif

  [menu addItemWithTitle:[Localized menuAppAbout] action:@selector(showAboutWindow:) keyEquivalent:@""];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:[[Localized menuAppSettings] MATH_stringByAppendingEllipsis] action:@selector(showSettingsWindow:) keyEquivalent:@","];
  [menu XP_addSeparatorItem];
  
  // Services submenu
  item = [menu addItemWithTitle:[Localized menuAppServices] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuAppServices]] autorelease];
  [storage addObject:submenu];
  [menu setSubmenu:submenu forItem:item];
  [app setServicesMenu:submenu];
  [menu XP_addSeparatorItem];
  
  [menu addItemWithTitle:[Localized menuAppHideSelf] action:@selector(hide:) keyEquivalent:@"h"];
  item = [menu addItemWithTitle:[Localized menuAppHideOthers] action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagCommand|XPEventModifierFlagOption];
  [menu addItemWithTitle:[Localized menuAppShowAll] action:@selector(unhideAllApplications:) keyEquivalent:@""];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:[Localized menuAppQuit] action:@selector(terminate:) keyEquivalent:@"q"];
}

+(void)__buildInfoMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuAppInfoLegacy] action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:[Localized menuAppInfoLegacy]] autorelease];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];

  [menu addItemWithTitle:[[Localized menuAppInfoLegacy] MATH_stringByAppendingEllipsis] action:@selector(showAboutWindow:) keyEquivalent:@""];
  [menu addItemWithTitle:[[Localized menuAppSettings] MATH_stringByAppendingEllipsis] action:@selector(showSettingsWindow:) keyEquivalent:@","];
  [menu addItemWithTitle:[[Localized menuHelp] MATH_stringByAppendingEllipsis] action:@selector(openSourceRepository:) keyEquivalent:@"?"];
}

+(void)__buildFileMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenu *submenu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuFile] action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:[Localized menuFile]] autorelease];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  
  [menu addItemWithTitle:[Localized menuFileNew] action:@selector(newDocument:) keyEquivalent:@"n"];
  [menu addItemWithTitle:[[Localized menuFileOpen] MATH_stringByAppendingEllipsis] action:@selector(openDocument:) keyEquivalent:@"o"];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:[Localized menuFileClose] action:@selector(performClose:) keyEquivalent:@"w"];
  [menu addItemWithTitle:[[Localized menuFileSave] MATH_stringByAppendingEllipsis] action:@selector(saveDocument:) keyEquivalent:@"s"];
  [menu addItemWithTitle:[[Localized menuFileSaveAll] MATH_stringByAppendingEllipsis] action:@selector(saveAllDocuments:) keyEquivalent:@""];
  item = [menu addItemWithTitle:[[Localized menuFileSaveAs] MATH_stringByAppendingEllipsis] action:@selector(saveDocumentAs:) keyEquivalent:@"s"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand|XPEventModifierFlagOption];
  item = [menu addItemWithTitle:[[Localized menuFileDuplicate] MATH_stringByAppendingEllipsis] action:@selector(duplicateDocument:) keyEquivalent:@"s"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  [menu addItemWithTitle:[[Localized menuFileRename] MATH_stringByAppendingEllipsis] action:@selector(renameDocument:) keyEquivalent:@""];
  [menu addItemWithTitle:[[Localized menuFileMoveTo] MATH_stringByAppendingEllipsis] action:@selector(moveDocument:) keyEquivalent:@""];
  item = [menu addItemWithTitle:[Localized menuFileRevertTo] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuFileRevertTo]] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:[Localized menuFileLastSavedVersion] action:@selector(revertDocumentToSaved:) keyEquivalent:@""];
  [submenu addItemWithTitle:[[Localized menuFileBrowseAllVersions] MATH_stringByAppendingEllipsis] action:@selector(browseDocumentVersions:) keyEquivalent:@""];
}

+(void)__buildEditMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenu *submenu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuEdit] action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:[Localized menuEdit]] autorelease];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  
  [menu addItemWithTitle:[Localized menuEditUndo] action:@selector(undo:) keyEquivalent:@"z"];
  item = [menu addItemWithTitle:[Localized menuEditRedo] action:@selector(redo:) keyEquivalent:@"z"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  [menu XP_addSeparatorItem];
  [menu addItemWithTitle:[Localized menuEditCut] action:@selector(cutUniversal:) keyEquivalent:@"x"];
  [menu addItemWithTitle:[Localized menuEditCopy] action:@selector(copyUniversal:) keyEquivalent:@"c"];
  item = [menu addItemWithTitle:[Localized menuEditCutUnsolved] action:@selector(cutUnsolved:) keyEquivalent:@"x"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  item = [menu addItemWithTitle:[Localized menuEditCopyUnsolved] action:@selector(copyUnsolved:) keyEquivalent:@"c"];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagShift|XPEventModifierFlagCommand];
  [menu addItemWithTitle:[Localized menuEditPaste] action:@selector(pasteUniversal:) keyEquivalent:@"v"];
  [menu addItemWithTitle:[Localized menuEditDelete] action:@selector(delete:) keyEquivalent:@""];
  [menu addItemWithTitle:[Localized menuEditSelectAll] action:@selector(selectAll:) keyEquivalent:@"a"];
  [menu XP_addSeparatorItem];
  // TODO: Add Insert, Attach Files, Add Link
#ifndef AFF_NSTextViewFindNone
  // Find Submenu
  item = [menu addItemWithTitle:[Localized menuEditFind] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuEditFind]] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  item = [submenu addItemWithTitle:[[Localized menuEditFind] MATH_stringByAppendingEllipsis] action:@selector(performFindPanelAction:) keyEquivalent:@"f"];
  [item setTag:NSFindPanelActionShowFindPanel];
  item = [submenu addItemWithTitle:[Localized menuEditFindNext] action:@selector(performFindPanelAction:) keyEquivalent:@"g"];
  [item setTag:NSFindPanelActionNext];
  item = [submenu addItemWithTitle:[Localized menuEditFindPrevious] action:@selector(performFindPanelAction:) keyEquivalent:@"d"];
  [item setTag:NSFindPanelActionPrevious];
  item = [submenu addItemWithTitle:[Localized menuEditFindUseSelection] action:@selector(performFindPanelAction:) keyEquivalent:@"e"];
  [item setTag:NSFindPanelActionSetFindString];
  [submenu addItemWithTitle:[Localized menuEditFindScroll] action:@selector(centerSelectionInVisibleArea:) keyEquivalent:@"j"];
#endif
  // Spelling Submenu
  item = [menu addItemWithTitle:[Localized menuEditSpelling] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuEditSpelling]] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:[Localized menuEditSpellingShow] action:@selector(showGuessPanel:) keyEquivalent:@":"];
  [submenu addItemWithTitle:[Localized menuEditSpellingCheckNow] action:@selector(checkSpelling:) keyEquivalent:@";"];
  [submenu XP_addSeparatorItem];
  [submenu addItemWithTitle:[Localized menuEditSpellingCheckWhileTyping] action:@selector(toggleContinuousSpellChecking:) keyEquivalent:@""];
#ifndef AFF_NSTextViewSubstitutionsAndGrammarNone
  [submenu addItemWithTitle:[Localized menuEditSpellingCheckGrammar] action:@selector(toggleGrammarChecking:) keyEquivalent:@""];
#endif
  [submenu addItemWithTitle:[Localized menuEditSpellingAutoCorrect] action:@selector(toggleAutomaticSpellingCorrection:) keyEquivalent:@""];
  
#ifndef AFF_NSTextViewFindNone
  // Substitutions Submenu
  item = [menu addItemWithTitle:[Localized menuEditSubstitutions] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuEditSubstitutions]] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsShow] action:@selector(orderFrontSubstitutionsPanel:) keyEquivalent:@""];
  [submenu XP_addSeparatorItem];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsSmartCopyPaste] action:@selector(toggleSmartInsertDelete:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsSmartQuotes] action:@selector(toggleAutomaticQuoteSubstitution:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsSmartDashes] action:@selector(toggleAutomaticDashSubstitution:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsSmartLinks] action:@selector(toggleAutomaticLinkDetection:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsDataDetectors] action:@selector(toggleAutomaticDataDetection:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditSubstitutionsTextReplacements] action:@selector(toggleAutomaticTextReplacement:) keyEquivalent:@""];
#endif
  // Transformations Submenu
  item = [menu addItemWithTitle:[Localized menuEditTransformations] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuEditTransformations]] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:[Localized menuEditTransformationsUpperCase] action:@selector(uppercaseWord:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditTransformationsLowerCase] action:@selector(lowercaseWord:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditTransformationsCapitalize] action:@selector(capitalizeWord:) keyEquivalent:@""];
  // Speech Submenu
  item = [menu addItemWithTitle:[Localized menuEditSpeech] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuEditSpeech]] autorelease];
  [menu setSubmenu:submenu forItem:item];
  [storage addObject:submenu];
  [submenu addItemWithTitle:[Localized menuEditSpeechStart] action:@selector(startSpeaking:) keyEquivalent:@""];
  [submenu addItemWithTitle:[Localized menuEditSpeechStop] action:@selector(stopSpeaking:) keyEquivalent:@""];
}

+(void)__buildViewMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuView] action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:[Localized menuView]] autorelease];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  
  [menu addItemWithTitle:[Localized menuViewActualSize] action:@selector(actualSize:) keyEquivalent:@"0"];
  item = [menu addItemWithTitle:[Localized menuViewZoomIn] action:@selector(zoomIn:) keyEquivalent:@"."];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagCommand|XPEventModifierFlagShift];
  item = [menu addItemWithTitle:[Localized menuViewZoomOut] action:@selector(zoomOut:) keyEquivalent:@","];
  [item setKeyEquivalentModifierMask:XPEventModifierFlagCommand|XPEventModifierFlagShift];
#ifndef AFF_NSWindowNoFullScreen
  [menu XP_addSeparatorItem];
#endif
}

+(void)__buildWindowsMenuInMainMenu:(NSMenu*)mainMenu
                                app:(NSApplication*)app
                            storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuWindow] action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:[Localized menuWindow]] autorelease];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  [app setWindowsMenu:menu];
  [menu addItemWithTitle:[Localized menuWindowShowKeypad] action:@selector(toggleKeypadPanel:) keyEquivalent:@"k"];
}

+(void)__buildHelpMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
{
  NSMenu *menu = nil;
  NSMenuItem *item = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuHelp] action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:[Localized menuHelp]] autorelease];
  [mainMenu setSubmenu:menu forItem:item];
  [storage addObject:menu];
  [menu addItemWithTitle:[Localized menuHelpWelcomeDocument] action:@selector(openWelcomeDocument:) keyEquivalent:@"?"];
  [menu addItemWithTitle:[Localized menuHelpMathEdit] action:@selector(openSourceRepository:) keyEquivalent:@"?"];
}

+(void)__buildTrailingMenuInMainMenu:(NSMenu*)mainMenu
                                 app:(NSApplication*)app
                             storage:(NSMutableArray*)storage;
{
  NSMenuItem *item = nil;
  NSMenu *submenu = nil;
  
  item = [mainMenu addItemWithTitle:[Localized menuAppServices] action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:[Localized menuAppServices]] autorelease];
  [storage addObject:submenu];
  [mainMenu setSubmenu:submenu forItem:item];
  [app setServicesMenu:submenu];
  
  [mainMenu addItemWithTitle:[Localized menuAppHideLegacy] action:@selector(hide:) keyEquivalent:@"h"];
  [mainMenu addItemWithTitle:[Localized menuAppQuitLegacy] action:@selector(terminate:) keyEquivalent:@"q"];
}

@end

@implementation NSMenu (CrossPlatform)
-(void)XP_addSeparatorItem;
{
#ifndef AFF_MainMenuNoApplicationMenu
  [self addItem:[NSMenuItem separatorItem]];
#endif
}
@end

@implementation NSString (MATHMainMenu)
-(NSString*)MATH_stringByAppendingEllipsis;
{
#ifdef AFF_UnicodeUINone
  return [self stringByAppendingString:@"..."];
#else
  return [self stringByAppendingFormat:@"%C", 0x2026];
#endif
}
@end
