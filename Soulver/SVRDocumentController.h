#import <AppKit/AppKit.h>
#import "SVRTapeModel.h"

@interface SVRDocumentController : NSObject
{
    SVRTapeModel *_model;
    NSWindow *_window;
    NSString *_filePath;
}

// MARK: Properties
-(NSString*)filePath;
-(void)setFilePath:(NSString*)aPath;
-(NSWindow*)window;
-(SVRTapeModel*)model;

// MARK: INIT
-(id)initWithFilePath:(NSString*)aPath;
+(id)controllerWithFilePath:(NSString*)aPath;

// PRIVATE
-(void)__updateWindowState;


@end
