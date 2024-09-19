#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "SVRTextStorageController.h"

@interface SVRDocumentViewController : NSObject
{
  id _model;
  id _textController;
  id _textView;
}

// MARK: Interface Builder
/*@IBOutlet*/-(NSTextView*)textView;
/*@IBOutlet*/-(SVRTextStorageController*)textController;
/*@IBOutlet*/-(SVRDocumentModelController*)model;
/*@IBAction*/-(void)append:(NSButton*)sender;

// MARK: Properties
-(NSString*)description;

// MARK: Private
-(void)__append:(XPInteger)tag;
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;

// MARK: Respond to Notifications
-(void)replaceTapeWithString:(NSAttributedString*)aString;
-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end
