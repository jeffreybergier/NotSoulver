#import "SVRTapeModel.h"
#import "SVRTapeModelOperation.h"

@implementation SVRTapeModel

// MARK: Properties
-(void)initializeProperties;
{
  operations = [[[NSMutableArray alloc] init] retain];
  strokeInput = [[[NSMutableString alloc] init] retain];
}

-(void)strokeInputReset;
{
  [strokeInput release];
  strokeInput = [[[NSMutableString alloc] init] retain];
}

// MARK: Interface Builder
-(void)awakeFromNib;
{
  NSLog(@"%@", self);
  [self initializeProperties];
}

// MARK: Handle Input

-(void)appendKeyStroke:(NSString *)aStroke;
{
  SVRTapeModelOperator operator = [SVRTapeModelOperation operatorForString:aStroke];
  if (operator == SVRTapeModelOperatorUnknown) {
    [strokeInput appendString: aStroke];
    NSLog(@"%@", strokeInput);
  } else {
    float value = [strokeInput floatValue]; 
    [operations addObject:[[SVRTapeModelOperation alloc] initWithValue:value operator:operator]];
    NSLog(@"%@", operations);
  }
}

@end