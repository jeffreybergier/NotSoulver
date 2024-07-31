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
  SVRMathNode *node = [SVRMathNode nodeWithValue:[sender title]];
  [[self model] append:node];
}

@end
