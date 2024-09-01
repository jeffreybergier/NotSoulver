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
  [SVRDocumentViewController executeTests];
}

+(void)executeTests;
{
  NSLog(@"%@", self);
}
@end
