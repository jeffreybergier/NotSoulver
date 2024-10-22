#import "SVRDocumentViewController.h"
#import "SVRSinglePaneLayoutManager.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRDocumentViewController

// MARK: Init
-(id)init;
{
  self = [super init];
  _modelController = [[SVRDocumentModelController alloc] init];
  _textView = nil;
  return self;
}

// MARK: awakeFromNib
-(void)awakeFromNib;
{
  NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
  SVRDocumentModelController *modelController = [self modelController];
  NSTextStorage *model = [modelController model];
  NSTextView *textView = [self textView];
  
  // Configure delegates
  [modelController setTextView:textView];
  [textView setDelegate:modelController];
  
  // Configure layoutManager
  // This ordering is incredibly fragile
  [[textView textContainer] replaceLayoutManager:layoutManager];
  [layoutManager replaceTextStorage:model];
  
  // Configure the text view
  [textView setTypingAttributes:[self __typingAttributes]];
}

// MARK: IBActions
-(IBAction)keypadAppend:(id)sender;
{
  [self __append:[sender tag]];
}

// MARK: Interface Builder

-(NSTextView*)textView;
{
  return [[_textView retain] autorelease];
}

-(SVRDocumentModelController*)modelController;
{
  return [[_modelController retain] autorelease];
}

-(IBAction)append:(NSButton*)sender
{
  [self __append:[sender tag]];
}

// MARK: Private
-(void)__append:(XPInteger)tag;
{
  int control = 0;
  NSString *toAppend = [self __mapKeyWithTag:tag control:&control];
  if (toAppend) {
    [[self modelController] appendCharacter:toAppend];
  } else {
    switch (control) {
      case -1: [[self modelController] backspaceCharacter]; break;
      case -2: [[self modelController] backspaceLine]; break;
      case -3: [[self modelController] backspaceAll]; break;
      default: [XPLog error:@"%@ Button with unknown tag: %ld", self, tag];
    }
  }
}

// Returns NIL if backspace
// Exception if unknown tag
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
    case 14: return @"=\n";
    case 15: return @"+";
    case 16: return @"-";
    case 17: return @")";
    case 18: return @"*";
    case 19: return @"/";
    case 20: return @"(";
    case 21: return @"^";
    case 13:
      // Backspace Button
      *control = -1;
      return nil;
    case 22:
      // Clear Line Button
      *control = -2;
      return nil;
    case 23:
      // Clear All Button
      *control = -3;
      return nil;
  }
  [XPLog error:@"<%@> Button with unknown tag: %ld", self, tag];
  return nil;
}

-(NSDictionary*)__typingAttributes;
{
  NSUserDefaults *ud;
  NSArray *keys;
  NSArray *vals;
  
  ud = [NSUserDefaults standardUserDefaults];
  keys = [NSArray arrayWithObjects:
          NSFontAttributeName,
          NSForegroundColorAttributeName,
          nil];
  vals = [NSArray arrayWithObjects:
          [ud SVR_fontForText],
          [ud SVR_colorForText],
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Dealloc
-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_modelController release];
  _modelController = nil;
  _textView = nil;
  [super dealloc];
}

@end
