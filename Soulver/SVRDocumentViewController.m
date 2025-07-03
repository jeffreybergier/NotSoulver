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
  XPParameterRaise(self);
  XPParameterRaise(modelController);
  _modelController = [modelController retain];
  _textView = nil;
  _view_42 = nil;
  return self;
}

-(void)loadView;
{
  NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init]                                                 autorelease];
  NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)]   autorelease];
  NSTextView      *textView      = [[[NSTextView      alloc] initWithFrame:NSZeroRect textContainer:textContainer] autorelease];
  NSScrollView    *scrollView    = [[[NSScrollView    alloc] initWithFrame:NSZeroRect]                             autorelease];
  SVRDocumentModelController *modelController = [self modelController];
  
  XPParameterRaise(layoutManager);
  XPParameterRaise(textContainer);
  XPParameterRaise(textView);
  XPParameterRaise(scrollView);
  XPParameterRaise(modelController);
  
  // TextContainer
  [textContainer setWidthTracksTextView:YES];
  [textContainer setHeightTracksTextView:NO];
  
  // ScrollView
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView XP_setAllowsMagnification:YES];
  [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  
  // TextView
  [textView setMinSize:NSMakeSize(0, 0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:NO];
  [textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [textView XP_setUsesFindPanel:YES];
  [textView XP_setUsesFindBar:YES];
  [textView XP_setAllowsUndo:YES];
  // TODO: Consider preserving these settings in NSUserDefaults
  [textView XP_setContinuousSpellCheckingEnabled:YES];
  [textView XP_setGrammarCheckingEnabled:NO];
  [textView XP_setAutomaticSpellingCorrectionEnabled:YES];
  
  // ModelController
  [[modelController model] addLayoutManager:layoutManager];
  [layoutManager addTextContainer:textContainer];
  [textView setDelegate:modelController];
  
  // Wrap it in the scroll view
  [scrollView setDocumentView:textView];
  
  // Self
  _textView = textView;
  [self setView:scrollView];
  
  // Theming
  [self __themeDidChangeNotification:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__themeDidChangeNotification:)
                                               name:SVRThemeDidChangeNotificationName
                                             object:nil];
  
  XPParameterRaise(_textView);
  XPParameterRaise([self view]);
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

-(void)viewWillLayout;
{
  NSTextView *textView = [self textView];
  NSScrollView *scrollView = [textView enclosingScrollView];
  NSRect textViewFrame = [textView frame];
  XPFloat scrollViewWidth = [scrollView contentSize].width;
  XPFloat magnification = [scrollView XP_magnification];
  if (magnification == 1 && textViewFrame.size.width != scrollViewWidth) {
    // TODO: ScrollView Zoom Problem
    // after changing the magnification of the scroll view
    // even after it is changed back to 1, it no longer
    // automatically resizes the text view to fit the width.
    // This is an issue in TextEdit as well, so I assume there
    // is some sort of issue with NSScrollView.
    // NOTE: viewWillLayout was added in 10.10 so this feature
    // is broken in 10.8 Mountain Lion. But its OK
    // opening and closing the document resolves the issue.
    // As long as zoom is never used, everything works normally
    textViewFrame.size.width = scrollViewWidth;
    [textView setFrame:textViewFrame];
    XPLogExtra1(@"Manually Resized TextView(%@)", textView);
  }
}

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
-(NSString*)__stringValueForKeypadKeyKind:(SVRKeypadButtonKind)kind;
{
  switch (kind) {
    case SVRKeypadButtonKind1:
    case SVRKeypadButtonKind2:
    case SVRKeypadButtonKind3:
    case SVRKeypadButtonKind4:
    case SVRKeypadButtonKind5:
    case SVRKeypadButtonKind6:
    case SVRKeypadButtonKind7:
    case SVRKeypadButtonKind8:
    case SVRKeypadButtonKind9:        return [NSString stringWithFormat:@"%d", (int)kind];
    case SVRKeypadButtonKind0:        return @"0";
    case SVRKeypadButtonKindNegative: return @"-";
    case SVRKeypadButtonKindDecimal:  return @".";
    case SVRKeypadButtonKindDelete:   return nil;
    case SVRKeypadButtonKindEqual:    return @"=\n";
    case SVRKeypadButtonKindAdd:      return @"+";
    case SVRKeypadButtonKindSubtract: return @"-";
    case SVRKeypadButtonKindBRight:   return @")";
    case SVRKeypadButtonKindMultiply: return @"*";
    case SVRKeypadButtonKindDivide:   return @"/";
    case SVRKeypadButtonKindBLeft:    return @"(";
    case SVRKeypadButtonKindPower:    return @"^";
    case SVRKeypadButtonKindRoot:     return [@"2" stringByAppendingString:[NSString SVR_rootRawString]];
    case SVRKeypadButtonKindLog:      return [@"10" stringByAppendingString:[NSString SVR_logRawString]];
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRKeypadButtonKind(%d)", (int)kind);
      return @"";
  }
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
  XPLogDebug1(@"<%@>", XPPointerString(self));
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
  NSString   *toAppend = [self __stringValueForKeypadKeyKind:[sender tag]];
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
  BOOL canMagnify = [self __canMagnify];
  
  menuAction = [menuItem action];
  selectedRange = [[self textView] selectedRange];
  canCopy  = !XPIsNotFoundRange(selectedRange) && selectedRange.length > 0;
  canPaste = !XPIsNotFoundRange(selectedRange);
  
  if        (menuAction == @selector(actualSize:)) {
    return canMagnify;
  } else if (menuAction == @selector(zoomIn:)) {
    return canMagnify;
  } else if (menuAction == @selector(zoomOut:)) {
    return canMagnify;
  } else if (menuAction == @selector(copyUnsolved:)) {
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

-(IBAction)actualSize:(id)sender;
{
  NSTextView *textView = [self textView];
  NSScrollView *scrollView = [textView enclosingScrollView];
  NSRect newTextViewFrame = [textView frame];
  newTextViewFrame.size.width = [scrollView contentSize].width;
  
  // TODO: ScrollView Zoom Problem - See -viewWillLayout;
  [scrollView XP_setMagnification:1];
  [scrollView setHasHorizontalScroller:NO];
  [textView setFrame:newTextViewFrame];
}

-(IBAction)zoomIn:(id)sender;
{
  NSScrollView *scrollView = [[self textView] enclosingScrollView];
  [scrollView XP_setMagnification:[scrollView XP_magnification]+0.25];
  [scrollView setHasHorizontalScroller:YES];
}

-(IBAction)zoomOut:(id)sender;
{
  NSScrollView *scrollView = [[self textView] enclosingScrollView];
  [scrollView XP_setMagnification:[scrollView XP_magnification]-0.25];
  [scrollView setHasHorizontalScroller:YES];
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
    XPLogDebug(@"Universal Paste");
    [[self modelController] replaceCharactersInRange:[textView selectedRange]
                                          withString:diskRepString];
  } else {
    // Fail universal paste and forward the message to the textview
    XPLogDebug(@"NOT Universal Paste");
    [textView pasteAsPlainText:sender];
    return;
  }
}

-(BOOL)__canMagnify;
{
#ifdef AFF_ScrollViewNoMagnification
  return NO;
#else
  return YES;
#endif
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
  
  XPParameterRaise(rtfData);
  XPParameterRaise(diskRepData);
  XPParameterRaise(plainString);
  
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
    XPParameterRaise(_view_42);
  }
  return [[_view_42 retain] autorelease];
}

-(void)setView:(NSView*)view;
{
  XPParameterRaise(view);
  [_view_42 release];
  _view_42 = [view retain];
}
@end
#endif
