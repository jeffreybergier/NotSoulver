/* SVRAccessoryWindowsOwner.m created by me on Sun 27-Oct-2024 */

#import "SVRAccessoryWindowsOwner.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRAccessoryWindowsOwner

// MARK: IBOutlets
-(NSPanel *)keypadPanel;
{
  return [[_keypadPanel retain] autorelease];
}

-(NSWindow*)aboutWindow;
{
  return [[_aboutWindow retain] autorelease];
}

-(NSWindow*)settingsWindow;
{
  return [[_settingsWindow retain] autorelease];
}

// MARK: Init
-(id)init;
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  self = [super init];
  [NSBundle loadNibNamed:@"NEXTSTEP_AccessoryWindows" owner:self];
  [self __restoreWindowState];
  [nc addObserver:self
         selector:@selector(__windowDidBecomeKey:)
             name:NSWindowDidBecomeKeyNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(__windowWillCloseNotification:)
             name:NSWindowWillCloseNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(__windowDidMove:)
             name:NSWindowDidMoveNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(__windowDidResize:)
             name:NSWindowDidResizeNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(__applicationWillTerminate:)
             name:NSApplicationWillTerminateNotification
           object:nil];
  return self;
}

// MARK: IBActions
// Invoked by AppDelegate
-(IBAction)toggleKeypadPanel:(id)sender;
{
  NSPanel *panel = [self keypadPanel];
  if ([panel isVisible]) {
    [panel performClose:sender];
  } else {
    [panel makeKeyAndOrderFront:sender];
  }
}

-(IBAction)showSettingsWindow:(id)sender;
{
  [[self settingsWindow] makeKeyAndOrderFront:sender];
}

-(IBAction)showAboutWindow:(id)sender;
{
  [[self aboutWindow] makeKeyAndOrderFront:sender];
}

// MARK: Restore Window State
-(void)__restoreWindowState;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSPanel  *keypad   = [self keypadPanel];
  NSWindow *about    = [self aboutWindow];
  NSWindow *settings = [self settingsWindow];
  
  // Restore Frames
  [keypad   setFrameUsingName:[self __stateRestorationKeyForWindow:keypad  ]];
  [about    setFrameUsingName:[self __stateRestorationKeyForWindow:about   ]];
  [settings setFrameUsingName:[self __stateRestorationKeyForWindow:settings]];
  
  // Restore Visibility
  if ([ud SVR_keypadPanelVisible])    { [self  toggleKeypadPanel:ud]; }
  if ([ud SVR_aboutWindowVisible])    { [self    showAboutWindow:ud]; }
  if ([ud SVR_settingsWindowVisible]) { [self showSettingsWindow:ud]; }
}

-(NSString*)__stateRestorationKeyForWindow:(NSWindow*)window;
{
  if      (window == [self keypadPanel])    { return @"SVRAccessoryWindowsOwnerKeypadPanel";   }
  else if (window == [self aboutWindow])    { return @"SVRAccessoryWindowsOwnerAboutWindow";   }
  else if (window == [self settingsWindow]) { return @"SVRAccessoryWindowsOwnerSettingsWindow"; }
  return nil;
}

// MARK: Notifications (Save window state)

-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSWindow *window = [aNotification object];
  if      (window == [self keypadPanel])    { [ud    SVR_setKeypadPanelVisible:YES]; }
  else if (window == [self aboutWindow])    { [ud    SVR_setAboutWindowVisible:YES]; }
  else if (window == [self settingsWindow]) { [ud SVR_setSettingsWindowVisible:YES]; }
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSWindow *window = [aNotification object];
  if      (window == [self keypadPanel])    { [ud    SVR_setKeypadPanelVisible:NO]; }
  else if (window == [self aboutWindow])    { [ud    SVR_setAboutWindowVisible:NO]; }
  else if (window == [self settingsWindow]) { [ud SVR_setSettingsWindowVisible:NO]; }
}

-(void)__windowDidResize:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  NSString *key = [self __stateRestorationKeyForWindow:window];
  if (!key) { return; }
  [window saveFrameUsingName:key];
}

-(void)__windowDidMove:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  NSString *key = [self __stateRestorationKeyForWindow:window];
  if (!key) { return; }
  [window saveFrameUsingName:key];
}

-(void)__applicationWillTerminate:(NSNotification*)aNotification;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
  [XPLog debug:@"DEALLOC: %@", self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_keypadPanel autorelease];
  [_aboutWindow autorelease];
  [_settingsWindow autorelease];
  _keypadPanel = nil;
  _aboutWindow = nil;
  _settingsWindow = nil;
  [super dealloc];
}

@end
