#import <AppKit/AppKit.h>

@interface SVRDocumentModelController: NSObject

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)errorPointer;
-(int)backspaceCharacterWithError:(NSNumber**)errorPointer;
-(int)backspaceLineWithError:(NSNumber**)errorPointer;
-(int)backspaceAllWithError:(NSNumber**)errorPointer;

@end
