#import <AppKit/AppKit.h>
#import "SVRMathString.h"

@interface SVRDocumentModelController: NSObject
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
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)errorPointer;
-(int)backspaceWithError:(NSNumber**)errorPointer;

@end
