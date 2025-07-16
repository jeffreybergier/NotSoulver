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

@class NSDocumentLegacyImplementation;

#ifdef AFF_NSDocumentNone
#define XPDocument NSDocumentLegacyImplementation
// typedef NSDocumentLegacyImplementation XPDocument;
#else
#define XPDocument NSDocument
// typedef NSDocument XPDocument;
#endif

#ifdef AFF_NSDocumentNoURL
#define XPURL NSString
// typedef NSString XPURL;
#else
#define XPURL NSURL
// typedef NSURL XPURL;
#endif

// This is a best effort implementation of NSDocument only for use in OpenStep.
// Its insanely minimal because it won't be used once Mac OS X Ships
#ifdef XPSupportsFormalProtocols
@interface NSDocumentLegacyImplementation: NSResponder <NSWindowDelegate>
#else
@interface NSDocumentLegacyImplementation: NSResponder
#endif
{
  mm_copy NSString *_fileName;
  mm_copy NSString *_fileType;
  mm_copy NSString *_fileExtension;
  mm_retain NSWindow *_window_42; // Only used in OpenStep
  BOOL _isEdited;
}

// MARK: Init

/// Designated Initializer.  Inits an "empty" document.
-(id)init;
-(id)initWithContentsOfFile:(NSString*)fileName ofType:(NSString*)fileType;

// MARK: Window Management

-(void)makeWindowControllers;
-(void)showWindows;
-(NSWindow*)windowForSheet;
// TODO: Implement
-(void)setWindow:(NSWindow *)window;

// MARK: Document Properties

/// Default implementation reads file on disk and compares with _rawData property
/// supported values are NSChangeDone (0) and NSChangeCleared (2)
-(void)updateChangeCount:(XPDocumentChangeType)change;
-(BOOL)isDocumentEdited;

-(NSString*)fileName;
-(void)setFileName:(NSString*)fileName;
-(NSString*)fileType;
-(void)setFileType:(NSString*)type;
-(NSString*)displayName;

// MARK: NSObject basics

-(XPUInteger)hash;
-(BOOL)isEqual:(id)object;

// MARK: MUST IMPLEMENT loading methods
// Override to provide data for saving
-(NSData*)dataRepresentationOfType:(NSString*)type;
// Override to convert your model when loading
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// MARK: Data reading and writing
-(BOOL)writeToFile:(NSString*)fileName ofType:(NSString*)type;
-(BOOL)readFromFile:(NSString*)fileName ofType:(NSString*)type;

// MARK: Menu Handling

/// Override to enable and disable menu items, default returns YES
-(IBAction)saveDocument:(id)sender;
-(IBAction)saveDocumentAs:(id)sender;
-(IBAction)saveDocumentTo:(id)sender;
-(IBAction)revertDocumentToSaved:(id)sender;

// MARK: Customizations

-(NSString*)__fileExtension;
// TODO: Change this to a method -__fileExtension: for the subclass to implement
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
