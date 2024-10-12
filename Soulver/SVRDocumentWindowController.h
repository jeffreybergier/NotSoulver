#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"
#import "SVRCrossPlatform.h"

@interface SVRDocumentWindowController: NSResponder
{
  NSString *_filename;
  SVRDocumentModelController *_model;
  NSWindow *_window;
  NSObject *_viewController;
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
-(void)save:(id)sender;
-(void)saveAs:(id)sender;
-(BOOL)__save;
-(BOOL)__saveAs;
@end
