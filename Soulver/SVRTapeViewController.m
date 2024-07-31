#import "SVRTapeViewController.h"
#import "SVRTapeModel.h"

@implementation SVRTapeViewController

// MARK: Properties
-(NSTextField *)textField; { return textField; }
-(SVRTapeModel *)model;    { return model; }

-(void)awakeFromNib; 
{
  NSLog(@"%@", self);
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelRenderDidChangeNotification:) 
                                               name:[SVRTapeModel renderDidChangeNotificationName] 
                                             object:nil];

}

-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [[self textField] setStringValue:[aNotification object]];
}

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
