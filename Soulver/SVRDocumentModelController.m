#import "SVRDocumentModelController.h"
#import "SVRCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRDocumentModelController

// MARK: Properties
-(NSTextStorage*)model;
{
  return [[_model retain] autorelease];
}
-(void)setModel:(NSTextStorage*)newModel;
{
  [_model release];
  _model = [newModel retain];
}

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


@implementation SVRDocumentModelController (TextDelegate)

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog extra:@"%@ textStorageWillProcessEditing: `%@`", self, [storage string]];
  [SVRSolver annotateStorage:storage];
  [SVRSolver solveAnnotatedStorage:storage];
  [SVRSolver colorAnnotatedAndSolvedStorage:storage];
}
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog extra:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
}

@end
