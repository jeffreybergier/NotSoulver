#import "SVRTapeViewController.h"
#import "SVRTapeModel.h"

@implementation SVRTapeViewController

// MARK: Properties
-(NSTextView*)textView; { return textView; }
-(SVRTapeModel*)model;   { return model; }

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
  [self replaceTapeWithString:[aNotification object]];
}

-(void)replaceTapeWithString:(NSString*)aString;
{
  NSTextStorage *storage = [[self textView] textStorage];
  [storage beginEditing];
  [[storage mutableString] setString:aString];
  [storage endEditing];
  [[self textView] didChangeText];
}

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
