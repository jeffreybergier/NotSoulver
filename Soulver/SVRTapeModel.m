#import "SVRTapeModel.h"
#import "SVRMathString+Rendering.h"

@implementation SVRTapeModel

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
  [[NSNotificationCenter defaultCenter] postNotificationName:[SVRTapeModel renderDidChangeNotificationName] 
                                                      object:_latestRender];
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
-(void)appendString:(NSString*)aString;
{
  [[self mathString] appendString:aString];
  [self setLatestRender:[[self mathString] render]];
}
-(void)backspace;
{
  [[self mathString] backspace];
  [self setLatestRender:[[self mathString] render]];
}

-(void)dealloc;
{
  [_mathString release];
  [_latestRender release];
  [super dealloc];
}






@end