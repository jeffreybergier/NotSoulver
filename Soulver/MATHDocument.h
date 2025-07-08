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

#if XPSupportsNSDocument >= 1
@interface SVRDocument: NSDocument
#else
@interface SVRDocument: NSDocumentLegacyImplementation
#endif
{
  mm_new   SVRDocumentModelController *_modelController;
  mm_retain SVRDocumentViewController *_viewController;
}

// MARK: Properties
-(SVRDocumentViewController*)viewController;
-(SVRDocumentModelController*)modelController;

// Create everything without Nibs
-(void)makeWindowControllers;

// MARK: NSDocument subclass
-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// MARK: Model Changed Notification
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;

@end

@interface SVRDocument (StateRestoration)
+(BOOL)autosavesInPlace;
+(BOOL)canConcurrentlyReadDocumentsOfType:(NSString*)typeName;
-(BOOL)canAsynchronouslyWriteToURL:(XPURL*)url
                            ofType:(NSString*)typeName
                  forSaveOperation:(XPSaveOperationType)saveOperation;
@end

@interface SVRDocument (DarkMode)
-(void)overrideWindowAppearance;
@end
