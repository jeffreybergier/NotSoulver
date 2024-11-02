#import "SVRSettingsViewController.h"

@implementation SVRSettingsViewController

-(void)choiceChanged:(NSControl*)sender;
{
  NSLog(@"choiceChanged:%@", sender);
}

-(void)valueChanged:(NSControl*)sender;
{
  NSLog(@"valueChanged:%@", sender);
}

-(void)valueReset:(NSControl*)sender;
{
  NSLog(@"valueReset:%@", sender);
}

@end
