#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "SVRDocumentTextDelegate.h"

@interface SVRDocumentViewController : NSObject
{
  id _model;
  id _textView;
  id _textDelegate;
}

// MARK: Interface Builder
/*@IBOutlet*/-(SVRDocumentModelController*)model;
/*@IBOutlet*/-(NSTextView*)textView;
/*@IBOutlet*/-(SVRDocumentTextDelegate*)textDelegate;
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
