#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "XPCrossPlatform.h"

@interface SVRDocumentViewController: NSObject
{
  IBOutlet SVRDocumentModelController *_modelController;
  IBOutlet NSTextView *_textView;
}

// MARK: Interface Builder
-(SVRDocumentModelController*)modelController;
-(NSTextView*)textView;
-(IBAction)append:(NSButton*)sender;

// MARK: Private
-(void)__append:(XPInteger)tag;
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;

@end
