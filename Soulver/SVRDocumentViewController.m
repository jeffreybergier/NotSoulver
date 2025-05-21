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
-(id)initWithModelController:(SVRDocumentModelController*)modelController;
{
  self = [super init];
  NSCParameterAssert(self);
  NSCParameterAssert(modelController);
  _modelController = [modelController retain];
  _textView = nil;
  _view_42 = nil;
  return self;
}

-(void)loadView;
{
  NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init]                                                 autorelease];
  NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)]   autorelease];
  NSTextView *textView           = [[[NSTextView      alloc] initWithFrame:NSZeroRect textContainer:textContainer] autorelease];
  NSScrollView *scrollView       = [[[NSScrollView    alloc] initWithFrame:NSZeroRect]                             autorelease];
  SVRDocumentModelController *modelController = [self modelController];
  
  NSCParameterAssert(layoutManager);
  NSCParameterAssert(textContainer);
  NSCParameterAssert(textView);
  NSCParameterAssert(scrollView);
  NSCParameterAssert(modelController);
  
  // TextContainer
  [textContainer setWidthTracksTextView:YES];
  [textContainer setHeightTracksTextView:NO];
  
  // ScrollView
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  
  // TextView
  [textView setMinSize:NSMakeSize(0, 0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:YES];
  [textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [textView XP_setAllowsUndo:YES];
  
  // ModelController
  [[modelController model] addLayoutManager:layoutManager];
  [layoutManager addTextContainer:textContainer];
  [textView setDelegate:modelController];
  
  // Wrap it in the scroll view
  [scrollView setDocumentView:textView];
  
  // Self
  _textView = [textView retain];
  [self setView: scrollView];
  
  // Theming
  [self __themeDidChangeNotification:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__themeDidChangeNotification:)
                                               name:SVRThemeDidChangeNotificationName
                                             object:nil];
}

// MARK: Properties

-(NSTextView*)textView;
{
  return [[_textView retain] autorelease];
}

-(SVRDocumentModelController*)modelController;
{
  return [[_modelController retain] autorelease];
}

// MARK: Private

-(void)__themeDidChangeNotification:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSTextView *textView = [self textView];
  [textView setTypingAttributes:[self __typingAttributes]];
  [textView setBackgroundColor:[ud SVR_colorForTheme:SVRThemeColorBackground]];
  [textView setInsertionPointColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint]];
  if (aNotification){
    [[self modelController] renderPreservingSelectionInTextView:textView];
  }
  [textView setNeedsDisplay:YES];
}

// Returns NIL if backspace
// Exception if unknown tag
-(NSString*)__mapKeyWithTag:(XPInteger)tag;
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
    case 22: return [@"2" stringByAppendingString:[NSString SVR_rootRawString]];
    case 23: return [@"10" stringByAppendingString:[NSString SVR_logRawString]];
    case 13: return nil; // Backspace key
  }
  XPLogRaise2(@"<%@> Button with unknown tag: %d", self, (int)tag);
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
  XPLogExtra1(@"%p", self);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_modelController release];
  _modelController = nil;
  _textView = nil;
  [super dealloc];
}

@end

@implementation SVRDocumentViewController (IBActions)

-(IBAction)keypadAppend:(NSButton*)sender;
{
  NSTextView *textView = [self textView];
  NSString   *toAppend = [self __mapKeyWithTag:[sender tag]];
  NSRange range;
  
  if (toAppend) {
    [textView XP_insertText:toAppend];
  } else {
    range = [textView selectedRange];
    // The delete method on NSText does not do a backspace
    // if nothing is selected. So this forces a single
    // character selection if needed
    if (range.location > 0 && range.length == 0) {
      range.location -= 1;
      range.length = 1;
      [textView setSelectedRange:range];
    }
    [textView delete:sender];
  }
}

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
  [self copyUnsolved:sender];
  [[self textView] delete:sender];
}
-(IBAction)cutUniversal:(id)sender;
{
  [self copyUniversal:sender];
  [[self textView] delete:sender];
}

-(IBAction)copyUnsolved:(id)sender;
{
  BOOL success = NO;
  NSRange range = [[self textView] selectedRange];
  NSData *rtfData = [[self modelController] dataRepresentationOfType:SVRDocumentModelRepUnsolved
                                                           withRange:range];
  NSData *diskRepData = [[self modelController] dataRepresentationOfType:SVRDocumentModelRepDisk
                                                               withRange:range];
  success = [self __universalCopyRTFData:rtfData diskRepData:diskRepData];
  XPLogAssrt(success, @"FAIL");
}

-(IBAction)copyUniversal:(id)sender;
{
  BOOL success = NO;
  NSRange range = [[self textView] selectedRange];
  NSData *rtfData = [[self modelController] dataRepresentationOfType:SVRDocumentModelRepSolved
                                                           withRange:range];
  NSData *diskRepData = [[self modelController] dataRepresentationOfType:SVRDocumentModelRepDisk
                                                               withRange:range];
  success = [self __universalCopyRTFData:rtfData diskRepData:diskRepData];
  XPLogAssrt(success, @"FAIL");
}

-(IBAction)pasteUniversal:(id)sender;
{
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSTextView *textView = [self textView];
  NSString *specialType = SVRDocumentViewControllerUnsolvedPasteboardType;
  NSString *diskRepString = nil;
  NSData *diskRepData = nil;
  
  if ([pb availableTypeFromArray:[NSArray arrayWithObject:specialType]]
      && (diskRepData = [pb dataForType:specialType])
      && (diskRepString = [[[NSString alloc] initWithData:diskRepData encoding:NSUTF8StringEncoding] autorelease]))
  {
    // Do Universal Paste
    XPLogDebug1(@"%@ pasteUniversal: Universal Paste", self);
    [[self modelController] replaceCharactersInRange:[textView selectedRange]
                                          withString:diskRepString];
  } else {
    // Fail universal paste and forward the message to the textview
    XPLogDebug1(@"%@ pasteUniversal: NOT Universal Paste", self);
    [textView pasteAsPlainText:sender];
    return;
  }
}

-(BOOL)__universalCopyRTFData:(NSData*)rtfData
                  diskRepData:(NSData*)diskRepData;
{
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  BOOL successRTF = NO;
  BOOL successPlain = NO;
  BOOL successSpecial = NO;
  NSString *specialType = SVRDocumentViewControllerUnsolvedPasteboardType;
  NSString *plainString = [[[[NSAttributedString alloc] initWithRTF:rtfData
                                                 documentAttributes:NULL] autorelease] string];
  
  NSCParameterAssert(rtfData);
  NSCParameterAssert(diskRepData);
  NSCParameterAssert(plainString);
  
  [pb declareTypes:[NSArray arrayWithObjects:
                    XPPasteboardTypeRTF,
                    XPPasteboardTypeString,
                    specialType,
                    nil]
             owner:nil];
  
  successRTF     = [pb setData:rtfData       forType:XPPasteboardTypeRTF];
  successSpecial = [pb setData:diskRepData   forType:specialType];
  successPlain   = [pb setString:plainString forType:XPPasteboardTypeString];
  
  return successRTF && successPlain && successSpecial;
}

@end

#ifndef XPSupportsNSViewController
@implementation SVRDocumentViewController (CrossPlatform)
-(NSView*)view;
{
  if (!_view_42) {
    [self loadView];
    NSCParameterAssert(_view_42);
  }
  return [[_view_42 retain] autorelease];
}

-(void)setView:(NSView*)view;
{
  NSCParameterAssert(view);
  [_view_42 release];
  _view_42 = [view retain];
}
@end
#endif
