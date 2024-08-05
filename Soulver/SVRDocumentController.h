#import <AppKit/AppKit.h>
#import "SVRTapeModel.h"

@interface SVRDocumentController : NSObject
{
    SVRTapeModel *_model;
    NSWindow *_window;
    NSString *_filePath;
}

-(id)initWithFilePath:(NSString*)aPath;

@end
