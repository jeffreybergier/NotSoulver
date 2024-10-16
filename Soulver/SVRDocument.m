#import "SVRDocument.h"

@implementation SVRDocument

// MARK: Properties

-(SVRDocumentViewController*)viewController;
{
  return [[_viewController retain] autorelease];
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
  self = [super initWithContentsOfFile:fileName ofType:@"solv"];
  return self;
}

+(id)documentWithContentsOfFile:(NSString*)fileName;
{
  return [[[SVRDocument alloc] initWithContentsOfFile:fileName] autorelease];
}

// MARK: NSDocument subclass

-(void)awakeFromNib;
{
  NSTextStorage *model = [[[self viewController] modelController] model];
  NSAssert(model, @"");
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:model];
  [super awakeFromNib];
}

-(NSData*)dataRepresentationOfType:(NSString*)type;
{
  return [[[self viewController] modelController] dataRepresentationOfType:type];
}

-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;
{
  return [[[self viewController] modelController] loadDataRepresentation:data ofType:type];
}

// MARK: Model Changed Notifications
-(void)modelDidProcessEditingNotification:(NSNotification*)aNotification;
{
  [self updateWindowState];
}

// MARK: IBActions
-(IBAction)keypadAppend:(id)sender;
{
  NSLog(@"keypadAppend: %@<%d>", [sender title], [sender tag]);
}

-(void)dealloc;
{
  [_viewController release];
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
