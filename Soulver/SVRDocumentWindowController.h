#import <AppKit/AppKit.h>
#import "SVRDocumentModelController.h"

@interface SVRDocumentWindowController: NSObject
{
    SVRDocumentModelController *_model;
    NSWindow *_window;
    NSString *_filename;
}

// MARK: Properties
-(NSString*)filename;
-(void)setFilename:(NSString*)filename;
-(NSWindow*)window;
-(SVRDocumentModelController*)model;

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
