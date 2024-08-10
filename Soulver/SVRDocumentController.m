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
    document = [SVRMathString mathStringWithFilename:filename];
    if (!document) { NSLog(@"Open File Failed: %@", filename); return; }
    [[self model] setMathString:document];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__modelRenderDidChangeNotification:)
                                               name:[SVRTapeModel renderDidChangeNotificationName]
                                             object:[self model]];
}

// MARK: Saving
-(BOOL)saveDocument;
{
  NSString *filename;
  NSSavePanel *panel;
  BOOL result;

  filename = [self filename];
  if (!filename) {
    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:@"solv"];
    [panel runModal];
    filename = [panel filename];
    [self setFilename:filename];
  }
  if (!filename) { return NO; }
  result = [[[self model] mathString] writeToFilename:filename];
  if (result) { [[self window] setDocumentEdited:NO]; }
  return result;
}

// MARK: Private

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

-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [[self window] setDocumentEdited:YES];
}

-(void)dealloc;
{
  [_filename release];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
