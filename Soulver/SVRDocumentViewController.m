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
  [self __append:[sender tag]];
}

// MARK: Properties
-(NSString*)description;
{
  return [super description];
}

// MARK: Private
-(void)__append:(XPInteger)tag;
{
  int control;
  NSNumber *error = nil;
  NSString *toAppend = [self __mapKeyWithTag:tag control:&control];
  if (toAppend) {
    [[self model] appendCharacter:toAppend error:&error];
    if (error != nil) { NSLog(@"%@ appendString:%@ forTag:%ld error:%@",
                                self, toAppend, tag, error); }
  } else {
    switch (control) {
      case -1: [[self model] backspaceCharacterWithError:&error]; break;
      case -2: [[self model] backspaceLineWithError:&error]; break;
      case -3: [[self model] backspaceAllWithError:&error]; break;
      default: NSAssert2(NO, @"<%@> Button with unknown tag: %ld", self, tag);
    }
    
    if (error != nil) { NSLog(@"%@ backspaceWithTag:%ld error:%@",
                                self, tag, error); }
  }
}

// Returns NIL if backspace
// NSAssert if unknown tag
-(NSString*)__mapKeyWithTag:(XPInteger)tag control:(int*)control;
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
    case 13: *control = -1; return nil;
    case 14: return @"=";
    case 15: return [[SVRMathString operatorEncodeMap] objectForKey:@"+"];
    case 16: return [[SVRMathString operatorEncodeMap] objectForKey:@"-"];
    case 17: return @")";
    case 18: return [[SVRMathString operatorEncodeMap] objectForKey:@"*"];
    case 19: return [[SVRMathString operatorEncodeMap] objectForKey:@"/"];
    case 20: return @"(";
    case 21: return [[SVRMathString operatorEncodeMap] objectForKey:@"^"];
    case 22: *control = -2; return nil;
    case 23: *control = -3; return nil;
  }
  NSAssert2(NO, @"<%@> Button with unknown tag: %ld", self, tag);
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
  [XPLog extra:@"DEALLOC: %@", self];
  _model = nil;
  _textView = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
