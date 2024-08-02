#import <AppKit/AppKit.h>
#import "SVRMathNode.h"

@interface SVRTapeModel: NSObject
{
  SVRMathNode *_mathNode;
  NSAttributedString *_latestRender;
}

// MARK: Properties
-(SVRMathNode*)mathNode;
-(void)setMathNode:(SVRMathNode*)aNode;
-(NSAttributedString*)latestRender;
-(void)setLatestRender:(NSAttributedString*)aString;
+(NSString*)renderDidChangeNotificationName;

// MARK: Usage
-(void)append:(SVRMathNode*)aNode;

@end