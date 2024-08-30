#import "SVRDocumentViewController.h"

@implementation SVRDocumentViewController

// MARK: Interface Builder
/*@IBOutlet*/-(NSTextView*)textView;
{
  return _textView; 
}
/*@IBOutlet*/-(SVRDocumentModelController*)model;
{
  return _model;
}
// @IBAction
-(void)append:(NSButton*)sender
{
  NSNumber *error = nil;
  NSString *toAppend = [self __mapKeyWithTag:[sender tag]];
  if (toAppend) {
    [[self model] appendCharacter:toAppend error:&error];
    if (error) { NSLog(@"%@ appendString:%@ forTag:%d error:%@",
                       self, toAppend, [sender tag], error); }
  } else {
    [[self model] backspaceWithError:&error];
    if (error) { NSLog(@"%@ backspaceWithTag:%d error:%@",
                       self, [sender tag], error); }
  }
}

// Returns NIL if backspace
// NSAssert if unknown tag
-(NSString*)__mapKeyWithTag:(int)tag;
{
  switch (tag) {
    case  1: return @"1";
    case  2: return @"2";
    case  3: return @"3";
    case  4: return @"4";
    case  5: return @"5";
    case  6: return @"6";
    case  7: return @"7";
    case  8: return @"8";
    case  9: return @"9";
    case 10: return @"0";
    case 11: return @"-";
    case 12: return @".";
    case 13: return nil;
    case 14: return @"=";
    case 15: return [[SVRMathString operatorEncodeMap] objectForKey:@"+"];
    case 16: return [[SVRMathString operatorEncodeMap] objectForKey:@"-"];
    case 17: return @")";
    case 18: return [[SVRMathString operatorEncodeMap] objectForKey:@"*"];
    case 19: return [[SVRMathString operatorEncodeMap] objectForKey:@"/"];
    case 20: return @"(";
    case 21: return [[SVRMathString operatorEncodeMap] objectForKey:@"^"];
    case 22: break;
    case 23: break;
  }
  NSAssert2(NO, @"<%@> Button with unknown tag: %d", self, tag);
  return nil;
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
  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(modelRenderDidChangeNotification:)
           name:[SVRDocumentModelController renderDidChangeNotificationName] 
         object:[self model]];

  NSLog(@"%@", self);
}

// MARK: Dealloc
-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
