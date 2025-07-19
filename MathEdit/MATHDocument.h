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
#import "XPDocument.h"
#import "MATHDocumentViewController.h"

#ifdef AFF_NSDocumentNone
@interface MATHDocument: NSDocumentLegacyImplementation
#else
@interface MATHDocument: NSDocument
#endif
{
  mm_new   MATHDocumentModelController *_modelController;
  mm_retain MATHDocumentViewController *_viewController;
}

// MARK: Properties
-(MATHDocumentViewController*)viewController;
-(MATHDocumentModelController*)modelController;

// Create everything without Nibs
-(void)makeWindowControllers;

// MARK: NSDocument subclass
-(NSData*)dataOfType:(NSString*)typeName error:(XPErrorPointer)outError;
-(NSData*)dataRepresentationOfType:(NSString*)type; // Legacy for X2
-(BOOL)readFromData:(NSData*)data ofType:(NSString*)typeName error:(XPErrorPointer)outError;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type; // Legacy for X2

// MARK: Model Changed Notification
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;

@end

@interface MATHDocument (StateRestoration)
+(BOOL)autosavesInPlace;
+(BOOL)canConcurrentlyReadDocumentsOfType:(NSString*)typeName;
-(BOOL)canAsynchronouslyWriteToURL:(id)url
                            ofType:(NSString*)typeName
                  forSaveOperation:(XPSaveOperationType)saveOperation;
@end

@interface MATHDocument (DarkMode)
-(void)overrideWindowAppearance;
@end

// MARK: XPDocument Compatibility Category

#ifdef AFF_NSDocumentNone
@interface NSDocumentLegacyImplementation (MATHDocument)
#else
@interface NSDocument (MATHDocument)
#endif
-(id)MATH_initWithContentsOfFileObject:(id)fileObject
                                ofType:(NSString*)typeName
                                 error:(XPErrorPointer)outError;
-(id)MATH_fileObject;
-(NSString*)MATH_nameForFrameAutosave;
-(NSString*)MATH_requiredFileType;
-(NSWindow*)MATH_windowForSheet;
-(void)MATH_addWindowController:(XPWindowController*)aWindowController;
-(void)MATH_setRequiredFileType:(NSString*)type;
@end
