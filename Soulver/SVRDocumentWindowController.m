#import "SVRDocumentWindowController.h"

@implementation SVRDocumentWindowController

+(NSString*)documentDidChangeFilenameNotification;
{
  return @"SVRDocumentControllerDocumentDidChangeFilenameNotification";
}
-(NSDictionary*)__documentDidChangeFilenameNotificationInfo:(NSString*)oldFilename;
{
  NSArray *keys;
  NSArray *vals;
  if (!oldFilename) { return nil; }
  keys = [NSArray arrayWithObjects:@"oldFilename", nil];
  vals = [NSArray arrayWithObjects:  oldFilename,  nil];
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

// MARK: Properties
-(NSString*)filename;
{
  return _filename;
}

-(void)setFilename:(NSString*)filename;
{
  NSString *oldFileName = [_filename autorelease];
  NSString *newFileName = [filename copy];
  _filename = newFileName;
  [self __updateWindowState];
  [[NSNotificationCenter defaultCenter]
    postNotificationName:[[self class] documentDidChangeFilenameNotification]
    object:self
    userInfo:[self __documentDidChangeFilenameNotificationInfo:oldFileName]];
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
  NSAssert1((SVRDocumentWindowController*)[[self window] delegate] == self,
            @"Incorrect Window Delegate: %@", [[self window] delegate]);

  // Set up Last Responder
  [[self window] setNextResponder:self];
  
  NSLog(@"%@", self);
}

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

-(XPUInteger)__onDiskHash;
{
  SVRMathString *read;
  // TODO: Consider making this has smarter/lazier
  unsigned blankHash = 0;
  if (![self filename]) { return blankHash; }
  read = [SVRMathString mathStringWithFilename:[self filename]];
  if (!read) { return blankHash; }
  return [read hash];
}
-(BOOL)__needsSaving;
{
  XPUInteger lhs = [[[self model] mathString] hash];
  XPUInteger rhs = [self __onDiskHash];
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
  [_viewController release];
  [_window setDelegate:nil];
  [_window setNextResponder:nil];
  // this autorelease (over release) is absolutely necessary
  // to prevent crashes when window is closing
  [_window autorelease];
  [_filename release];
  [_model release];
  _window = nil;
  _filename = nil;
  _model = nil;
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end

// MARK: SVRDocumentWindowController
@implementation SVRDocumentWindowController (NSWindowDelegate)
-(BOOL)windowShouldClose:(id)sender;
{
  XPInteger alertResult;
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
  switch ([menuItem tag]) {
      // Save
    case 2003: return [self __needsSaving];
      // Save As
    case 2004: return [self filename] != nil;
      // Save To
    case 2005: return ([self filename] != nil) && [self __needsSaving];
      // Revert to Saved
      // TODO: Set KeyEquivalent to CMD+U
    case 2007: return ([self filename] != nil) && [self __needsSaving];
    default:
      NSLog(@"%@ validateMenuItem: Unexpected: (%ld)%@",
            self, [menuItem tag], [menuItem title]);
      return NO;
  }
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  XPInteger alertResult = NSRunAlertPanel(@"Revert to Saved",
                                     @"Any changes will be lost",
                                     @"Revert to Saved",
                                     @"Cancel", nil);
#pragma clang diagnostic pop
  switch (alertResult) {
    case 1: [self __revertToSaved]; break;
    default: break;
  }
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
