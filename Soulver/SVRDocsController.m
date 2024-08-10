#import "SVRDocsController.h"
#import "SVRDocumentController.h"

@implementation SVRDocsController

// MARK: Properties
-(NSMutableDictionary*)openFiles;
{
  return _openFiles;
}
-(NSMutableArray*)openUnsaved;
{
  return _openUnsaved;
}

// MARK: IBActions

- (void)closeDoc:(id)sender
{
}

- (void)newDoc:(id)sender
{
  [[self openUnsaved] addObject:[SVRDocumentController controllerWithFilename:nil]];
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
  SVRMathString *document;
  NSSavePanel *panel;
  NSString *file;
  BOOL result;

  panel = [NSSavePanel savePanel];
  [panel setRequiredFileType:@"solv"];
  [panel runModal];
  file = [panel filename];
  if (!file) { NSLog(@"Save Cancelled"); return; }

  document = [SVRMathString mathStringWithString:@"2+2=-4="];
  result = [document writeToFilename:file];
  if (result) { NSLog(@"Saved: %@", file); }
  else { NSLog(@"Failed: %@", file); }
}

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
  _openFiles = [NSMutableDictionary new];
  _openUnsaved = [NSMutableArray new];
}

-(void)dealloc;
{
  [_openFiles release];
  [_openUnsaved release];
}

@end
