#import "SVRDocumentModelController.h"
#import "SVRMathString+Rendering.h"

@implementation SVRDocumentModelController

// MARK: Properties

-(SVRMathString*)mathString;
{
  return _mathString;
}
-(void)setMathString:(SVRMathString*)aString;
{
  NSNumber *error;
  [_mathString release];
  _mathString = [aString retain];
  [self setLatestRender:[_mathString renderWithError:&error]];
  if (error != nil) { NSLog(@"%@: setMathString: %@: Error: %@", self, aString, error); }
}
-(NSAttributedString*)latestRender;
{
  return _latestRender;
}
-(void)setLatestRender:(NSAttributedString*)aString;
{
  [_latestRender release];
  _latestRender = [aString retain];
  [[NSNotificationCenter defaultCenter]
    postNotificationName:[SVRDocumentModelController
                          renderDidChangeNotificationName] 
                  object:self];
}
+(NSString*)renderDidChangeNotificationName;
{
  return [NSString stringWithFormat:@"RenderDidChange"];
}

// MARK: Interface Builder
-(void)awakeFromNib;
{
  NSLog(@"%@", self);
  _mathString = [[SVRMathString alloc] init];
}

// MARK: Usage
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)errorPointer;
{
  NSNumber *error = errorPointer ? *errorPointer : nil;
  int result = 0;
  if (error != nil) { return -1; }
  [[self mathString] appendEncodedString:aString];
  [self setLatestRender:[[self mathString] renderWithError:&error]];
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return -1; }
  return result;
}
-(int)backspaceWithError:(NSNumber**)errorPointer;
{
  NSNumber *error = errorPointer ? *errorPointer : nil;
  int result = 0;
  if (error != nil) { return -1; }
  [[self mathString] backspace];
  [self setLatestRender:[[self mathString] renderWithError:&error]];
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return -1; }
  return result;
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_mathString release];
  [_latestRender release];
  [super dealloc];
}






@end
