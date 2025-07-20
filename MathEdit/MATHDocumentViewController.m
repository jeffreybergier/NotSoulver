//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "MATHSolver.h"
#import "MATHDocumentViewController.h"

NSString *MATHDocumentViewControllerUnsolvedPasteboardType = @"com.saturdayapps.mathedit.unsolved";

@implementation MATHDocumentViewController

// MARK: Init
-(id)initWithModelController:(MATHDocumentModelController*)modelController;
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
  MATHDocumentModelController *modelController = [self modelController];
  
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
  [scrollView XP_setAllowsMagnification:YES];
  [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#ifdef AFF_ScrollViewNoMagnification
  [scrollView setHasHorizontalScroller:NO];
#else
  [scrollView setHasHorizontalScroller:YES];
#endif
  
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
                                               name:MATHThemeDidChangeNotificationName
                                             object:nil];
  
  XPParameterRaise(_textView);
  XPParameterRaise([self view]);
}

// MARK: Properties

-(NSTextView*)textView;
{
  return [[_textView retain] autorelease];
}

-(MATHDocumentModelController*)modelController;
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
    XPLogDebug(@"[HACK] Manually Resized TextView");
  }
}

-(void)__themeDidChangeNotification:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSTextView *textView = [self textView];
  MATHDocumentModelController *mc = [self modelController];
  [textView setTypingAttributes:[self __typingAttributes]];
  [textView setBackgroundColor:[ud MATH_colorForTheme:MATHThemeColorBackground]];
  [textView setInsertionPointColor:[ud MATH_colorForTheme:MATHThemeColorInsertionPoint]];
  if (aNotification){
    [mc renderPreservingSelectionInTextView:textView error:NULL];
  }
  [textView setNeedsDisplay:YES];
}

// Returns NIL if backspace
// Exception if unknown tag
-(NSString*)__stringValueForKeypadKeyKind:(MATHKeypadButtonKind)kind;
{
  switch (kind) {
    case MATHKeypadButtonKind1:
    case MATHKeypadButtonKind2:
    case MATHKeypadButtonKind3:
    case MATHKeypadButtonKind4:
    case MATHKeypadButtonKind5:
    case MATHKeypadButtonKind6:
    case MATHKeypadButtonKind7:
    case MATHKeypadButtonKind8:
    case MATHKeypadButtonKind9:        return [NSString stringWithFormat:@"%d", (int)kind];
    case MATHKeypadButtonKind0:        return @"0";
    case MATHKeypadButtonKindNegative: return @"-";
    case MATHKeypadButtonKindDecimal:  return @".";
    case MATHKeypadButtonKindDelete:   return nil;
    case MATHKeypadButtonKindEqual:    return @"=\n";
    case MATHKeypadButtonKindAdd:      return @"+";
    case MATHKeypadButtonKindSubtract: return @"-";
    case MATHKeypadButtonKindBRight:   return @")";
    case MATHKeypadButtonKindMultiply: return @"*";
    case MATHKeypadButtonKindDivide:   return @"/";
    case MATHKeypadButtonKindBLeft:    return @"(";
    case MATHKeypadButtonKindPower:    return @"^";
    case MATHKeypadButtonKindRoot:     return [@"2"  stringByAppendingString:[NSString MATH_rootRawString]];
    case MATHKeypadButtonKindLog:      return [@"10" stringByAppendingString:[NSString MATH_logRawString]];
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] MATHKeypadButtonKind(%d)", (int)kind);
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
          [ud MATH_fontForTheme:MATHThemeFontOther],
          [ud MATH_colorForTheme:MATHThemeColorOtherText],
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

@implementation MATHDocumentViewController (IBActions)

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
  [textView setFrame:newTextViewFrame];
}

-(IBAction)zoomIn:(id)sender;
{
  NSScrollView *scrollView = [[self textView] enclosingScrollView];
  [scrollView XP_setMagnification:[scrollView XP_magnification]+0.25];
}

-(IBAction)zoomOut:(id)sender;
{
  NSScrollView *scrollView = [[self textView] enclosingScrollView];
  [scrollView XP_setMagnification:[scrollView XP_magnification]-0.25];
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
  MATHDocumentModelController *mc = [self modelController];
  NSData *rtfData = [mc dataOfType:MATHDocumentModelRepUnsolved
                             range:range
                             error:NULL];
  NSData *diskRepData = [mc dataOfType:MATHDocumentModelRepDisk
                                 range:range
                                 error:NULL];
  success = [self __universalCopyRTFData:rtfData diskRepData:diskRepData];
  XPLogAssrt(success, @"FAIL");
}

-(IBAction)copyUniversal:(id)sender;
{
  BOOL success = NO;
  NSRange range = [[self textView] selectedRange];
  MATHDocumentModelController *mc = [self modelController];
  NSData *rtfData = [mc dataOfType:MATHDocumentModelRepSolved
                             range:range
                             error:NULL];
  NSData *diskRepData = [mc dataOfType:MATHDocumentModelRepDisk
                                 range:range
                                 error:NULL];
  success = [self __universalCopyRTFData:rtfData diskRepData:diskRepData];
  XPLogAssrt(success, @"FAIL");
}

-(IBAction)pasteUniversal:(id)sender;
{
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSTextView *textView = [self textView];
  NSString *specialType = MATHDocumentViewControllerUnsolvedPasteboardType;
  NSString *diskRepString = nil;
  NSData *diskRepData = nil;
  
  if ([pb availableTypeFromArray:[NSArray arrayWithObject:specialType]]
      && (diskRepData = [pb dataForType:specialType])
      && (diskRepString = [[[NSString alloc] initWithData:diskRepData encoding:NSUTF8StringEncoding] autorelease]))
  {
    // Do Universal Paste
    XPLogDebug(@"Universal Paste");
    [[self modelController] replaceCharactersInRange:[textView selectedRange]
                                          withString:diskRepString
                       preservingSelectionInTextView:textView];
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
  NSString *specialType = MATHDocumentViewControllerUnsolvedPasteboardType;
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
  
  successRTF     = [pb setData:rtfData       forType:XPPasteboardTypeRTF   ];
  successSpecial = [pb setData:diskRepData   forType:specialType           ];
  successPlain   = [pb setString:plainString forType:XPPasteboardTypeString];
  
  return successRTF && successPlain && successSpecial;
}

@end

#ifdef AFF_NSViewControllerNone
@implementation MATHDocumentViewController (CrossPlatform)
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
