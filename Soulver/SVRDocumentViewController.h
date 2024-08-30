#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"

@interface SVRDocumentViewController : NSObject
{
    id model;
    id textView;
}

// MARK: Interface Builder
/*@IBOutlet*/-(NSTextView*)textView;
/*@IBOutlet*/-(SVRDocumentModelController*)model;
/*@IBAction*/-(void)append:(NSButton*)sender;
-(NSString*)__mapKeyWithTag:(int)tag;

// MARK: Respond to Notifications
-(void)replaceTapeWithString:(NSAttributedString*)aString;
-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end
