#import <AppKit/AppKit.h>
#import "SVRTapeModel.h"

@interface SVRDocumentController : NSObject
{
    SVRTapeModel *_model;
    NSWindow *_window;
    NSString *_filename;
}

// MARK: Properties
-(NSString*)filename;
-(void)setFilename:(NSString*)filename;
-(NSWindow*)window;
-(SVRTapeModel*)model;

// MARK: INIT
-(id)initWithFilename:(NSString*)filename;
+(id)controllerWithFilename:(NSString*)filename;

// MARK: Saving
-(BOOL)saveDocument;

// PRIVATE
-(void)__updateWindowState;
-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;


@end
