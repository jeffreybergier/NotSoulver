#import <AppKit/AppKit.h>

@interface SVRTapeViewController : NSObject
{
    id model;
    id textView;
}

-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;
-(void)replaceTapeWithString:(NSString*)aString;

@end
