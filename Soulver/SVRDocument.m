#import "SVRDocument.h"

@implementation SVRDocument

-(id)initWithContentsOfFile:(NSString*)fileName;
{
  return [super initWithContentsOfFile:fileName ofType:@"solv"];
}

+(id)documentWithContentsOfFile:(NSString*)fileName;
{
  return [[[SVRDocument alloc] initWithContentsOfFile:fileName] autorelease];
}

// MARK: Properties
-(NSString*)windowNibName;
{
#if OS_OPENSTEP
  return @"NEXTSTEP_SVRDocument.nib";
#else
  return @"MACOSX_SVRDocument.nib";
#endif
}

-(NSObject*)viewController;
{
  return _viewController;
}

-(SVRDocumentModelController*)modelController;
{
  return _modelController;
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
      return NO;
  }
}

-(void)dealloc;
{
  [_viewController release];
  [_modelController release];
  _viewController = nil;
  _modelController = nil;
  [super dealloc];
}

@end
