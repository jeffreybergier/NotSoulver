#import "SVRKeypadViewController.h"
#import "SVRMathStringModelController.h"

@implementation SVRKeypadViewController

-(SVRMathStringModelController*)model; { return model; }

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

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [super dealloc];
}

@end
