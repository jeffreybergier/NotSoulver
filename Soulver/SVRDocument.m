#import "SVRDocument.h"

@implementation SVRDocument

// MARK: Properties

-(SVRDocumentViewController*)viewController;
{
  return [[_viewController retain] autorelease];
}

-(NSString*)windowNibName;
{
#ifdef __MAC_10_0
  return @"MACOSX_SVRDocument.nib";
#else
  return @"NEXTSTEP_SVRDocument.nib";
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
  id previousNextResponder = nil;
  
  [super awakeFromNib];
  
  // Add view controller into the responder chain
  previousNextResponder = [[self window] nextResponder];
  [[self window] setNextResponder:[self viewController]];
  [[self viewController] setNextResponder:self];
  [self setNextResponder:previousNextResponder];
  
  // Subscribe to model updates
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(modelDidProcessEditingNotification:)
                                               name:NSTextStorageDidProcessEditingNotification
                                             object:[[[self viewController] modelController] model]];
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
  [self updateWindowChrome];
}

-(void)dealloc;
{
  [_viewController release];
  _viewController = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
