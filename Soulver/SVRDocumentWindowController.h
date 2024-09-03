#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"

@interface SVRDocumentWindowController: NSObject
{
  NSString *_filename;
  SVRDocumentModelController *_model;
  NSWindow *_window;
  NSObject *_viewController;
  NSResponder *_lastResponder;
}

// MARK: Properties
-(NSString*)filename;
-(void)setFilename:(NSString*)filename;
-(NSWindow*)window;
-(SVRDocumentModelController*)model;
-(NSObject*)viewController;
-(NSResponder*)lastResponder;
-(NSString*)description;

// MARK: INIT
-(id)initWithFilename:(NSString*)filename;
+(id)controllerWithFilename:(NSString*)filename;

// MARK: Saving
-(BOOL)saveDocument;
+(NSString*)windowDidCloseNotification;

// PRIVATE
-(void)__updateWindowState;
-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;

@end

@interface SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
@end
