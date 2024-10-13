#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "XPDocument.h"
#import "SVRDocumentModelController.h"
#import "SVRDocumentViewController.h"

@interface SVRDocument: XPDocument
{
  IBOutlet SVRDocumentModelController *_modelController;
  IBOutlet SVRDocumentViewController *_viewController;
}

-(NSString*)windowNibName;
-(NSObject*)viewController;
-(SVRDocumentModelController*)modelController;

// MARK: INIT
-(id)initWithContentsOfFile:(NSString*)fileName;
+(id)documentWithContentsOfFile:(NSString*)fileName;

@end
