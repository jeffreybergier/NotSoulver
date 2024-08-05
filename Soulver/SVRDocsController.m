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
  [[self openUnsaved] addObject:[SVRDocumentController controllerWithFilePath:nil]];
}

- (void)openDoc:(id)sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel runModalForTypes:[NSArray arrayWithObjects:@"solv", nil]];
}

- (void)saveDoc:(id)sender
{
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
