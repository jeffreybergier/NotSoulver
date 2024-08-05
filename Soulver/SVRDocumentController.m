#import "SVRDocumentController.h"

@implementation SVRDocumentController

// MARK: Properties
-(NSString*)filePath;
{
  return _filePath;
}
-(void)setFilePath:(NSString*)aPath;
{
  [_filePath release];
  _filePath = [aPath retain];
  [self __updateWindowState];
}
-(NSWindow*)window;
{
  return _window;
}
-(SVRTapeModel*)model;
{
  return _model;
}

// MARK: INIT
-(id)initWithFilePath:(NSString*)aPath;
{
  self = [super init];
  [NSBundle loadNibNamed:@"NEXTSTEP_SVRDocument.nib" owner:self];
  _filePath = [aPath retain];
  return self;
}

+(id)controllerWithFilePath:(NSString*)aPath;
{
  return [[[SVRDocumentController alloc] initWithFilePath:aPath] autorelease];
}

-(void)awakeFromNib;
{
  NSLog(@"%@", self);
  [self __updateWindowState];
}

-(void)__updateWindowState;
{
  if ([self filePath]) {
    [[self window] setDocumentEdited:NO];
    [[self window] setTitle:@""];
    [[self window] setRepresentedFilename:[self filePath]];
  } else {
    [[self window] setDocumentEdited:YES];
    [[self window] setTitle:@"UNTITLED.solv"];
    [[self window] setRepresentedFilename:@""];
  }
}

@end
