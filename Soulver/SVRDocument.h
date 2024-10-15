#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "XPDocument.h"
#import "SVRDocumentViewController.h"

@interface SVRDocument: XPDocument
{
  IBOutlet SVRDocumentViewController *_viewController;
  NSTextStorage *_model;
}

// MARK: Properties
-(SVRDocumentViewController*)viewController;
-(NSTextStorage*)model;
-(NSString*)windowNibName;
-(void)replaceModelWithRawData;

// MARK: INIT
-(id)initWithContentsOfFile:(NSString*)fileName;
+(id)documentWithContentsOfFile:(NSString*)fileName;

// MARK: NSDocument subclass
-(void)awakeFromNib;
-(void)setRawData:(NSData*)rawData;
-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;

@end
