#import "SVRDocumentModelController.h"
#import "SVRSolver.h"

@implementation SVRDocumentModelController

// MARK: Properties
-(NSTextStorage*)model;
{
  return [[_model retain] autorelease];
}

-(NSTextView*)textView;
{
  return [[_textView retain] autorelease];
}

-(void)setTextView:(NSTextView*)textView;
{
  _textView = textView;
}

// MARK: Init
-(id)init;
{
  self = [super init];
  _model = [NSTextStorage new];
  _textView = nil;
  _waitTimer = nil;
  return self;
}

// MARK: NSDocument Support
-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[[self model] string] dataUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  BOOL success = NO;
  NSTextStorage *model = [self model];
  NSString *string = [
    [[NSString alloc] initWithData:data
                          encoding:NSUTF8StringEncoding]
    autorelease];
  if (string) {
    [XPLog debug:@"%@ loadDataRepresentation: Rendering", self];
    [model beginEditing];
    [[model mutableString] setString:string];
    [SVRSolver removeAllSolutionsAndTags:model];
    [SVRSolver solveAndTagAttributedString:model];
    [SVRSolver styleSolvedAndTaggedAttributedString:model];
    [model endEditing];
    success = YES;
  }
  return success;
}

// MARK: Usage
-(void)appendCharacter:(NSString*)aString;
{
  NSTextStorage *model = [self model];
  [ model beginEditing];
  [[model mutableString] appendString:aString];
  [ model endEditing];
  [self textDidChange:nil];
}

-(void)backspaceCharacter;
{
  NSRange lastCharacter = XPNotFoundRange;
  NSTextStorage *model = [self model];
  XPUInteger length = [[model mutableString] length];
  if (length == 0) { return; }
  
  lastCharacter = NSMakeRange(length-1, 1);
  [ model beginEditing];
  [[model mutableString] deleteCharactersInRange:lastCharacter];
  [ model endEditing];
  [self textDidChange:nil];
}

-(void)backspaceLine;
{
  [XPLog pause:@"Unimplemented"];
}

-(void)backspaceAll;
{
  NSTextStorage *model = [self model];
  [ model beginEditing];
  [[model mutableString] setString:@""];
  [ model endEditing];
  [self textDidChange:nil];
}

-(void)dealloc;
{
  [XPLog debug:@"DEALLOC: %@", self];
  [_waitTimer invalidate];
  [_waitTimer release];
  [_model release];
  _textView = nil;
  _waitTimer = nil;
  _model = nil;
  [super dealloc];
}

@end


@implementation SVRDocumentModelController (TextDelegate)

-(void)resetWaitTimer;
{
  [_waitTimer invalidate];
  [_waitTimer release];
  _waitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(waitTimerFired:)
                                              userInfo:nil
                                               repeats:NO];
  [_waitTimer retain];
}

-(void)waitTimerFired:(NSTimer*)timer;
{
  NSTextStorage *model = [self model];
  NSTextView *textView = [self textView];
  NSRange selection = [textView selectedRange];
  
  [XPLog debug:@"%@ waitTimerFired: Rendering", self];
  
  [model beginEditing];
  [SVRSolver removeAllSolutionsAndTags:model];
  [SVRSolver solveAndTagAttributedString:model];
  [SVRSolver styleSolvedAndTaggedAttributedString:model];
  [model endEditing];
  [textView setSelectedRange:selection];

  // Invalidating at the end is important.
  // Otherwise, self could get deallocated mid-method 
  [timer invalidate];
}

-(void)textDidChange:(NSNotification*)notification;
{
  [XPLog extra:@"textDidChange:"];
  [self resetWaitTimer];
}

@end
