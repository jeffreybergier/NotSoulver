#import "SVRTextStorageController.h"
#import "SVRCrossPlatform.h"

@implementation SVRTextStorageController

-(SVRMathString2*)mathString;
{
  return _mathString;
}

-(void)awakeFromNib
{
  _mathString = [[SVRMathString2 alloc] init];
  [XPLog debug:@"%@ awakeFromNib", self];
}

-(void)textStorageDidProcessEditing:(NSNotification*)aNotification
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
  [[self mathString] setExpressionString:[storage string]];
  [storage beginEditing];
  [storage setAttributedString:[[self mathString] coloredExpressionString]];
  [storage endEditing];
}

@end
