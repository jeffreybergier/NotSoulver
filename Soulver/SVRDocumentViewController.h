#import <AppKit/AppKit.h>
#import "SVRMathStringModelController.h"

@interface SVRDocumentViewController : NSObject
{
    id model;
    id textView;
}

// MARK: Interface Builder
/*@IBOutlet*/-(NSTextView*)textView;
/*@IBOutlet*/-(SVRMathStringModelController*)model;
/*@IBAction*/-(void)append:(NSButton*)sender;

// MARK: Respond to Notifications
-(void)replaceTapeWithString:(NSAttributedString*)aString;
-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end
