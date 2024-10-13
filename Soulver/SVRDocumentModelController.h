#import <AppKit/AppKit.h>

@interface SVRDocumentModelController: NSObject
{
  IBOutlet NSTextStorage *_model;
}

// MARK: Properties
-(NSTextStorage*)model;
-(void)setModel:(NSTextStorage*)newModel;

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)errorPointer;
-(int)backspaceCharacterWithError:(NSNumber**)errorPointer;
-(int)backspaceLineWithError:(NSNumber**)errorPointer;
-(int)backspaceAllWithError:(NSNumber**)errorPointer;

@end

#if OS_OPENSTEP
@interface SVRDocumentModelController (TextDelegate)
#else
@interface SVRDocumentModelController (TextDelegate) <NSTextStorageDelegate>
#endif

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;

@end
