#import <AppKit/AppKit.h>
#import "SVRMathString.h"

@interface SVRDocumentModelController: NSObject
{
  SVRMathString *_mathString;
  NSAttributedString *_latestRender;
}

// MARK: Properties
+(NSString*)renderDidChangeNotificationName;
-(SVRMathString*)mathString;
-(void)setMathString:(SVRMathString*)mathString;
-(NSAttributedString*)latestRender;
-(void)setLatestRender:(NSAttributedString*)aString;
-(NSString*)description;

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)errorPointer;
-(int)backspaceCharacterWithError:(NSNumber**)errorPointer;
-(int)backspaceLineWithError:(NSNumber**)errorPointer;
-(int)backspaceAllWithError:(NSNumber**)errorPointer;

@end
