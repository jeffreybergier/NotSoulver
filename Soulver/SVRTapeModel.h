#import <AppKit/AppKit.h>
#import "SVRMathNode.h"

@interface SVRTapeModel: NSObject
{
  SVRMathNode *_mathNode;
  NSString *_latestRender;
}

// MARK: Properties
-(SVRMathNode*)mathNode;
-(void)setMathNode:(SVRMathNode*)aNode;
-(NSString*)latestRender;
-(void)setLatestRender:(NSString*)aString;
+(NSString*)renderDidChangeNotificationName;

// MARK: Usage
-(void)append:(SVRMathNode*)aNode;

@end