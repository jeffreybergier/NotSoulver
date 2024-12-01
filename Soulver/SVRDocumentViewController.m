//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "SVRDocumentViewController.h"
#import "NSUserDefaults+Soulver.h"
#import "SVRSolver.h"

NSString *SVRDocumentViewControllerUnsolvedPasteboardType = @"com.saturdayapps.notsoulver.unsolved";

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
  [self themeDidChangeNotification:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(themeDidChangeNotification:)
                                               name:SVRThemeDidChangeNotificationName
                                             object:nil];
  
  // Announce
  XPLogDebug1(@"awakeFromNib: %@", self);
}

-(void)themeDidChangeNotification:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSTextView *textView = [self textView];
  [textView setTypingAttributes:[self __typingAttributes]];
  [textView setBackgroundColor:[ud SVR_colorForTheme:SVRThemeColorBackground]];
  [textView setInsertionPointColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint]];
  if (aNotification){
    [[self modelController] waitTimerFired:nil];
  }
  [textView setNeedsDisplay:YES];
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
      default: XPLogRaise2(@"%@ Button with unknown tag: %ld", self, tag);
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
  XPLogRaise2(@"<%@> Button with unknown tag: %ld", self, tag);
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
          [ud SVR_fontForTheme:SVRThemeFontOther],
          [ud SVR_colorForTheme:SVRThemeColorOtherText],
          nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Dealloc
-(void)dealloc;
{
  XPLogDebug1(@"DEALLOC: %@", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_modelController release];
  _modelController = nil;
  _textView = nil;
  [super dealloc];
}

@end

@implementation SVRDocumentViewController (IBActions)

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  SEL menuAction;
  NSRange selectedRange = XPNotFoundRange;
  BOOL canCopy  = NO;
  BOOL canPaste = NO;
  
  menuAction = [menuItem action];
  selectedRange = [[self textView] selectedRange];
  canCopy  = !XPIsNotFoundRange(selectedRange) && selectedRange.length > 0;
  canPaste = !XPIsNotFoundRange(selectedRange);
  
  if        (menuAction == @selector(copyUnsolved:)) {
    return canCopy;
  } else if (menuAction == @selector(copyUniversal:)) {
    return canCopy;
  } else if (menuAction == @selector(cutUnsolved:)) {
    return canCopy;
  } else if (menuAction == @selector(cutUniversal:)) {
    return canCopy;
  } else if (menuAction == @selector(pasteUniversal:)) {
    return canPaste;
  }

  return NO;
}

-(IBAction)cutUnsolved:(id)sender;
{
  NSRange range = [[self textView] selectedRange];
  [self copyUnsolved:sender];
  [[self modelController] deleteCharactersInRange:range];
}
-(IBAction)cutUniversal:(id)sender;
{
  NSRange range = [[self textView] selectedRange];
  [self copyUniversal:sender];
  [[self modelController] deleteCharactersInRange:range];
}

-(IBAction)copyUnsolved:(id)sender;
{
  BOOL success = NO;
  NSRange range = [[self textView] selectedRange];
  NSAttributedString *original = [[[self modelController] model] attributedSubstringFromRange:range];
  NSAttributedString *unsolved = [SVRSolver replaceAttachmentsWithOriginalCharacters:original];
  success = [self __copyUnsolvedAttributedString:unsolved];
  if (success) { return; }
  XPLogPause2(@"%@ copySolved: Failed: %@", self, [unsolved string]);
}

-(IBAction)copyUniversal:(id)sender;
{
  BOOL success = NO;
  NSRange range = [[self textView] selectedRange];
  NSAttributedString *original = [[[self modelController] model] attributedSubstringFromRange:range];
  NSAttributedString *solved = [SVRSolver replaceAttachmentsWithStringValue:original];
  NSAttributedString *unsolved = [SVRSolver replaceAttachmentsWithOriginalCharacters:original];
  success = [self __universalCopySolvedAttributedString:solved andUnsolvedString:[unsolved string]];
  if (success) { return; }
  XPLogPause2(@"%@ copySolved: Failed: %@", self, [solved string]);
}

-(IBAction)pasteUniversal:(id)sender;
{
  NSString *specialType = SVRDocumentViewControllerUnsolvedPasteboardType;
  NSTextView *textView = [self textView];
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSString *unsolvedString = nil;
  
  if ([pb availableTypeFromArray:[NSArray arrayWithObject:specialType]]
      && (unsolvedString = [pb stringForType:specialType]))
  {
    // Do Universal Paste
    XPLogDebug1(@"%@ pasteUniversal: Universal Paste", self);
    [[self modelController] replaceCharactersInRange:[textView selectedRange]
                                          withString:unsolvedString];
  } else {
    // Fail universal paste and forward the message to the textview
    XPLogDebug1(@"%@ pasteUniversal: NOT Universal Paste", self);
    [textView pasteAsPlainText:sender];
    return;
  }
}

-(BOOL)__copyUnsolvedAttributedString:(NSAttributedString*)unsolvedString;
{
  BOOL successPlain = NO;
  BOOL successRTF   = NO;
  NSRange range = NSMakeRange(0, [unsolvedString length]);
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  
  [pb declareTypes:[NSArray arrayWithObjects:
                    XPPasteboardTypeRTF,
                    XPPasteboardTypeString,
                    nil]
             owner:nil];
  
  // Attributes dictionary might be needed in OSX
  // [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
  successRTF = [pb setData:[unsolvedString RTFFromRange:range documentAttributes:nil]
                   forType:XPPasteboardTypeRTF];
  successPlain = [pb setString:[unsolvedString string] forType:XPPasteboardTypeString];
  
  return successRTF && successPlain;
}

-(BOOL)__universalCopySolvedAttributedString:(NSAttributedString*)solvedString
                           andUnsolvedString:(NSString*)unsolvedString;
{
  BOOL successRTF = NO;
  BOOL successPlain = NO;
  BOOL successUnsolved = NO;
  NSRange range = NSMakeRange(0, [solvedString length]);
  NSString *specialType = SVRDocumentViewControllerUnsolvedPasteboardType;
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  
  [pb declareTypes:[NSArray arrayWithObjects:
                    XPPasteboardTypeRTF,
                    XPPasteboardTypeString,
                    specialType,
                    nil]
             owner:nil];
  
  // Attributes dictionary might be needed in OSX
  // [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
  successRTF = [pb setData:[solvedString RTFFromRange:range documentAttributes:nil]
                   forType:XPPasteboardTypeRTF];
  successPlain    = [pb setString:[solvedString string] forType:XPPasteboardTypeString];
  successUnsolved = [pb setString:unsolvedString forType:specialType];
  
  return successRTF && successPlain && successUnsolved;
}

@end
