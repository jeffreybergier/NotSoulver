#import "SVRKeypadViewController.h"
#import "SVRTapeModel.h"

@implementation SVRKeypadViewController

-(SVRTapeModel *)model; { return model; }

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
}

- (void)append:(NSButton*)sender
{
  NSString *title = [sender title];
  if ([title isEqualToString:@"<-"]) {
    [[self model] backspace];
  } else {
    [[self model] appendCharacter:[sender title] error:NULL];
  }
}

@end
