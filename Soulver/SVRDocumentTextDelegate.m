#import "SVRDocumentTextDelegate.h"
#import "SVRCrossPlatform.h"

@implementation SVRDocumentTextDelegate

-(void)awakeFromNib
{
  [XPLog debug:@"%@ awakeFromNib", self];
}

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageWillProcessEditing: `%@`", self, [storage string]];
}

-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
}

@end
