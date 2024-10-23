/* XPDocument.h created by me on Sat 12-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

// This is a best effort implementation of NSDocument only for use in OpenStep.
// Its insanely minimal because it won't be used once Mac OS X Ships
#if OS_OPENSTEP
@interface XPDocument: NSResponder
#else
@interface XPDocument: NSResponder <NSWindowDelegate>
#endif
{
  mm_retain IBOutlet NSWindow *_window;
  mm_copy   NSString *_fileName;
  mm_copy   NSString *_fileType;
  BOOL _isNibLoaded;
}

// MARK: Window Placement

+(void)load;

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
-(NSWindow*)window;
/// Default implementation populates rawData property if fileName is set
/// and sets self as window delegate
-(void)awakeFromNib;
-(void)updateWindowChrome;

// MARK: Document Status

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
/// Default implementation reads file on disk and compares with _rawData property
-(BOOL)isDocumentEdited;
/// Filename on disk is NIL if the document is not saved
-(NSString*)fileName;
-(void)setFileName:(NSString*)fileName;
-(NSString*)fileType;
-(void)setFileType:(NSString*)type;

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

// MARK: NSWindowDelegate

-(void)windowDidResize:(NSNotification*)aNotification;
-(void)windowDidMove:(NSNotification*)aNotification;

// MARK: Panels and Alerts

-(BOOL)prepareSavePanel:(NSSavePanel*)savePanel;
-(XPInteger)runModalSavePanel:(NSSavePanel*)savePanel;
-(XPInteger)__runModalSavePanelAndSetFileName;
-(XPAlertReturn)runUnsavedChangesAlert;
-(XPAlertReturn)runRevertToSavedAlert;

@end
