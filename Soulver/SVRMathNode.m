//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathNode.h"

@implementation SVRMathNode

// MARK: Properties

-(SVRMathNode*)nextNode;
{
  return _nextNode;
}

-(void)setNextNode:(SVRMathNode*)aNode;
{
  [_nextNode release];
  _nextNode = [aNode retain];
}
-(NSString*)value;
{
  return _value;
}
-(void)setValue:(NSString*)aString;
{
  [_value release];
  _value = [aString retain];
}

// MARK: Init
-(id)initWithValue:(NSString*)aString;
{
  if ([SVRMathNode isValidInput:aString]) {
    self = [super init];
    [self setNextNode:nil];
    [self setValue:aString];
    return self;
  } else {
    return nil;
  }
}

+(id)nodeWithValue:(NSString*)aString;
{
  return [[[SVRMathNode alloc] initWithValue:aString] autorelease];
}

// MARK: Usage
-(void)appendNode:(SVRMathNode*)aNode;
{
  SVRMathNode *next = [self nextNode];
  if (!next) {
    [self setNextNode:aNode];
    return;
  }
  while (next) {
    if (![next nextNode]) {
      [next setNextNode:aNode];
      next = nil;
    } else {
      next = [next nextNode];
    }
  }
}

// MARK: DEINIT
- (void)dealloc
{
  [self setValue:nil];
  [self setNextNode:nil];
  [super dealloc];
}

+(BOOL)isValidInput:(NSString*)input;
{
  return [[NSSet setWithObjects:@".", @"/", @"*", @"+", @"-", @"0", @"1", @"2", @"3", @"4", @"5",
          @"6", @"7", @"8", @"9", @"=", nil] member:input] != nil;
}

@end
