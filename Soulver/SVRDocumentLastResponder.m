#import "SVRDocumentLastResponder.h"

@implementation SVRDocumentLastResponder

-(SVRDocumentWindowController*)windowController;
{
  return _windowController;
}

@end

@implementation SVRDocumentLastResponder (NSMenuActionResponder)

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  NSLog(@"validateMenuItem: %@", menuItem);
  return YES;
}

-(void)cut:(NSMenuItem*)menuItem;
{
  NSLog(@"cut: %@", menuItem);
}

-(void)copy:(NSMenuItem*)menuItem;
{
  NSLog(@"copy: %@", menuItem);
}

-(void)paste:(NSMenuItem*)menuItem;
{
  NSLog(@"paste: %@", menuItem);
}

@end
