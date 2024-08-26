#import "SVRTapeViewController.h"
#import "SVRMathStringModelController.h"

@implementation SVRTapeViewController

// MARK: Properties
-(NSTextView*)textView; 
{ 
  return textView; 
}
-(SVRMathStringModelController*)model;
{ 
  return model;
}

-(void)awakeFromNib; 
{
  NSLog(@"%@", self);
  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(modelRenderDidChangeNotification:)
           name:[SVRMathStringModelController renderDidChangeNotificationName] 
         object:[self model]];

}

-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [self replaceTapeWithString:[[self model] latestRender]];
}

-(void)replaceTapeWithString:(NSAttributedString*)aString;
{
  NSTextStorage *storage = [[self textView] textStorage];
  [storage beginEditing];
  [storage setAttributedString:aString];
  [storage endEditing];
  [[self textView] didChangeText];
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
