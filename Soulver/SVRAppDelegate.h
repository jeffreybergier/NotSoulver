#import <AppKit/AppKit.h>
#import "SVRDocumentWindowController.h"

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
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
-(void)__documentDidChangeFilenameNotification:(NSNotification*)aNotification;
-(void)__documentWillClose:(SVRDocumentWindowController*)document;
-(void)   __document:(SVRDocumentWindowController*)document
didChangeOldFilename:(NSString*)oldFilename;

@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
@end
