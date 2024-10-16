#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "XPCrossPlatform.h"

@interface SVRDocumentViewController: NSResponder
{
  IBOutlet NSTextView *_textView;
  SVRDocumentModelController *_modelController;
}

// MARK: Init
-(id)init;

// MARK: awakeFromNib
-(void)awakeFromNib;

// MARK: IBActions
-(IBAction)keypadAppend:(id)sender;

// MARK: Interface Builder
-(NSTextView*)textView;
-(SVRDocumentModelController*)modelController;
-(IBAction)append:(NSButton*)sender;

// MARK: Private
-(void)__append:(XPInteger)tag;
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;

@end
