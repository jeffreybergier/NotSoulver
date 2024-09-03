#import <AppKit/AppKit.h>

@interface SVRAppDelegate: NSObject
{
  NSMutableDictionary *_openFiles;
  NSMutableDictionary *_openUnsaved;
}

// MARK: Properties
-(NSMutableDictionary*)openFiles;
-(NSMutableDictionary*)openUnsaved;

// MARK: Document Management
-(void)newDoc:(id)sender;
-(void)openDoc:(id)sender;
-(void)saveAll:(id)sender;

// MARK: Notifications
-(void)closeDoc:(NSNotification*)aNotification;

@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
@end