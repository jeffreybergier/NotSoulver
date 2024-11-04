#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "XPCrossPlatform.h"

@interface SVRDocumentViewController: NSResponder
{
  mm_unretain IBOutlet NSTextView *_textView;
  mm_new SVRDocumentModelController *_modelController;
}

// MARK: Init
-(id)init;

// MARK: awakeFromNib
-(void)awakeFromNib;
-(void)themeDidChangeNotification:(NSNotification*)aNotification;

// MARK: IBActions
-(IBAction)keypadAppend:(id)sender;

// MARK: Interface Builder
-(NSTextView*)textView;
-(SVRDocumentModelController*)modelController;
-(IBAction)append:(NSButton*)sender;

// MARK: Private
-(void)__append:(XPInteger)tag;
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;
-(NSDictionary*)__typingAttributes;

@end
