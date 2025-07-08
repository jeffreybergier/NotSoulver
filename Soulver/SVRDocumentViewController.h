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

#import <AppKit/AppKit.h>
#import "MATHAccessoryWindowViews.h"
#import "SVRDocumentModelController.h"
#import "XPCrossPlatform.h"

@interface SVRDocumentViewController: XPViewController
{
  mm_new NSView *_view_42; // Used only in OpenStep
  mm_new SVRDocumentModelController *_modelController;
  mm_unretain NSTextView *_textView;
}

// MARK: Init
-(id)initWithModelController:(SVRDocumentModelController*)modelController;
-(void)loadView;

// MARK: Properties
-(NSTextView*)textView;
-(SVRDocumentModelController*)modelController;

// MARK: Private
-(void)viewWillLayout;
-(void)__themeDidChangeNotification:(NSNotification*)aNotification;
-(NSString*)__stringValueForKeypadKeyKind:(SVRKeypadButtonKind)tag;
-(NSDictionary*)__typingAttributes;

@end

@interface SVRDocumentViewController (IBActions)

-(IBAction)keypadAppend:(NSButton*)sender;
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(IBAction)actualSize:(id)sender;
-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)cutUnsolved:(id)sender;
-(IBAction)cutUniversal:(id)sender;
-(IBAction)copyUnsolved:(id)sender;
-(IBAction)copyUniversal:(id)sender;
-(IBAction)pasteUniversal:(id)sender;
-(BOOL)__canMagnify;
-(BOOL)__universalCopyRTFData:(NSData*)rtfData
                  diskRepData:(NSData*)diskRepData;

@end

#ifndef XPSupportsNSViewController
@interface SVRDocumentViewController (CrossPlatform)
-(NSView*)view;
-(void)setView:(NSView*)view;
@end
#endif
