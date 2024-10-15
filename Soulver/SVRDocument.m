#import "SVRDocument.h"

@implementation SVRDocument

// MARK: Properties

-(SVRDocumentViewController*)viewController;
{
  return [[_viewController retain] autorelease];
}

-(NSTextStorage*)model;
{
  return [[_model retain] autorelease];
}

-(NSString*)windowNibName;
{
#if OS_OPENSTEP
  return @"NEXTSTEP_SVRDocument.nib";
#else
  return @"MACOSX_SVRDocument.nib";
#endif
}

// MARK: INIT
-(id)initWithContentsOfFile:(NSString*)fileName;
{
  _model = [NSTextStorage new]; // need to do before call super init
  self = [super initWithContentsOfFile:fileName ofType:@"solv"];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:_model];
  return self;
}

+(id)documentWithContentsOfFile:(NSString*)fileName;
{
  return [[[SVRDocument alloc] initWithContentsOfFile:fileName] autorelease];
}

// MARK: NSDocument subclass

-(void)awakeFromNib;
{
  [[self viewController] updateModel:[self model]];
  [super awakeFromNib];
  [XPLog debug:@"awakeFromNib: %@", self];
}

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[[self model] string] dataUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  BOOL success = NO;
  NSString *string = [
    [[NSString alloc] initWithData:data
                          encoding:NSUTF8StringEncoding]
    autorelease];
  if (string) {
    [ [self model] beginEditing];
    [[[self model] mutableString] setString:string];
    [ [self model] endEditing];
    success = YES;
  }
  return success;
}

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem;
{
  switch ([menuItem tag]) {
    // TODO: Update Menus to be stock again
      // Save, logic allows saving if needed or if its a new document
    case 2003: return YES;
      // Save As
    case 2004: return YES;
      // Save To
    case 2005: return YES;
      // Revert to Saved
    case 2007: return YES;
      // Copy Render
    case 3001: return YES;
      // Copy
    case 3002: return YES;
      // Paste
    case 3003: return YES;
    default:
      [XPLog debug:@"%@ validateMenuItem: Unexpected: (%ld)%@", self, [menuItem tag], [menuItem title]];
      return YES;
  }
}

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;
{
  [self updateWindowState];
}

-(void)dealloc;
{
  [_viewController release];
  [_model release];
  _viewController = nil;
  _model = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
