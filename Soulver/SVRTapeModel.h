#import <AppKit/AppKit.h>

@interface SVRTapeModel: NSObject
{
  NSMutableArray */*<SVRTapeModelOperation>*/ operations;
  NSMutableString * strokeInput;
}

-(void)appendKeyStroke:(NSString *)aStroke;

@end