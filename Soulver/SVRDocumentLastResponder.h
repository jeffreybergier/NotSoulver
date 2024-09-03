#import <AppKit/AppKit.h>
#import "SVRDocumentWindowController.h"

@interface SVRDocumentLastResponder: NSResponder
{
  SVRDocumentWindowController *_windowController;
}
-(SVRDocumentWindowController*)windowController;
@end

@interface SVRDocumentLastResponder (NSMenuActionResponder)
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(void)cut:(NSMenuItem*)menuItem;
-(void)copy:(NSMenuItem*)menuItem;
-(void)paste:(NSMenuItem*)menuItem;
@end