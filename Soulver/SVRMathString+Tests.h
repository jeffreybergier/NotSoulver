//
//  SVRMathString+Tests.h
//  SoulverCommand
//
//  Created by Jeffrey Bergier on 2024/08/18.
//

#import "SVRMathString.h"

@interface SVRMathString (Tests)
+(void)load;
+(void)executeTests;
-(void)__testAssertEqual:(NSString*)rhs;
-(void)__testAssertEqual:(NSString*)rhs expectError:(NSNumber*)expectedError;
@end

// MARK: Debug Logging
@interface NSString (SVRLog)
/// Replaces newlines from logged strings with \n
-(void)SVR_debugLOG;
@end
