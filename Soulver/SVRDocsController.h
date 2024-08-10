#import <AppKit/AppKit.h>

@interface SVRDocsController : NSObject
{
  NSMutableDictionary *_openFiles;
  NSMutableDictionary *_openUnsaved;
}

// MARK: Properties
-(NSMutableDictionary*)openFiles;
-(NSMutableDictionary*)openUnsaved;

// MARK: IBActions
-(void)newDoc:(id)sender;
-(void)openDoc:(id)sender;
-(void)saveDoc:(id)sender;

// MARK: Notifications
-(void)closeDoc:(NSNotification*)aNotification;

@end

@interface SVRDocsController (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)application:(NSApplication *)sender openTempFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
-(BOOL)application:(id)sender openFileWithoutUI:(NSString *)filename;
@end