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
  [SVRSolver annotateStorage:storage];
  [SVRSolver solveAnnotatedStorage:storage];
}

-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
  [SVRSolver colorAnnotatedAndSolvedStorage:storage];
}

-(void)textDidBeginEditing:(NSNotification*)aNotification;
{
  [XPLog debug:@"%@ textDidBeginEditing", self];
}

-(void)textDidEndEditing:(NSNotification*)aNotification;
{
  [XPLog debug:@"%@ textDidEndEditing", self];
}

@end
