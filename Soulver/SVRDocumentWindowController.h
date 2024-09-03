#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"

@interface SVRDocumentWindowController: NSResponder
{
  NSString *_filename;
  SVRDocumentModelController *_model;
  NSWindow *_window;
  NSObject *_viewController;
}

// MARK: Properties
-(NSString*)filename;
-(void)setFilename:(NSString*)filename;
-(NSWindow*)window;
-(SVRDocumentModelController*)model;
-(NSObject*)viewController;
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

// MARK: SVRDocumentWindowController
@interface SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
@end

// MARK: NSMenuActionResponder
@interface SVRDocumentWindowController (NSMenuActionResponder)
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(void)cut:(NSMenuItem*)menuItem;
-(void)copy:(NSMenuItem*)menuItem;
-(void)paste:(NSMenuItem*)menuItem;
-(void)save:(NSMenuItem*)menuItem;
-(void)saveAs:(NSMenuItem*)menuItem;
-(void)keyUp:(NSEvent*)theEvent;
@end
