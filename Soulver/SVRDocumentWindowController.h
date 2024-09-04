#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"

@interface SVRDocumentWindowController: NSResponder
{
  NSString *_filename;
  SVRDocumentModelController *_model;
  NSWindow *_window;
  NSObject *_viewController;
}

// MARK: Notifications
+(NSString*)documentDidSaveAsNotification;

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

// PRIVATE
-(void)__updateWindowState;
-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;
-(unsigned long)__onDiskHash;
-(BOOL)__needsSaving;
-(NSString*)__runSavePanel;

@end

// MARK: SVRDocumentWindowController
@interface SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
@end

// MARK: NSMenuActionResponder
@interface SVRDocumentWindowController (NSMenuActionResponder)
-(void)keyUp:(NSEvent*)theEvent; // delete in the future
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(void)cut:(id)sender;
-(void)copy:(id)sender;
-(void)paste:(id)sender;
-(void)revertToSaved:(id)sender;
-(void)save:(id)sender;
-(void)saveAs:(id)sender;
-(void)saveTo:(id)sender;
@end
