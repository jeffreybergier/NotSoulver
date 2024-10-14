#import "SVRDocumentViewController.h"
#import "SVRSinglePaneLayoutManager.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRDocumentViewController

// MARK: NSDocument Support
-(void)updateModel:(NSTextStorage*)model;
{
  NSLayoutManager *layoutManager = nil;
  
  NSAssert([self textView], @"No Text View");
  
  // Create new modelController
  [_modelController release];
  _modelController = [[SVRDocumentModelController alloc] initWithModel:model];
  
  // Configure layoutManager
  layoutManager = [[[SVRSinglePaneLayoutManager alloc] init] autorelease];
  [layoutManager setTextStorage:model];
  [[[self textView] textContainer] replaceLayoutManager:layoutManager];
  
  // Configure delegates
  [model setDelegate:_modelController];
  [[self textView] setDelegate:_modelController];
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
  NSNumber *error = nil;
  NSString *toAppend = [self __mapKeyWithTag:tag control:&control];
  if (toAppend) {
    [[self modelController] appendCharacter:toAppend error:&error];
    if (error != nil) { [
      XPLog alwys:@"%@ appendString:%@ forTag:%ld error:%@", self, toAppend, tag, error];
    }
  } else {
    switch (control) {
      case -1: [[self modelController] backspaceCharacterWithError:&error]; break;
      case -2: [[self modelController] backspaceLineWithError:&error]; break;
      case -3: [[self modelController] backspaceAllWithError:&error]; break;
      default: [XPLog error:@"%@ Button with unknown tag: %ld", self, tag];
    }
    if (error != nil) {
      [XPLog alwys:@"%@ backspaceWithTag:%ld error:%@", self, tag, error];
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
    case 13: *control = -1; return nil;
    case 14: return @"=";
    case 15: return [[[NSUserDefaults standardUserDefaults] SVR_operatorEncodeMap] objectForKey:@"+"];
    case 16: return [[[NSUserDefaults standardUserDefaults] SVR_operatorEncodeMap] objectForKey:@"-"];
    case 17: return @")";
    case 18: return [[[NSUserDefaults standardUserDefaults] SVR_operatorEncodeMap] objectForKey:@"*"];
    case 19: return [[[NSUserDefaults standardUserDefaults] SVR_operatorEncodeMap] objectForKey:@"/"];
    case 20: return @"(";
    case 21: return [[[NSUserDefaults standardUserDefaults] SVR_operatorEncodeMap] objectForKey:@"^"];
    case 22: *control = -2; return nil;
    case 23: *control = -3; return nil;
  }
  [XPLog error:@"<%@> Button with unknown tag: %ld", self, tag];
  return nil;
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
