#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

@interface SVRDocumentModelController: NSObject
{
  mm_new      NSTextStorage *_model;
  mm_new      NSTimer       *_waitTimer;
  mm_unretain NSTextView    *_textView;
}

// MARK: Properties
-(NSTextStorage*)model;
-(NSTextView*)textView;
-(void)setTextView:(NSTextView*)textView;

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
@interface SVRDocumentModelController (TextDelegate) <NSTextViewDelegate>
#endif

-(void)resetWaitTimer;
-(void)waitTimerFired:(NSTimer*)timer;
-(void)textDidChange:(NSNotification*)notification;

@end
