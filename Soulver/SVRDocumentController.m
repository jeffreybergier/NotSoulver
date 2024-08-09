#import "SVRDocumentController.h"

@implementation SVRDocumentController

// MARK: Properties
-(NSString*)filename;
{
  return _filename;
}
-(void)setFilename:(NSString*)filename;
{
  [_filename release];
  _filename = [filename retain];
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
-(id)initWithFilename:(NSString*)filename;
{
  self = [super init];
  _filename = [filename retain];
  [NSBundle loadNibNamed:@"NEXTSTEP_SVRDocument.nib" owner:self];
  return self;
}

+(id)controllerWithFilename:(NSString*)filename;
{
  return [[[SVRDocumentController alloc] initWithFilename:filename] autorelease];
}

-(void)awakeFromNib;
{
  SVRMathString *document;
  NSString *filename;
  NSLog(@"%@", self);
  [self __updateWindowState];
  filename = [self filename];
  if (filename) {
    NSLog(@"Opening File: %@", filename);
    document = [NSUnarchiver unarchiveObjectWithFile:filename];
    if (!document) { NSLog(@"Open File Failed: %@", filename); return; }
    //[[self model] setMathString:document];
  }
}

-(void)__updateWindowState;
{
  NSString *filename = [self filename];
  if (filename) {
    [[self window] setDocumentEdited:NO];
    [[self window] setTitle:filename];
    [[self window] setRepresentedFilename:filename];
  } else {
    [[self window] setDocumentEdited:YES];
    [[self window] setTitle:@"UNTITLED.solv"];
    [[self window] setRepresentedFilename:@""];
  }
}

@end
