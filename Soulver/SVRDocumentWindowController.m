#import "SVRDocumentWindowController.h"

@implementation SVRDocumentWindowController

+(NSString*)documentDidChangeFilenameNotification;
{
  return @"SVRDocumentControllerDocumentDidChangeFilenameNotification";
}
-(NSDictionary*)__didChangeOldFilename:(NSString*)old toNewFilename:(NSString*)new;
{
  id oldFilename = (old) ? old : [NSNull null];
  id newFilename = (new) ? new : [NSNull null];
  NSArray *keys = [NSArray arrayWithObjects:@"oldFilename", @"newFilename", nil];
  NSArray *vals = [NSArray arrayWithObjects:  oldFilename,    newFilename,  nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Properties
-(NSString*)filename;
{
  return _filename;
}

-(void)setFilename:(NSString*)_newFilename;
{
  NSString *oldFileName = [_filename autorelease];
  NSString *newFileName = [_newFilename copy];
  _filename = newFileName;
  [self __updateWindowState];
  [[NSNotificationCenter defaultCenter]
    postNotificationName:[[self class] documentDidChangeFilenameNotification]
    object:self
    userInfo:[self __didChangeOldFilename:oldFileName toNewFilename:newFileName]];
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
  NSAssert1((SVRDocumentWindowController*)[[self window] delegate] == self, @"Incorrect Window Delegate: %@", [[self window] delegate]);

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
  if (![self __needsSaving]) { return YES; }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  alertResult = NSRunAlertPanel(@"Close Document",
                                @"Save changes before closing?",
                                @"Save",
                                @"Cancel",
                                @"Don't Save");
#pragma clang diagnostic pop
  switch (alertResult) {
    case 1:
      return [self __save];
    case -1:
      return YES;
    default:
      return NO;
  }
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

-(void)save:(id)sender;
{
  [self __save];
}

-(void)saveAs:(id)sender;
{
  [self __saveAs];
}

-(void)saveTo:(id)sender;
{
  [self __saveTo];
}

-(void)revertToSaved:(id)sender;
{
  [self __revertToSaved];
}

-(BOOL)__save;
{
  if (![self filename]) { return [self __saveAs]; }
  if (![[[self model] mathString] writeToFilename:[self filename]])
     { NSLog(@"%@ __save: FAILED: %@", self, [self filename]); return NO; }
  NSLog(@"%@ __save: SUCCESS: %@", self, [self filename]);
  [self __updateWindowState];
  return YES;
}

-(BOOL)__saveAs;
{
  NSString *newFilename = [self __runSavePanel];
  if (!newFilename) { NSLog(@"%@ __saveAs: CANCELLED", self); return NO; }
  if (![[[self model] mathString] writeToFilename:newFilename])
     { NSLog(@"%@ __saveAs: FAILED: %@", self, newFilename); return NO; }
  [self setFilename:newFilename];
  NSLog(@"%@ __saveAs: SUCCESS: %@", self, newFilename);
  return YES;
}

-(BOOL)__saveTo;
{
  NSString *newFilename = [self __runSavePanel];
  if (!newFilename) { NSLog(@"%@ __saveTo: CANCELLED", self); return NO; }
  if ([[[self model] mathString] writeToFilename:newFilename])
     { NSLog(@"%@ __saveTo: FAILED: %@", self, newFilename); return NO; }
  NSLog(@"%@ __saveTo: SUCCESS: %@", self, newFilename);
  return YES;
}

-(BOOL)__revertToSaved;
{
  // TODO: Put in an alert here
  SVRMathString *replacement = nil;
  if (![self filename]) { NSLog(@"%@ revertToSaved: FAILED: No Filename", self); return NO; }
  replacement = [SVRMathString mathStringWithFilename:[self filename]];
  if (!replacement) { NSLog(@"%@ revertToSaved: FAILED: %@", self, [self filename]); return NO; }
  [[self model] setMathString:replacement];
  [self __updateWindowState];
  NSLog(@"%@ revertToSaved: SUCCESS: %@", self, [self filename]);
  return YES;
}

@end
