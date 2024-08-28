#import <AppKit/AppKit.h>
#import "SVRMathStringModelController.h"

@interface SVRDocumentWindowController: NSObject
{
    SVRMathStringModelController *_model;
    NSWindow *_window;
    NSString *_filename;
}

// MARK: Properties
-(NSString*)filename;
-(void)setFilename:(NSString*)filename;
-(NSWindow*)window;
-(SVRMathStringModelController*)model;

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
