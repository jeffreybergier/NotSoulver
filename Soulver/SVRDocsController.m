#import "SVRDocsController.h"
#import "SVRDocumentController.h"

@implementation SVRDocsController

// MARK: Properties
-(NSMutableDictionary*)openFiles;
{
  return _openFiles;
}
-(NSMutableDictionary*)openUnsaved;
{
  return _openUnsaved;
}

// MARK: IBActions

- (void)closeDoc:(id)sender
{
}

- (void)newDoc:(id)sender
{
  SVRDocumentController *controller;
  NSWindow *window;
  NSNumber *windowNumber;

  controller = [SVRDocumentController controllerWithFilename:nil];
  window = [controller window];
  windowNumber = [NSNumber numberWithInt:[window windowNumber]];
  
  [[self openUnsaved] setObject:controller forKey:windowNumber];
  [window makeKeyAndOrderFront:self];
}

- (void)openDoc:(id)sender
{
  NSOpenPanel *panel;
  NSString *file;
  SVRDocumentController *controller;

  panel = [NSOpenPanel openPanel];
  [panel setRequiredFileType:@"solv"];
  [panel runModal];
  file = [panel filename];
  if (!file) { NSLog(@"Open Cancelled"); return; }
  controller = [[self openFiles] objectForKey:file];
  if (!controller) {
    controller = [SVRDocumentController controllerWithFilename:file];
    [[self openFiles] setObject:controller forKey:file];
  }
  // TODO: Implement this functionality
  // [controller bringFront];
}

  //[panel runModalForTypes:[NSArray arrayWithObjects:@"solv", nil]];

- (void)saveDoc:(id)sender
{
  NSWindow *window;
  NSNumber *windowNumber;
  SVRDocumentController *documentLHS;
  SVRDocumentController *documentRHS;
  BOOL result;

  window = [[NSApplication sharedApplication] mainWindow];
  windowNumber = [NSNumber numberWithInt:[window windowNumber]];
  documentLHS = [window delegate];
  if ([documentLHS isKindOfClass:[SVRDocumentController class]]) {
    result = [documentLHS saveDocument];
  } else {
    result = NO;
  }
  NSLog(@"Document Save Successful: %d", result);
  if (result) {
    documentRHS = [[self openUnsaved] objectForKey:windowNumber];
    if (documentRHS) {
      NSAssert(documentLHS == documentRHS, @"Open Document Management Error");
      NSAssert([documentRHS filename], @"Open Document Management Error");
      [[self openFiles] setObject:documentRHS forKey: [documentRHS filename]];
      [[self openUnsaved] removeObjectForKey:windowNumber];
      NSLog(@"Confirmed: Moved document from openUnsaved to openFiles");
    } else {
      documentRHS = [[self openFiles] objectForKey:[documentLHS filename]];
      NSAssert(documentLHS == documentRHS, @"Open Document Management Error");
      NSAssert([documentRHS filename], @"Open Document Management Error");
      NSLog(@"Confirmed: Document in saveFiles dictionary");
    }
  }
}

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
  _openFiles = [NSMutableDictionary new];
  _openUnsaved = [NSMutableDictionary new];
}

-(void)dealloc;
{
  [_openFiles release];
  [_openUnsaved release];
}

@end
