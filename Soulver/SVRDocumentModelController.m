#import "SVRDocumentModelController.h"
#import "SVRSolver.h"

@implementation SVRDocumentModelController

// MARK: Properties
-(NSTextStorage*)model;
{
  return [[_model retain] autorelease];
}

// MARK: Init
-(id)initWithModel:(NSTextStorage*)model;
{
  self = [super init];
  _model = [_model retain];
  return self;
}

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(XPErrorPointer)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}
-(int)backspaceCharacterWithError:(XPErrorPointer)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}

-(int)backspaceLineWithError:(XPErrorPointer)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}

-(int)backspaceAllWithError:(XPErrorPointer)errorPointer;
{
  [XPLog error:@"Unimplemented"];
  return -1;
}

-(void)dealloc;
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_model release];
  _model = nil;
  [super dealloc];
}

@end


@implementation SVRDocumentModelController (TextDelegate)

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageWillProcessEditing: `%@`", self, [storage string]];
  [SVRSolver removeAllSolutionsAndTags:storage];
  [SVRSolver solveAndTagAttributedString:storage];
}
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog debug:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
  [SVRSolver styleSolvedAndTaggedAttributedString:storage];
}

@end
