#import "SVRDocumentController.h"

@implementation SVRDocumentController

-(id)initWithFilePath:(NSString*)aPath;
{
  self = [super init];
  [NSBundle loadNibNamed:@"NEXTSTEP_SVRDocument.nib" owner:self];
  _filePath = [aPath retain];
  return self;
}

@end
