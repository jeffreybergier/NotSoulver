#import <AppKit/AppKit.h>
#import "SVRDocument.h"

@interface SVRAppDelegate: NSObject
{
  NSMutableSet *_openDocuments;
}

// MARK: Init
-(void)awakeFromNib;

// MARK: Properties
-(NSMutableSet*)openDocuments;

// MARK: IBActions
-(IBAction)newDoc:(id)sender;
-(IBAction)openDoc:(id)sender;
-(IBAction)saveAll:(id)sender;

// MARK: Notifications
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)__applicationShouldTerminateAfterReviewingAllWindows:(NSApplication*)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
@end
