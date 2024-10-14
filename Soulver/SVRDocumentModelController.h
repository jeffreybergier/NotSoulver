#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

@interface SVRDocumentModelController: NSObject
{
  IBOutlet NSTextStorage *_model;
}

// MARK: Properties
-(NSTextStorage*)model;

// MARK: Init
-(id)initWithModel:(NSTextStorage*)model;

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(XPErrorPointer)errorPointer;
-(int)backspaceCharacterWithError:(XPErrorPointer)errorPointer;
-(int)backspaceLineWithError:(XPErrorPointer)errorPointer;
-(int)backspaceAllWithError:(XPErrorPointer)errorPointer;

@end

#if OS_OPENSTEP
@interface SVRDocumentModelController (TextDelegate)
#else
@interface SVRDocumentModelController (TextDelegate) <NSTextStorageDelegate, NSTextViewDelegate>
#endif

-(void)textStorageWillProcessEditing:(NSNotification*)aNotification;
-(void)textStorageDidProcessEditing:(NSNotification*)aNotification;
-(void)textDidBeginEditing:(NSNotification *)notification;
-(void)textDidEndEditing:(NSNotification *)notification;

@end
