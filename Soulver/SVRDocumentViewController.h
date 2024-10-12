#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "SVRCrossPlatform.h"

@interface SVRDocumentViewController : NSObject
{
  id _modelController;
  id _textView;
}

// MARK: Interface Builder
/*@IBOutlet*/-(SVRDocumentModelController*)modelController;
/*@IBOutlet*/-(NSTextView*)textView;
/*@IBAction*/-(void)append:(NSButton*)sender;

// MARK: Private
-(void)__append:(XPInteger)tag;
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;

@end
