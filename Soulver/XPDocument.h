/* XPDocument.h created by me on Sat 12-Oct-2024 */

#import <AppKit/AppKit.h>

// This is a best effort implementation of NSDocument only for use in OpenStep.
// Its insanely minimal because it won't be used once Mac OS X Ships

@interface XPDocument : NSObject
{

}

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
- (id)init;
- (id)initWithContentsOfFile:(NSString *)fileName ofType:(NSString *)fileType;

// MARK: Window Management

/// Default implementation throws exception.
/// File's Owner Should be this Object
- (NSString *)windowNibName;

/// Shows the window for this document
- (void)showWindows;

/// Return YES to allow the document to close
- (BOOL)shouldCloseDocument:(XPDocument*)document;

// MARK: Document Status

/// Automatically configured based on status of
/// - (NSData *)dataRepresentationOfType:(NSString *)type;
/// - (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type;
- (BOOL)isDocumentEdited;

/// Filename on disk is NIL if the document is not saved
-(NSString*)fileName;
-(void)setFileName:(NSString*)fileName;

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;

// MARK: Data reading and writing

-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
-(BOOL)writeToFile:(NSString*)fileName ofType:(NSString*)type;
-(BOOL)readFromFile:(NSString*)fileName ofType:(NSString*)type;

// MARK: Menu Handling

-(IBAction)saveDocument:(id)sender;
-(IBAction)saveDocumentAs:(id)sender;
-(IBAction)saveDocumentTo:(id)sender;
-(IBAction)revertDocumentToSaved:(id)sender;

// MARK: Panels and Alerts

-(int)runModalSavePanel:(NSSavePanel*)savePanel;
-(int)runUnsavedChangesAlert:(NSSavePanel*)savePanel;

@end
