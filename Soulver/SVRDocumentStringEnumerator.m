//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRDocumentStringEnumerator.h"
#import "SVRCrossPlatform.h"

@implementation SVRDocumentStringEnumerator

// MARK: Initialization
-(id)initWithString:(NSString*)string;
{
  self = [super init];
  _string = [string copy];
  _numbers = nil;
  _operators = nil;
  _operators = nil;
  _expressions = nil;
  return self;
}

+(id)regexWithString:(NSString*)string;
{
  return [[[SVRDocumentStringEnumerator alloc] initWithString:string] autorelease];
}

// MARK: NSEnumerator
-(NSValue*)nextNumber;
{
  return nil;
}

-(NSValue*)nextOperator;
{
  return nil;
}

-(NSValue*)nextExpression;
{
  return nil;
}

// MARK: Convenience Properties
-(NSString*)string;
{
  return [[_string retain] autorelease];
}
-(NSString*)description;
{
  return [super description];
}

// MARK: Enumerator Access (mostly for testing)
-(NSEnumerator*)numberEnumerator;
{
  return nil;
}

-(NSEnumerator*)operatorEnumerator;
{
  return nil;
}

-(NSEnumerator*)expressionEnumerator;
{
  return nil;
}

// MARK: Dealloc
-(void)dealloc;
{
  [_string release];
  [_numbers release];
  [_operators release];
  [_expressions release];
  _string = nil;
  _numbers = nil;
  _operators = nil;
  _expressions = nil;
  [super dealloc];
}

@end

@implementation SVRDocumentStringEnumerator (Tests)
+(void)executeTests;
{
  [XPLog pause:@"SVRDocumentStringEnumerator Tests: NSUnimplemented"];
}
@end
