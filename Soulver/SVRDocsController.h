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
