#import "SVRDocumentModelController.h"
#import "SVRCrossPlatform.h"

@implementation SVRDocumentModelController

// MARK: Interface Builder
-(void)awakeFromNib;
{
  [XPLog debug:@"%@ awakeFromNib", self];
}

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}
-(int)backspaceCharacterWithError:(NSNumber**)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}

-(int)backspaceLineWithError:(NSNumber**)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}

-(int)backspaceAllWithError:(NSNumber**)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [super dealloc];
}

@end
