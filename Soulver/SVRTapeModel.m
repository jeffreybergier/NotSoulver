#import "SVRTapeModel.h"
#import "SVRMathNode+Rendering.h"

@implementation SVRTapeModel

// MARK: Properties

-(SVRMathNode*)mathNode;
{
  return _mathNode;
}
-(void)setMathNode:(SVRMathNode*)aNode;
{
  [_mathNode release];
  _mathNode = [aNode retain];
  [self setLatestRender:[_mathNode render]];
}
-(NSString*)latestRender;
{
  return _latestRender;
}
-(void)setLatestRender:(NSString*)aString;
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
}

// MARK: Handle Input

-(void)append:(SVRMathNode*)aNode;
{
  if ([self mathNode]) {
    [[self mathNode] appendNode:aNode];
  } else {
    [self setMathNode:aNode];
  }
  [self setLatestRender:[[self mathNode] render]];
}











@end