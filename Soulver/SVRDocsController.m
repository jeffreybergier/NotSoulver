#import "SVRDocsController.h"
#import "SVRDocumentController.h"

@implementation SVRDocsController

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
}

- (void)closeDoc:(id)sender
{
}

- (void)newDoc:(id)sender
{
  SVRDocumentController *newDoc = [[SVRDocumentController alloc] initWithFilePath:nil];
}

- (void)openDoc:(id)sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel runModalForTypes:[NSArray arrayWithObjects:@"solv", nil]];
}

- (void)saveDoc:(id)sender
{
}

@end
