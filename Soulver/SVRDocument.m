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

#import "SVRDocument.h"
#import "SVRSolver.h"

@implementation SVRDocument

// MARK: Properties

-(SVRDocumentViewController*)viewController;
{
  return [[_viewController retain] autorelease];
}

-(NSString*)windowNibName;
{
  return @"NEXTSTEP_SVRDocument.nib";
}

// MARK: INIT
-(id)initWithContentsOfFile:(NSString*)fileName;
{
  self = [super initWithContentsOfFile:fileName ofType:@"solv"];
  return self;
}

+(id)documentWithContentsOfFile:(NSString*)fileName;
{
  return [[[SVRDocument alloc] initWithContentsOfFile:fileName] autorelease];
}

// MARK: NSDocument subclass

-(void)awakeFromNib;
{
  id previousNextResponder = nil;
  
  [super awakeFromNib];
  
  // Add view controller into the responder chain
  previousNextResponder = [[self window] nextResponder];
  [[self window] setNextResponder:[self viewController]];
  [[self viewController] setNextResponder:self];
  [self setNextResponder:previousNextResponder];
  
  // Subscribe to model updates
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:[[[self viewController] modelController] model]];
}

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[[self viewController] modelController] dataRepresentationOfType:type];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  return [[[self viewController] modelController] loadDataRepresentation:data ofType:type];
}

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;
{
  [self updateWindowChrome];
}

-(void)dealloc;
{
  [_viewController release];
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

@implementation SVRDocument (IBActions)

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  BOOL alreadyValidated = [super validateMenuItem:menuItem];
  SEL menuAction;
  NSRange selectedRange;
  BOOL selectionValid;
  if (alreadyValidated) { return alreadyValidated; };
  
  menuAction = [menuItem action];
  selectedRange = [[[self viewController] textView] selectedRange];
  selectionValid = !XPIsNotFoundRange(selectedRange) && selectedRange.length > 0;
  
  if        (menuAction == @selector(copyUnsolved:)) {
    return selectionValid;
  } else if (menuAction == @selector(copySolved:)) {
    return selectionValid;
  }

  return NO;
}


-(IBAction)copyUnsolved:(id)sender;
{
  NSRange range = [[[self viewController] textView] selectedRange];
  NSAttributedString *original = [[[[self viewController] modelController] model] attributedSubstringFromRange:range];
  // TODO: Consider improving this to apply correct styling to restored characters
  NSAttributedString *restored = [SVRSolver restoreOriginalString:original];
  [self __copyAttributedStringToPasteBoard:restored];
}

-(IBAction)copySolved:(id)sender;
{
  NSLog(@"SOLVED");
}

-(BOOL)__copyAttributedStringToPasteBoard:(NSAttributedString*)attributedString;
{
  BOOL successString = NO;
  BOOL successRTF = NO;
  NSRange range = NSMakeRange(0, [attributedString length]);
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  
  [pb declareTypes:[NSArray arrayWithObjects:
                    NSRTFPboardType,
                    NSStringPboardType,
                    nil]
             owner:nil];
  
  // Attributes dictionary might be needed in OSX
  // [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute];
  successString = [pb setString:[attributedString string] forType:NSStringPboardType];
  successRTF = [pb setData:[attributedString RTFFromRange:range
                                       documentAttributes:nil]
                   forType:NSRTFPboardType];
  
  return successRTF && successString;
}

@end
