#import "SVRDocumentModelController.h"
#import "SVRMathString+Rendering.h"

@implementation SVRDocumentModelController

// MARK: Properties
+(NSString*)renderDidChangeNotificationName;
{
  return [NSString stringWithFormat:@"RenderDidChange"];
}

-(SVRMathString*)mathString;
{
  return _mathString;
}

-(void)setMathString:(SVRMathString*)mathString;
{
  NSNumber *error = nil;
  [_mathString release];
  _mathString = [mathString retain];
  [self setLatestRender:[mathString renderWithError:&error]];
  if (error != nil) { NSLog(@"%@: setMathString: %@: Error: %@",
                            self, mathString, error); }
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

-(NSString*)description;
{
  return [NSString stringWithFormat:@"%@: %@",
          [super description], [self mathString]];
}

// MARK: Interface Builder
-(void)awakeFromNib;
{
  _mathString = [[SVRMathString alloc] init];
  _latestRender = [NSAttributedString new];
  NSLog(@"%@", self);
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
-(int)backspaceCharacterWithError:(NSNumber**)errorPointer;
{
  NSNumber *error = errorPointer ? *errorPointer : nil;
  int result = 0;
  if (error != nil) { return -1; }
  [[self mathString] backspaceCharacter];
  [self setLatestRender:[[self mathString] renderWithError:&error]];
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return -1; }
  return result;
}

-(int)backspaceLineWithError:(NSNumber**)errorPointer;
{
  NSNumber *error = errorPointer ? *errorPointer : nil;
  int result = 0;
  if (error != nil) { return -1; }
  [[self mathString] backspaceLine];
  [self setLatestRender:[[self mathString] renderWithError:&error]];
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return -1; }
  return result;
}

-(int)backspaceAllWithError:(NSNumber**)errorPointer;
{
  NSNumber *error = errorPointer ? *errorPointer : nil;
  int result = 0;
  if (error != nil) { return -1; }
  [[self mathString] backspaceAll];
  [self setLatestRender:[[self mathString] renderWithError:&error]];
  if (error != nil) { if (errorPointer) { *errorPointer = error; } return -1; }
  return result;
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_mathString release];
  [_latestRender release];
  _mathString = nil;
  _latestRender = nil;
  [super dealloc];
}






@end
