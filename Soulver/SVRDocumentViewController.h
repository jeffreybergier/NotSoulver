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

// MARK: Properties
-(NSString*)description;

// MARK: Private
-(void)__append:(long)tag;
-(NSString*)__mapKeyWithTag:(long)tag control:(int*)control;

// MARK: Respond to Notifications
-(void)replaceTapeWithString:(NSAttributedString*)aString;
-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end
