#import "SVRKeypadViewController.h"
#import "SVRTapeModel.h"

@implementation SVRKeypadViewController

-(SVRTapeModel *)model; { return model; }

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
}

- (void)append:(NSButton *)sender
{
  NSLog(@"Clicked: %@", [sender title]);
}

@end
