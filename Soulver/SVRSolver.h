//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "XPCrossPlatform.h"

// MARK: SVRSolver

@interface SVRSolver: NSObject

// MARK: Business Logic
+(void)solveAttributedString:(NSMutableAttributedString*)input;

// MARK: Private
+(void)__step1_decodeExpressionTerminator:(NSMutableAttributedString*)input;
+(void)__step2_removeAllTags:(NSMutableAttributedString*)input;
+(void)__step3_scanAndTag:(NSMutableAttributedString*)input;
+(void)__step4_solveAndTag:(NSMutableAttributedString*)input;
+(void)__step5_styleAndTag:(NSMutableAttributedString*)input;


@end

@interface SVRSolver (Testing)
+(void)executeTests;
@end

// MARK: Enumerations

typedef enum {
  // Stores NSDecimalNumber
  SVRSolverTagNumber,
  // Stores NSString of the range of the bracket
  // NSStringFromRange (use NSRangeFromString to extract)
  SVRSolverTagBracket,
  // Stores NSNumber containing the SVRSoulverOperator
  SVRSolverTagOperator,
  // Stores NSString of the range of the bracket - (Minus the Equal Sign)
  // NSStringFromRange (use NSRangeFromString to extract)
  SVRSolverTagExpression,
  // Stores NSDecimalNumber with the solution for the expression in the = sign
  // Stores NSNumber if its an error
  SVRSolverTagSolution,
  // Stores NSDecimalNumber with the solution of the previous expression
  SVRSolverTagPreviousSolution,
} SVRSolverTag;

typedef enum {
  SVRSolverOperatorExponent,
  SVRSolverOperatorDivide,
  SVRSolverOperatorMultiply,
  SVRSolverOperatorSubtract,
  SVRSolverOperatorAdd,
  SVRSolverOperatorUnknown
} SVRSolverOperator;

typedef enum {
  SVRSolverErrorNone = -1,
  SVRSolverErrorInvalidCharacter = -1001,
  SVRSolverErrorMismatchedBrackets = -1002,
  SVRSolverErrorMissingOperand = -1003,
  SVRSolverErrorDivideByZero = -1004,
} SVRSolverError;

typedef SVRSolverError* SVRSolverErrorPointer;

// MARK: Enumeration Helper Functions

XPAttributedStringKey XPAttributedStringKeyForTag(SVRSolverTag tag);
SVRSolverTag          SVRSolverTagForKey(XPAttributedStringKey string);
NSNumber             *NSNumberForOperator(SVRSolverOperator operator);
SVRSolverOperator     SVRSolverOperatorForNumber(NSNumber *number);
SVRSolverOperator     SVRSolverOperatorForRawString(NSString *string);
NSString             *RawStringForOperator(SVRSolverOperator operator);
NSString             *SVRSolverDescriptionForError(SVRSolverError error);
NSString             *SVRSolverDebugDescriptionForError(SVRSolverError error);
