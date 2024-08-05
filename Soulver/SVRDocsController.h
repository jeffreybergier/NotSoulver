#import <AppKit/AppKit.h>

@interface SVRDocsController : NSObject
{
  NSMutableDictionary *_openFiles;
  NSMutableArray *_openUnsaved;
}

// MARK: Properties
-(NSMutableDictionary*)openFiles;
-(NSMutableArray*)openUnsaved;

// MARK: IBActions
- (void)closeDoc:(id)sender;
- (void)newDoc:(id)sender;
- (void)openDoc:(id)sender;
- (void)saveDoc:(id)sender;
@end
