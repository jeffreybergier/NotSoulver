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
#import "XPCrossPlatform.h"

@protocol XPDocumentProtocol <NSObject>

-(BOOL)XP_isDocumentEdited;
-(XPURL*)XP_fileURL;
-(NSString*)XP_nameForFrameAutosave;
-(NSWindow*)XP_windowForSheet;
-(void)XP_showWindows;
-(void)XP_setWindow:(NSWindow*)aWindow;
-(void)XP_setFileType:(NSString*)type;
-(void)XP_setFileExtension:(NSString*)type;
-(BOOL)XP_readFromURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(XPErrorPointer)outError;
-(void)XP_addWindowController:(XPWindowController*)windowController;

@end

// This is a best effort implementation of NSDocument only for use in OpenStep.
// Its insanely minimal because it won't be used once Mac OS X Ships
#ifdef XPSupportsFormalProtocols
@interface NSDocumentLegacyImplementation: NSResponder <NSWindowDelegate>
#else
@interface NSDocumentLegacyImplementation: NSResponder
#endif
{
  mm_copy XPURL    *_fileURL;
  mm_copy NSString *_fileType;
  mm_copy NSString *_fileExtension;
  mm_retain NSWindow *_window_42; // Only used in OpenStep
  BOOL _isEdited;
}

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
-(id)initWithContentsOfURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(id*)outError;

// MARK: Window Management

/// Loads the NIB if needed and shows the window
-(void)showWindows;
/// _window should be set as IBOutlet
-(NSWindow*)windowForSheet;

// MARK: One-Time Setup
-(void)makeWindowControllers;

// MARK: Document Properties

/// For display in the window title. If NIL, "Untitled" shown
-(NSString*)displayName;
/// Default implementation reads file on disk and compares with _rawData property
-(BOOL)isDocumentEdited;
/// supported values are NSChangeDone (0) and NSChangeCleared (2)
-(void)updateChangeCount:(XPDocumentChangeType)change;
-(XPURL*)fileURL;
-(void)setFileURL:(XPURL*)fileURL;
-(NSString*)fileType;
-(void)setFileType:(NSString*)type;

// MARK: NSObject basics

-(XPUInteger)hash;
-(BOOL)isEqual:(id)object;

// MARK: Data reading and writing
// Override to provide data for saving
-(NSData*)dataRepresentationOfType:(NSString*)type;
// Override to convert your model when loading
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// No need to override, uses above 2 methods to read and write data
-(BOOL)writeToURL:( XPURL*)fileURL ofType:(NSString*)fileType error:(XPErrorPointer)outError;
-(BOOL)readFromURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(XPErrorPointer)outError;

// MARK: Menu Handling

/// Override to enable and disable menu items, default returns YES
-(IBAction)saveDocument:(id)sender;
-(IBAction)saveDocumentAs:(id)sender;
-(IBAction)saveDocumentTo:(id)sender;
-(IBAction)revertDocumentToSaved:(id)sender;

// MARK: Customizations

-(NSString*)__fileExtension;
-(void)__setFileExtension:(NSString*)type;
-(BOOL)windowShouldClose:(id)sender;
-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;

// MARK: Panels and Alerts

-(BOOL)__prepareSavePanel:(NSSavePanel*)savePanel;
-(XPInteger)__runModalSavePanel:(NSSavePanel*)savePanel;
-(XPInteger)__runModalSavePanelAndSetFileURL;
-(XPAlertReturn)__runUnsavedChangesAlert;
-(XPAlertReturn)__runRevertToSavedAlert;

@end

#ifndef AFF_NSDocumentNone
@interface NSDocument (CrossPlatform) <XPDocumentProtocol>
-(BOOL)XP_isDocumentEdited;
-(XPURL*)XP_fileURL;
-(NSString*)XP_nameForFrameAutosave;
-(NSWindow*)XP_windowForSheet;
-(void)XP_showWindows;
-(void)XP_setWindow:(NSWindow*)aWindow;
-(void)XP_setFileType:(NSString*)type;
-(void)XP_setFileExtension:(NSString*)type;
-(BOOL)XP_readFromURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(id*)outError;
-(void)XP_addWindowController:(id)windowController;
@end
#endif

@interface NSDocumentLegacyImplementation (CrossPlatform) <XPDocumentProtocol>
-(BOOL)XP_isDocumentEdited;
-(XPURL*)XP_fileURL;
-(NSString*)XP_nameForFrameAutosave;
-(NSWindow*)XP_windowForSheet;
-(void)XP_showWindows;
-(void)XP_setWindow:(NSWindow*)aWindow;
-(void)XP_setFileType:(NSString*)type;
-(void)XP_setFileExtension:(NSString*)type;
-(BOOL)XP_readFromURL:(XPURL*)fileURL ofType:(NSString*)fileType error:(id*)outError;
-(void)XP_addWindowController:(id)windowController;
@end
