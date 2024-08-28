#import "SVRDocumentWindowController.h"

@implementation SVRDocumentWindowController

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
-(SVRMathStringModelController*)model;
{
  return _model;
}

// MARK: INIT
-(id)initWithFilename:(NSString*)filename;
{
  self = [super init];
  _filename = [filename retain];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [NSBundle loadNibNamed:@"NEXTSTEP_SVRDocument.nib" owner:self];
#pragma clang diagnostic pop

  return self;
}

+(id)controllerWithFilename:(NSString*)filename;
{
  return [[[SVRDocumentWindowController alloc] initWithFilename:filename] autorelease];
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

  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(__modelRenderDidChangeNotification:)
           name:[SVRMathStringModelController renderDidChangeNotificationName]
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [panel setRequiredFileType:@"solv"];
    [panel runModal];
    filename = [panel filename];
#pragma clang diagnostic pop
    [self setFilename:filename];
  }
  if (!filename) {
    [self __updateWindowState];
    return NO;
  } else {
    result = [[[self model] mathString] writeToFilename:filename];
    [self __updateWindowState];
    return result;
  }
}

+(NSString*)windowDidCloseNotification;
{
  return @"SVRDocumentControllerWindowDidCloseNotification";
}

// MARK: Private

-(void)__updateWindowState;
{
  SVRMathString *rhs;
  SVRMathString *lhs = [[self model] mathString];
  NSString *filename = [self filename];
  // Update Title
  if (filename) {
    [[self window] setTitle:filename];
    [[self window] setRepresentedFilename:filename];
  } else {
    [[self window] setTitle:@"UNTITLED.solv"];
    [[self window] setRepresentedFilename:@""];
  }
  // Update document edited
  if (filename) {
    rhs = [SVRMathString mathStringWithFilename:filename];
    [[self window] setDocumentEdited:![lhs isEqual:rhs]];
  } else {
    [[self window] setDocumentEdited:![lhs isEmpty]];
  }
}

-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [self __updateWindowState];
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_filename release];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

@implementation SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
{
  long alertResult;
  NSDictionary *userInfo;
  NSArray *infoObjects;
  NSArray *infoKeys;
  NSNotificationCenter *center;
  BOOL result = YES;
  if ([[self window] isDocumentEdited]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    alertResult = NSRunAlertPanel(@"Close Document",
                                  @"Save changes before closing?",
                                  @"Save",
                                  @"Cancel",
                                  @"Don't Save");
#pragma clang diagnostic pop
    switch (alertResult) {
      case -1:
        result = YES;
        break;
      case 1:
        result = [self saveDocument];
        break;
      default:
        result = NO;
        break;
    }
  }
  if (result) {
    infoObjects = [NSArray arrayWithObjects:[NSNumber numberWithLong:[[self window] windowNumber]],
                                            [self filename],
                                            nil];
    infoKeys = [NSArray arrayWithObjects:@"windowNumber", [self filename] ? @"filename" : nil, nil];

    userInfo = [NSDictionary dictionaryWithObjects:infoObjects
                                           forKeys:infoKeys];
    center = [NSNotificationCenter defaultCenter]; 
    [center postNotificationName:[SVRDocumentWindowController windowDidCloseNotification]
                          object:self
                        userInfo:userInfo];
  }
  return result;
}
@end
