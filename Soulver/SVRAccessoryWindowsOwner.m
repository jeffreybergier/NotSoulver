/* SVRAccessoryWindowsOwner.m created by me on Sun 27-Oct-2024 */

#import "SVRAccessoryWindowsOwner.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRFontManager

-(SVRThemeFont)themeFont;
{
  return _themeFont;
}
-(void)setThemeFont:(SVRThemeFont)themeFont;
{
  _themeFont = themeFont;
}

@end

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
  [[NSBundle mainBundle] XP_loadNibNamed:@"NEXTSTEP_AccessoryWindows"
                                   owner:self
                         topLevelObjects:&_topLevelObjects];
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
  
  NSPanel  *keypadWindow   = [self keypadPanel];
  NSWindow *aboutWindow    = [self aboutWindow];
  NSWindow *settingsWindow = [self settingsWindow];
  
  SVRAccessoryWindow keypad   = [self __accessoryWindowForWindow:keypadWindow  ];
  SVRAccessoryWindow about    = [self __accessoryWindowForWindow:aboutWindow   ];
  SVRAccessoryWindow settings = [self __accessoryWindowForWindow:settingsWindow];
  
  // Restore Frames
  [keypadWindow   setFrameUsingName:[NSUserDefaults SVR_frameKeyForWindow:keypad]  ];
  [aboutWindow    setFrameUsingName:[NSUserDefaults SVR_frameKeyForWindow:about]   ];
  [settingsWindow setFrameUsingName:[NSUserDefaults SVR_frameKeyForWindow:settings]];
  
  // Restore Visibility
  if ([ud SVR_visibilityForWindow:keypad])   { [self  toggleKeypadPanel:ud]; }
  if ([ud SVR_visibilityForWindow:about])    { [self    showAboutWindow:ud]; }
  if ([ud SVR_visibilityForWindow:settings]) { [self showSettingsWindow:ud]; }
}

-(SVRAccessoryWindow)__accessoryWindowForWindow:(NSWindow*)window;
{
  if      (window == [self keypadPanel])    { return SVRAccessoryWindowKeypad;   }
  else if (window == [self aboutWindow])    { return SVRAccessoryWindowAbout;    }
  else if (window == [self settingsWindow]) { return SVRAccessoryWindowSettings; }
  return SVRAccessoryWindowNone;
}

// MARK: Notifications (Save window state)

-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
{
  SVRAccessoryWindow window = [self __accessoryWindowForWindow:[aNotification object]];
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:YES forWindow:window];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  SVRAccessoryWindow window = [self __accessoryWindowForWindow:[aNotification object]];
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:NO forWindow:window];
}

-(void)__windowDidResize:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  NSString *key = [NSUserDefaults SVR_frameKeyForWindow:[self __accessoryWindowForWindow:window]];
  if (!key) { return; }
  [window saveFrameUsingName:key];
}

-(void)__windowDidMove:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  NSString *key = [NSUserDefaults SVR_frameKeyForWindow:[self __accessoryWindowForWindow:window]];
  if (!key) { return; }
  [window saveFrameUsingName:key];
}

-(void)__applicationWillTerminate:(NSNotification*)aNotification;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
  XPLogDebug1(@"DEALLOC: %@", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_keypadPanel autorelease];
  [_aboutWindow autorelease];
  [_settingsWindow autorelease];
  [_topLevelObjects release];
  _keypadPanel = nil;
  _aboutWindow = nil;
  _settingsWindow = nil;
  _topLevelObjects = nil;
  [super dealloc];
}

@end
