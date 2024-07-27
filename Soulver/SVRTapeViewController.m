#import "SVRTapeViewController.h"
#import "SVRTapeModel.h"

@implementation SVRTapeViewController

// MARK: Properties
-(NSTextField *)textField; { return textField; }
-(SVRTapeModel *)model;    { return model; }

-(void)awakeFromNib; 
{
  NSLog(@"Hello World");
  NSLog(@"%@", [self textField]);
  NSLog(@"%@", [self model]);
}

@end
