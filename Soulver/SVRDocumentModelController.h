#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

@interface SVRDocumentModelController: NSObject
{
  IBOutlet NSTextStorage *_model;
}

// MARK: Properties
-(NSTextStorage*)model;

// MARK: Init
-(id)init;

// MARK: NSDocument Support
-(NSData*)dataRepresentationOfType:(NSString*)type;
-(BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)type;

// MARK: Usage
-(void)appendCharacter:(NSString*)aString;
-(void)backspaceCharacter;
-(void)backspaceLine;
-(void)backspaceAll;

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
