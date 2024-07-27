#import "SVRTapeViewController.h"
#import "SVRTapeModel.h"

@implementation SVRTapeViewController

// MARK: Properties
-(NSTextField *)textField; { return textField; }
-(SVRTapeModel *)model;    { return model; }

-(void)awakeFromNib; 
{
  NSLog(@"%@", self);
}

@end
