#import "SVRKeypadViewController.h"

@implementation SVRKeypadViewController

- (void)append:(NSButton *)sender
{
  NSLog(@"Clicked: %@", [sender title]);
}

@end
