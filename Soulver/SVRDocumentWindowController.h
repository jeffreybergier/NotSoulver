#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "XPCrossPlatform.h"
#import "SVRDocumentViewController.h"

@interface SVRDocumentWindowController: NSResponder
{
  IBOutlet SVRDocumentModelController *_model;
  IBOutlet NSWindow *_window;
  IBOutlet SVRDocumentViewController *_viewController;
  NSString *_filename;
  NSArray *_nibTopLevelObjects;
}

// MARK: Nib Name
+(NSString*)nibName;

// MARK: Properties
-(void)setFilename:(NSString*)filename;
-(NSString*)filename;
-(NSWindow*)window;
-(NSObject*)viewController;
-(SVRDocumentModelController*)model;

// MARK: INIT
-(id)initWithFilename:(NSString*)filename;
+(id)controllerWithFilename:(NSString*)filename;

// PRIVATE
-(void)__updateWindowState;
@end

// MARK: SVRDocumentWindowController
@interface SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
@end

// MARK: NSMenuActionResponder
@interface SVRDocumentWindowController (NSMenuActionResponder)
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(IBAction)save:(id)sender;
-(IBAction)saveAs:(id)sender;
-(BOOL)__save;
-(BOOL)__saveAs;
@end
