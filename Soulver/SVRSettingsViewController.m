#import "SVRSettingsViewController.h"

@implementation SVRSettingsViewController

-(void)awakeFromNib;
{
  [_groupFontView retain];
  [_groupColorView retain];
  [_groupGeneralView retain];
  
  [self choiceChanged:_settingsChooser];
  NSLog(@"%@ awakeFromNib", self);
}

-(void)choiceChanged:(NSPopUpButton*)sender;
{
  NSView *contentView = [_window contentView];
  XPInteger selection = [sender indexOfSelectedItem];
  
  [XPLog debug:@"choiceChanged:%@(%ld)", sender, selection];
  
  [_groupFontView removeFromSuperview];
  [_groupColorView removeFromSuperview];
  [_groupGeneralView removeFromSuperview];
  
  switch (selection) {
    case 0: // General
      [contentView addSubview:_groupGeneralView];
      break;
    case 1: // Colors
      [contentView addSubview:_groupColorView];
      break;
    case 2: // Fonts
      [contentView addSubview:_groupFontView];
      break;
    default:
      return;
  }
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
