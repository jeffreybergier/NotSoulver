/* SVRAccessoryWindowsOwner.m created by me on Sun 27-Oct-2024 */

#import "SVRAccessoryWindowsOwner.h"

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
  self = [super init];
  [NSBundle loadNibNamed:@"NEXTSTEP_AccessoryWindows" owner:self];
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

- (void)dealloc
{
  [XPLog debug:@"DEALLOC: %@", self];
  [_keypadPanel autorelease];
  [_aboutWindow autorelease];
  [_settingsWindow autorelease];
  _keypadPanel = nil;
  _aboutWindow = nil;
  _settingsWindow = nil;
  [super dealloc];
}

@end
