#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "XPDocument.h"
#import "SVRDocumentViewController.h"

@interface SVRDocument: XPDocument
{
  IBOutlet SVRDocumentViewController *_viewController;
}

// MARK: Properties
-(SVRDocumentViewController*)viewController;
-(NSString*)windowNibName;

// MARK: INIT
-(id)initWithContentsOfFile:(NSString*)fileName;
+(id)documentWithContentsOfFile:(NSString*)fileName;

// MARK: NSDocument subclass
-(void)awakeFromNib;
-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;

@end
