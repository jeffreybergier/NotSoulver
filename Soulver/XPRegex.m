//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "XPRegex.h"

@implementation XPRegex

// MARK: Dealloc
-(void)dealloc;
{
  [_regex release];
  [_string release];
  _regex = nil;
  _string = nil;
  [super dealloc];
}

@end

@implementation XPRegex (Tests)

@end
