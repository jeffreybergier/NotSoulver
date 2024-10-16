#import "SVRDocumentModelController.h"
#import "SVRSolver.h"

@implementation SVRDocumentModelController

// MARK: Properties
-(NSTextStorage*)model;
{
  return [[_model retain] autorelease];
}

// MARK: Init
-(id)init;
{
  self = [super init];
  _model = [NSTextStorage new];
  return self;
}

// MARK: NSDocument Support
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
  [XPLog extra:@"%@ textStorageWillProcessEditing: `%@`", self, [storage string]];
  [SVRSolver removeAllSolutionsAndTags:storage];
  [SVRSolver solveAndTagAttributedString:storage];
}
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
{
  NSTextStorage *storage = [aNotification object];
  [XPLog extra:@"%@ textStorageDidProcessEditing: `%@`", self, [storage string]];
  [SVRSolver styleSolvedAndTaggedAttributedString:storage];
}

-(void)textDidBeginEditing:(NSNotification *)notification;
{
  [XPLog extra:@"%@ textDidBeginEditing:", self];
}

-(void)textDidEndEditing:(NSNotification *)notification;
{
  [XPLog extra:@"%@ textDidEndEditing:", self];
}

@end
