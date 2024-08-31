#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"

@interface SVRDocumentViewController : NSObject
{
    id _model;
    id _textView;
}

// MARK: Interface Builder
/*@IBOutlet*/-(NSTextView*)textView;
/*@IBOutlet*/-(SVRDocumentModelController*)model;
/*@IBAction*/-(void)append:(NSButton*)sender;
-(NSString*)__mapKeyWithTag:(long)tag;

// MARK: Properties
-(NSString*)description;

// MARK: Respond to Notifications
-(void)replaceTapeWithString:(NSAttributedString*)aString;
-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end
