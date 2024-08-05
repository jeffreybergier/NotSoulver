//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathString.h"

@implementation SVRMathString

// MARK: Main Business Logic
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

// MARK: Debugging
-(NSString*)description;
{
  return [[super description] stringByAppendingString:_string];
}

// MARK: Init
-(id)init;
{
  self = [super init];
  _string = [NSMutableString new];
  return self;
}

-(id)initWithString:(NSString*)aString;
{
  self = [super init];
  _string = [aString mutableCopy];
  return self;
}

// MARK: Validation
+(BOOL)isValidInput:(NSString*)input;
{
  NSSet *valid = [NSSet setWithObjects:@".", @"/", @"*", @"+", @"-", @"=", @"^", @"(", @")",
                  @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
  return [valid member:input] != nil;
}

// MARK: Dealloc
- (void)dealloc
{
  [_string release];
  [super dealloc];
}

@end

@implementation SVRMathString (Coding)
-(void)encodeWithCoder:(NSCoder*)coder;
{
  [coder encodeObject:_string];
}
-(id)initWithCoder:(NSCoder*)coder;
{
  id string;
  self = [super init];
  string = [coder decodeObject];
  if ([string isKindOfClass:[NSString class]]) {
    _string = string;
    return self;
  } else {
    [self release];
    return nil;
  }
}
-(id)copyWithZone:(NSZone*)zone;
{
  return [[SVRMathString alloc] initWithString:_string];
}
@end
