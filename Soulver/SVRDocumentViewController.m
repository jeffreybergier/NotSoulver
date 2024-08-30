#import "SVRDocumentViewController.h"

@implementation SVRDocumentViewController

// MARK: Interface Builder
/*@IBOutlet*/-(NSTextView*)textView;
{
  return textView; 
}
/*@IBOutlet*/-(SVRDocumentModelController*)model;
{
  return model;
}
// @IBAction
-(void)append:(NSButton*)sender
{
  NSString *title = [sender title];
  NSNumber *error = nil;
  if ([title isEqualToString:@"<-"]) {
    [[self model] backspaceWithError:&error];
  } else {
    [[self model] appendCharacter:[sender title] error:&error];
  }
  if (error != nil) {
    NSLog(@"%@: appendError: %@", self, error);
  }

  NSLog(@"Tag: %d", [sender tag]);
}

// MARK: Respond to Notifications
-(void)replaceTapeWithString:(NSAttributedString*)aString;
{
  NSTextStorage *storage = [[self textView] textStorage];
  [storage beginEditing];
  [storage setAttributedString:aString];
  [storage endEditing];
  [[self textView] didChangeText];
}

-(void)modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [self replaceTapeWithString:[[self model] latestRender]];
}

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(modelRenderDidChangeNotification:)
           name:[SVRDocumentModelController renderDidChangeNotificationName] 
         object:[self model]];

}

// MARK: Dealloc
-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
