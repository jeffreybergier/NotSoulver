#import "SVRMathStringModelController.h"
#import "SVRMathString+Rendering.h"

@implementation SVRMathStringModelController

// MARK: Properties

-(SVRMathString*)mathString;
{
  return _mathString;
}
-(void)setMathString:(SVRMathString*)aString;
{
  [_mathString release];
  _mathString = [aString retain];
  [self setLatestRender:[_mathString render]];
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
    postNotificationName:[SVRMathStringModelController
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
-(int)appendCharacter:(NSString*)aString error:(NSNumber**)error;
{
  int result = [[self mathString] appendCharacter:aString error:error];
  [self setLatestRender:[[self mathString] render]];
  return result;
}
-(void)backspace;
{
  [[self mathString] backspace];
  [self setLatestRender:[[self mathString] render]];
}

-(void)dealloc;
{
  NSLog(@"DEALLOC: %@", self);
  [_mathString release];
  [_latestRender release];
  [super dealloc];
}






@end