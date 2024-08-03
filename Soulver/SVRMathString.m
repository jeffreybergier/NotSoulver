//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathString.h"

@implementation SVRMathString

-(void)appendString:(NSString*)aString;
{
  NSRange scanRange;
  unsigned int scanRangeMax;
  NSString *scanString;
  
  scanRange = NSMakeRange(0, 1);
  scanRangeMax = [aString length];
  
  while (scanRange.location < scanRangeMax) {
    scanString = [aString substringWithRange:scanRange];
    if (![SVRMathString isValidInput:scanString]) {
      NSLog(@"Invalid Input: %@", scanString);
      return;
    }
    scanRange.location += 1;
  }
  [_string appendString:aString];
}

-(void)backspace;
{
  NSRange range;
  unsigned int length;
  
  length = [_string length];
  
  switch (length) {
    case 0:
      return;
    case 1:
      [_string setString:@""];
      return;
    default:
      range = NSMakeRange(length - 1, 1);
      [_string deleteCharactersInRange:range];
      return;
  }
}

-(NSString*)description;
{
  return [[super description] stringByAppendingString:_string];
}

-(id)init;
{
  self = [super init];
  _string = [NSMutableString new];
  return self;
}

+(BOOL)isValidInput:(NSString*)input;
{
  NSSet *valid = [NSSet setWithObjects:@".", @"/", @"*", @"+", @"-", @"=", @"^", @"(", @")",
                  @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
  return [valid member:input] != nil;
}

- (void)dealloc
{
  [_string release];
  [super dealloc];
}

@end
