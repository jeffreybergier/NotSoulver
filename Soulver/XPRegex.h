//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>
#import "SVRLegacyRegex.h"

@interface XPRegex: NSObject
{
  SVRLegacyRegex *_regex;
  NSString *_string;
}

// MARK: Initialization
-(id)initWithString:(NSString*)string;
+(id)regexWithString:(NSString*)string;

// MARK: NSEnumerator
-(NSArray*)allObjects;
-(NSValue*)nextNumber;
-(NSValue*)nextOperator;

// MARK: Convenience Properties
-(NSString*)string;
-(NSString*)description;

@end

@interface XPRegex (Tests)
+(void)executeTests;
@end
