#import "SVRDocumentWindowController.h"

@implementation SVRDocumentWindowController

+(NSString*)documentDidSaveAsNotification;
{
  return @"SVRDocumentControllerDocumentDidSaveAsNotification";
}

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

-(SVRDocumentModelController*)model;
{
  return _model;
}

-(NSObject*)viewController;
{
  return _viewController;
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@ <Window: %ld> <File: %@>",
         [super description], [[self window] windowNumber], [self filename]];
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

  // Read the file if there is a filepath
  filename = [self filename];
  if (filename) {
    NSLog(@"Opening File: %@", filename);
    document = [SVRMathString mathStringWithFilename:filename];
    if (!document) { NSLog(@"Open File Failed: %@", filename); return; }
    [[self model] setMathString:document];
  }
  [self __updateWindowState];

  // Register for notifications from the model
  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(__modelRenderDidChangeNotification:)
           name:[SVRDocumentModelController renderDidChangeNotificationName]
         object:[self model]];

  // Check to make sure we are delegate
  NSAssert1([[self window] delegate] == self, @"Incorrect Window Delegate: %@", [[self window] delegate]);

  // Set up Last Responder
  [[self window] setNextResponder:self];
  
  NSLog(@"%@", self);
}

/*
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
 */

// MARK: Private

-(void)__updateWindowState;
{
  // Update Title
  if ([self filename]) {
    [[self window] setTitle:[self filename]];
    [[self window] setRepresentedFilename:[self filename]];
  } else {
    [[self window] setTitle:@"UNTITLED.solv"];
    [[self window] setRepresentedFilename:@""];
  }
  [[self window] setDocumentEdited:[self __needsSaving]];
}

-(void)__modelRenderDidChangeNotification:(NSNotification*)aNotification;
{
  [self __updateWindowState];
}

-(unsigned long)__onDiskHash;
{
  SVRMathString *read;
  unsigned long blankHash = [[SVRMathString mathStringWithString:@""] hash];
  if (![self filename]) { return blankHash; }
  read = [SVRMathString mathStringWithFilename:[self filename]];
  if (!read) { return blankHash; }
  return [read hash];
}
-(BOOL)__needsSaving;
{
  unsigned long lhs = [[[self model] mathString] hash];
  unsigned long rhs = [self __onDiskHash];
  return lhs != rhs;
}

-(NSString*)__runSavePanel;
{
  NSString *output = nil;
  NSSavePanel *panel = [NSSavePanel savePanel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [panel setRequiredFileType:@"solv"];
  [panel runModal];
  output = [panel filename];
#pragma clang diagnostic pop
  return output;
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_filename release];
  [_model release];
  [_viewController release];
  _filename = nil;
  _model = nil;
  _viewController = nil;
  _window = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

// MARK: SVRDocumentWindowController
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

// MARK: NSMenuActionResponder
@implementation SVRDocumentWindowController (NSMenuActionResponder)

-(void)keyUp:(NSEvent*)theEvent;
{
  NSLog(@"keyUp: %@", theEvent);
}

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  NSLog(@"validateMenuItem: %@", menuItem);
  return YES;
}

-(void)cut:(id)sender;
{
  NSLog(@"%@ cut: %@", self, sender);
}

-(void)copy:(id)sender;
{
  NSLog(@"%@ copy: %@", self, sender);
}

-(void)paste:(id)sender;
{
  NSLog(@"%@ paste: %@", self, sender);
}

-(void)revertToSaved:(id)sender;
{
  NSLog(@"%@ revertToSaved: %@", self, sender);
}

-(void)save:(id)sender;
{
  NSLog(@"%@ save: %@", self, sender);
}

-(void)saveAs:(id)sender;
{
  NSLog(@"%@ saveAs: %@", self, sender);
}

-(void)saveTo:(id)sender;
{
  NSLog(@"%@ saveTo: %@", self, sender);
}

@end
