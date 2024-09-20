#import <AppKit/AppKit.h>
#import "SVRMathString2.h"

#if OS_OPENSTEP
@interface SVRDocumentTextDelegate: NSObject
#else
@interface SVRDocumentTextDelegate: NSObject <NSTextStorageDelegate>
#endif

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;

@end
