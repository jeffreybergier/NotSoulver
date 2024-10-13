/* XPDocument.h created by me on Sat 12-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

// This is a best effort implementation of NSDocument only for use in OpenStep.
// Its insanely minimal because it won't be used once Mac OS X Ships

@interface XPDocument: NSResponder <NSWindowDelegate>
{
  IBOutlet NSWindow *_window;
  NSString *_fileName;
  NSString *_fileType;
  NSData *_rawData;
}

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;

// MARK: Window Management

/// Default implementation throws exception.
/// File's Owner Should be this Object
-(NSString*)windowNibName;
/// Default implementation populates rawData property if fileName is set
/// and sets self as window delegate
-(void)awakeFromNib;

/// Shows the window for this document
-(void)showWindows;

/// Return YES to allow the document to close
-(BOOL)shouldCloseDocument;

-(NSWindow*)window;

// MARK: Document Status

/// Automatically configured based on status of
/// - (NSData *)dataRepresentationOfType:(NSString *)type;
/// - (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type;
-(BOOL)isDocumentEdited;

/// Filename on disk is NIL if the document is not saved
-(NSString*)fileName;
-(void)setFileName:(NSString*)fileName;
-(NSString*)fileType;
-(void)setFileType:(NSString*)type;
-(NSData*)rawData;
-(void)setRawData:(NSData*)rawData;

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;

// MARK: Data reading and writing

/// Return NSData object for your document
-(NSData*)dataRepresentationOfType:(NSString*)type;
/// If arguments are nil, document values used
-(BOOL)writeToFile:(NSString*)fileName ofType:(NSString*)type;
/// If arguments are nil, document values used
-(BOOL)readFromFile:(NSString*)fileName ofType:(NSString*)type;

// MARK: Menu Handling

/// Override to enable and disable menu items, default returns YES
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
-(IBAction)saveDocument:(id)sender;
-(IBAction)saveDocumentAs:(id)sender;
-(IBAction)saveDocumentTo:(id)sender;
-(IBAction)revertDocumentToSaved:(id)sender;

// MARK: Panels and Alerts

-(NSSavePanel*)savePanelForDocument;
-(XPInteger)runModalSavePanel:(NSSavePanel*)savePanel;
-(XPAlertReturn)runUnsavedChangesAlert;
-(XPAlertReturn)runRevertToSavedAlert;

@end
