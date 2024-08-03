#import <AppKit/AppKit.h>
#import "SVRMathString.h"

@interface SVRTapeModel: NSObject
{
  SVRMathString *_mathString;
  NSAttributedString *_latestRender;
}

// MARK: Properties
-(SVRMathString*)mathString;
-(void)setMathString:(SVRMathString*)aString;
-(NSAttributedString*)latestRender;
-(void)setLatestRender:(NSAttributedString*)aString;
+(NSString*)renderDidChangeNotificationName;

// MARK: Usage
-(void)appendString:(NSString*)aString;
-(void)backspace;

@end