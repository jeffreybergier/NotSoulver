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

#import "SVRAppDelegate.h"
#import "SVRDocument.h"
#import "NSUserDefaults+Soulver.h"

@implementation SVRAppDelegate

// MARK: Init;
-(id)init;
{
  self = [super init];
  _openDocuments = [NSMutableSet new];
  _accessoryWindowsOwner = nil; // Set in applicationDidFinishLaunching:
  return self;
}

// MARK: Properties
-(NSMutableSet*)openDocuments;
{
  return [[_openDocuments retain] autorelease];
}

-(SVRAccessoryWindowsOwner*)accessoryWindowsOwner;
{
  return [[_accessoryWindowsOwner retain] autorelease];
}

// MARK: IBActions
-(void)newDoc:(id)sender
{
  SVRDocument *document = [SVRDocument documentWithContentsOfFile:nil];
  [document showWindows];
  [[self openDocuments] addObject:document];
}

-(IBAction)openDoc:(id)sender
{
  NSArray *filenames;
  NSEnumerator *e;
  NSString *nextF;
  SVRDocument *nextC;
  
  filenames = XPRunOpenPanel();
  if ([filenames count] == 0) { XPLogDebug1(@"%@ Open Cancelled", self); return; }
  e = [filenames objectEnumerator];
  while ((nextF = [e nextObject])) {
    nextC = [[self openDocuments] member:nextF];
    if (!nextC) {
      nextC = [SVRDocument documentWithContentsOfFile:nextF];
      [[self openDocuments] addObject:nextC];
    }
    [nextC showWindows];
  }
}

-(IBAction)saveAll:(id)sender;
{
  NSEnumerator *e;
  SVRDocument *nextC;
  e = [[self openDocuments] objectEnumerator];
  while ((nextC = [e nextObject])) {
    [nextC saveDocument:self];
  }
}

-(IBAction)toggleKeypadPanel:(id)sender;
{
  [[self accessoryWindowsOwner] toggleKeypadPanel:sender];
}

-(IBAction)showSettingsWindow:(id)sender;
{
  [[self accessoryWindowsOwner] showSettingsWindow:sender];
}

-(IBAction)showAboutWindow:(id)sender;
{
  [[self accessoryWindowsOwner] showAboutWindow:sender];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  id document = [window delegate];
  if (document) {
    [[self openDocuments] removeObject:document];
  }
}

-(void)dealloc;
{
  XPLogDebug1(@"DEALLOC: %@", self);
  [_openDocuments release];
  [_accessoryWindowsOwner release];
  _openDocuments = nil;
  _accessoryWindowsOwner = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end


@implementation SVRAppDelegate (NSApplicationDelegate)

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
{
  NSApplication *app = [aNotification object];
  // Configure the title of the app
  [[app mainMenu] setTitle:[Localized appName]];
  // Prepare UserDefaults
  [[NSUserDefaults standardUserDefaults] SVR_configure];
  // Prepare FontManager
  [NSFontManager setFontManagerFactory:[SVRFontManager class]];
  // Register for Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__windowWillCloseNotification:)
                                               name:NSWindowWillCloseNotification
                                             object:nil];
  // Configure Accessory Windows
  _accessoryWindowsOwner = [[SVRAccessoryWindowsOwner alloc] init];
  // Announce
  XPLogDebug1(@"%@ applicationWillFinishLaunching:", self);
}

-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
{
  XPAlertReturn alertResult = NSNotFound;
  BOOL aDocumentNeedsSaving = NO;
  NSEnumerator *e = nil;
  XPDocument *next = nil;
  
  // Check all documents
  e = [[self openDocuments] objectEnumerator];
  while ((next = [e nextObject])) {
    aDocumentNeedsSaving = [next isDocumentEdited];
    if (aDocumentNeedsSaving) { break; }
  }
  
  // Ask the user if they want to quit
  if (!aDocumentNeedsSaving) { return YES; }
  alertResult = XPRunQuitAlert();
  switch (alertResult) {
    case XPAlertReturnDefault:
      return [self __applicationShouldTerminateAfterReviewingAllWindows:sender];
    case XPAlertReturnAlternate: return YES;
    case XPAlertReturnOther:     return NO;
    default:
      XPLogRaise2(@"%@ Unexpected alert result: %ld", self, alertResult);
      return NO;
  }
}

-(BOOL)__applicationShouldTerminateAfterReviewingAllWindows:(NSApplication*)sender;
{
  BOOL allDocumentsSaved = YES;
  NSEnumerator *e = [[self openDocuments] objectEnumerator];
  XPDocument *next = nil;
  while ((next = [e nextObject])) {
    if ([next isDocumentEdited]) {
      [next saveDocument:sender];
      allDocumentsSaved = ![next isDocumentEdited];
    }
    if (allDocumentsSaved) {
      [[next window] performClose:sender];
    } else {
      break;
    }
  }
  return allDocumentsSaved;
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
{
  SVRDocument *document = [[self openDocuments] member:filename];
  if (!document) {
    document = [SVRDocument documentWithContentsOfFile:filename];
    [[self openDocuments] addObject:document];
  }
  [[document window] makeKeyAndOrderFront:sender];
  return YES;
}

-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
{
  [self newDoc:sender];
  return YES;
}
@end
