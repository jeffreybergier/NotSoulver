#import <AppKit/AppKit.h>

@interface SVRTapeViewController : NSObject
{
    id model;
    id textField;
}

-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end
