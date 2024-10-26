#import <AppKit/AppKit.h>
#import "SVRDocument.h"
#import "SVRAccessoryWindowsOwner.h"

@interface SVRAppDelegate: NSObject
{
  mm_new NSMutableSet *_openDocuments;
  mm_new SVRAccessoryWindowsOwner *_accessoryWindowsOwner;
}

// MARK: Init
-(void)awakeFromNib;

// MARK: Properties
-(NSMutableSet*)openDocuments;
-(SVRAccessoryWindowsOwner*)accessoryWindowsOwner;

// MARK: IBActions
-(IBAction)newDoc:(id)sender;
-(IBAction)openDoc:(id)sender;
-(IBAction)saveAll:(id)sender;
-(IBAction)toggleKeypadPanel:(id)sender;
-(IBAction)showSettingsWindow:(id)sender;
-(IBAction)showAboutWindow:(id)sender;

// MARK: Notifications
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)__applicationShouldTerminateAfterReviewingAllWindows:(NSApplication*)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
@end
