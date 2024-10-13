#import <AppKit/AppKit.h>
#import "SVRDocument.h"

@interface SVRAppDelegate: NSObject
{
  NSMutableDictionary *_openFiles;
  NSMutableArray *_openUnsaved;
}

// MARK: Properties
-(NSMutableDictionary*)openFiles;
-(NSMutableArray*)openUnsaved;
-(NSEnumerator*)openDocumentEnumerator;

// MARK: Document Management
-(void)newDoc:(id)sender;
-(void)openDoc:(id)sender;
-(void)saveAll:(id)sender;
-(void)__saveAll:(id)sender;

// MARK: Notifications
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
-(void)__documentDidChangeFilenameNotification:(NSNotification*)aNotification;
-(void)__documentWillClose:(SVRDocument*)document;
-(void)__document:(SVRDocument*)document didChangeOldFilename:(NSString*)oldFilename;

@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
@end

@interface MultiEnumerator: NSEnumerator
{
  NSArray *_allCollections;
  XPUInteger _currentIndex;
  NSEnumerator *_currentEnumerator;
}
-(id)nextObject;
-(id)initWithCollections:(NSArray*)collections;
+(id)enumeratorWithCollections:(NSArray*)collections;
@end
