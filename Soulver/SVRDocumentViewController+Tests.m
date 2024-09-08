//
//  SVRDocumentViewController+Tests.m
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/09/01.
//

#if TESTING

#import "SVRDocumentViewController+Tests.h"

@implementation SVRDocumentViewController (Tests)

+(void)executeTests;
{
  [self test_tagMap];
  [self test_modelUpdate];
}

+(void)test_tagMap;
{
  int control;
  SVRDocumentViewController *vc;
  [XPLog alwys:@"%@: START: test_tagMap", self];
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
  [XPLog alwys:@"%@: PASS: test_tagMap", self];
}

+(void)test_modelUpdate;
{
  SVRDocumentViewController *vc;
  SVRDocumentModelController *model;
  [XPLog alwys:@"%@: START: test_modelUpdate", self];
  vc = [[[SVRDocumentViewController alloc] init] autorelease];
  model = [[[SVRDocumentModelController alloc] init] autorelease];
  [model awakeFromNib];
  vc->_model = model;
  [vc awakeFromNib];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@""], @"");
  [vc __append:1];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1"], @"");
  [vc __append:2];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"12"], @"");
  [vc __append:3];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"123"], @"");
  [vc __append:4];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234"], @"");
  [vc __append:5];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"12345"], @"");
  [vc __append:6];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"123456"], @"");
  [vc __append:7];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567"], @"");
  [vc __append:8];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"12345678"], @"");
  [vc __append:9];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"123456789"], @"");
  [vc __append:10];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890"], @"");
  [vc __append:11];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-"], @"");
  [vc __append:12];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-."], @"");
  [vc __append:13];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-"], @"");
  [vc __append:14];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-="], @"");
  [vc __append:15];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=a"], @"");
  [vc __append:16];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=as"], @"");
  [vc __append:17];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=as)"], @"");
  [vc __append:18];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=as)m"], @"");
  [vc __append:19];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=as)md"], @"");
  [vc __append:20];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=as)md("], @"");
  [vc __append:21];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-=as)md(e"], @"");
  [vc __append:22];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@"1234567890-="], @"");
  [vc __append:23];
  NSAssert([[[[vc model] mathString] stringValue] isEqualToString:@""], @"");
  [XPLog alwys:@"%@: PASS: test_modelUpdate", self];
}
@end

#endif
