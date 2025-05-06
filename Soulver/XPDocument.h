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

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

#ifdef XPSupportsNSDocument

#define XPDocument NSDocument
@interface NSDocument (CrossPlatform)
-(NSWindow*)XP_windowForSheet;
-(NSString*)XP_nameForFrameAutosave;
@end

#else

// This is a best effort implementation of NSDocument only for use in OpenStep.
// Its insanely minimal because it won't be used once Mac OS X Ships
@interface XPDocument: NSResponder
{
  /// Named without underscore for NSDocument compatibility
  mm_retain IBOutlet NSWindow *window;
  mm_copy   NSString *_fileName;
  mm_copy   NSString *_fileType;
  mm_copy   NSString *_fileExtension;
  BOOL _isNibLoaded;
  BOOL _isEdited;
}

// MARK: Window Placement

+(void)initialize;

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;

// MARK: Window Management

/// Default implementation throws exception.
/// File's Owner Should be this Object
-(NSString*)windowNibName;
/// Loads the NIB if needed and shows the window
-(void)showWindows;
/// Return YES to allow the document to close
-(BOOL)windowShouldClose:(id)sender;
/// _window should be set as IBOutlet
-(NSWindow*)XP_windowForSheet;
-(NSString*)XP_nameForFrameAutosave;
// Nib Loading
-(void)awakeFromNib;
-(void)windowControllerWillLoadNib:(id)windowController;
-(void)windowControllerDidLoadNib:(id)windowController;

// MARK: Document Status

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
/// Default implementation reads file on disk and compares with _rawData property
-(BOOL)isDocumentEdited;
/// supported values are NSChangeDone (0) and NSChangeCleared (2)
-(void)updateChangeCount:(int)change;
/// Filename on disk is @"" if the document is not saved
-(NSString*)fileName;
-(void)setFileName:(NSString*)fileName;
-(NSString*)fileType;
-(void)setFileType:(NSString*)type;
-(NSString*)fileExtension;
-(void)setFileExtension:(NSString*)type;

// MARK: NSObject basics
/// Returns hash of the filename or calls super
-(XPUInteger)hash;
/// Compares fileName or calls super
-(BOOL)isEqual:(id)object;

// MARK: Data reading and writing
// Override to provide data for saving
-(NSData*)dataRepresentationOfType:(NSString*)type;
// Override to convert your model when loading
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// No need to override, uses above 2 methods to read and write data
-(BOOL)writeToFile:(NSString*)fileName ofType:(NSString*)type;
-(BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)type;

// MARK: Menu Handling

/// Override to enable and disable menu items, default returns YES
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(IBAction)saveDocument:(id)sender;
-(IBAction)saveDocumentAs:(id)sender;
-(IBAction)saveDocumentTo:(id)sender;
-(IBAction)revertDocumentToSaved:(id)sender;

// MARK: Panels and Alerts

-(BOOL)prepareSavePanel:(NSSavePanel*)savePanel;
-(XPInteger)runModalSavePanel:(NSSavePanel*)savePanel;
-(XPInteger)__runModalSavePanelAndSetFileName;
-(XPAlertReturn)runUnsavedChangesAlert;
-(XPAlertReturn)runRevertToSavedAlert;

@end

#endif

