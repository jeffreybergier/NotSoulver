//
//  SVRDocumentViewController+Tests.m
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/09/01.
//

#import "SVRDocumentViewController+Tests.h"

@implementation SVRDocumentViewController (Tests)
+(void)load;
{
  [self executeTests];
}

+(void)executeTests;
{
  [self test_tagMap];
}

+(void)test_tagMap;
{
  int control;
  SVRDocumentViewController *vc;
  NSLog(@"%@: START: test_tagMap", self);
  vc = [[[SVRDocumentViewController alloc] init] autorelease];
  [vc awakeFromNib];
  NSAssert([[vc __mapKeyWithTag: 1 control:&control] isEqualToString:@"1"], @"");
  NSAssert([[vc __mapKeyWithTag: 2 control:&control] isEqualToString:@"2"], @"");
  NSAssert([[vc __mapKeyWithTag: 3 control:&control] isEqualToString:@"3"], @"");
  NSAssert([[vc __mapKeyWithTag: 4 control:&control] isEqualToString:@"4"], @"");
  NSAssert([[vc __mapKeyWithTag: 5 control:&control] isEqualToString:@"5"], @"");
  NSAssert([[vc __mapKeyWithTag: 6 control:&control] isEqualToString:@"6"], @"");
  NSAssert([[vc __mapKeyWithTag: 7 control:&control] isEqualToString:@"7"], @"");
  NSAssert([[vc __mapKeyWithTag: 8 control:&control] isEqualToString:@"8"], @"");
  NSAssert([[vc __mapKeyWithTag: 9 control:&control] isEqualToString:@"9"], @"");
  NSAssert([[vc __mapKeyWithTag:10 control:&control] isEqualToString:@"0"], @"");
  NSAssert([[vc __mapKeyWithTag:11 control:&control] isEqualToString:@"-"], @"");
  NSAssert([[vc __mapKeyWithTag:12 control:&control] isEqualToString:@"."], @"");
  NSAssert( [vc __mapKeyWithTag:13 control:&control] == nil, @"");
  NSAssert(control == -1, @"");
  NSAssert([[vc __mapKeyWithTag:14 control:&control] isEqualToString:@"="], @"");
  NSAssert([[vc __mapKeyWithTag:15 control:&control] isEqualToString:@"a"], @"");
  NSAssert([[vc __mapKeyWithTag:16 control:&control] isEqualToString:@"s"], @"");
  NSAssert([[vc __mapKeyWithTag:17 control:&control] isEqualToString:@")"], @"");
  NSAssert([[vc __mapKeyWithTag:18 control:&control] isEqualToString:@"m"], @"");
  NSAssert([[vc __mapKeyWithTag:19 control:&control] isEqualToString:@"d"], @"");
  NSAssert([[vc __mapKeyWithTag:20 control:&control] isEqualToString:@"("], @"");
  NSAssert([[vc __mapKeyWithTag:21 control:&control] isEqualToString:@"e"], @"");
  NSAssert( [vc __mapKeyWithTag:22 control:&control] == nil, @"");
  NSAssert(control == -2, @"");
  NSAssert( [vc __mapKeyWithTag:23 control:&control] == nil, @"");
  NSAssert(control == -3, @"");
  NSLog(@"%@: PASS: test_tagMap", self);
}
@end
