//
//  SVRCharacterNode.m
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/07/29.
//

#import "SVRMathString.h"
#import "NSString+Soulver.h"

@implementation SVRMathString

// MARK: Main Business Logic

+(NSDictionary*)operatorEncodeMap;
{
  return [NSDictionary SVROperatorEncodeMap];
}
+(NSDictionary*)operatorDecodeMap;
{
  return [NSDictionary SVROperatorDecodeMap];
}

-(int)appendCharacter:(NSString*)aString error:(NSNumber**)error;
{
  NSString *operator = [[SVRMathString operatorEncodeMap] objectForKey:aString];
  if (operator) {
    [_string appendString:operator];
    return 0;
  } else if ([[NSSet SVRAllowedCharacters] member:aString]) {
    [_string appendString:aString];
    return 0;
  } else {
    *error = [NSNumber errorInvalidCharacter];
    return -1;
  }
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

-(BOOL)isEmpty;
{
  return [_string length] == 0;
}

// MARK: Debugging
-(NSString*)description;
{
  return [[super description] stringByAppendingString:_string];
}

// MARK: Dealloc
- (void)dealloc
{
  [_string release];
  [super dealloc];
}

@end

// MARK: Init
@implementation SVRMathString (Creating)
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
+(id)mathStringWithString:(NSString*)aString;
{
  return [[[SVRMathString alloc] initWithString:aString] autorelease];
}
@end

@implementation SVRMathString (Copying)
-(id)copyWithZone:(NSZone*)zone;
{
  return [[SVRMathString alloc] initWithString:_string];
}
@end

@implementation SVRMathString (Archiving)
-(BOOL)writeToFilename:(NSString*)filename;
{
  NSData *data = [_string dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) { return NO; }
  return [data writeToFile:filename atomically:YES];
}
+(id)mathStringWithFilename:(NSString*)filename;
{
  NSString *string;
  NSData *data = [NSData dataWithContentsOfFile:filename];
  if (!data) { return nil; }
  string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  if (!string) { return nil; }
  return [SVRMathString mathStringWithString:string];
}
@end

@implementation SVRMathString (NSObjectProtocol)
-(BOOL)isEqual:(id)object;
{
  SVRMathString *rhs = nil;
  SVRMathString *lhs = self;
  if ([object isKindOfClass:[SVRMathString class]]) {
    rhs = object;
  }
  if (rhs) {
    return [lhs->_string isEqualToString:rhs->_string];
  } else {
    return NO;
  }
}
-(unsigned)hash;
{
  return [_string hash];
}
@end
