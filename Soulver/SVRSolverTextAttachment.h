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

#import <AppKit/AppKit.h>
#import "SVRSolver.h"
#import "XPCrossPlatform.h"

@protocol SVRSolverTextAttachmentProtocol <NSObject>

-(NSString*)toDrawString;
-(NSFont*)toDrawFont;
-(NSColor*)toDrawColor;
-(NSFont*)neighorFont;
-(SVRSolverTextAttachmentBorderStyle)borderStyle;
-(XPUserInterfaceStyle)userInterfaceStyle;

@end

@interface SVRSolverTextAttachment: NSTextAttachment <SVRSolverTextAttachmentProtocol>
{
  mm_retain NSString  *_toDrawString;
  mm_retain NSFont    *_toDrawFont;
  mm_retain NSColor   *_toDrawColor;
  mm_retain NSFont    *_neighorFont;
  SVRSolverTextAttachmentBorderStyle _borderStyle;
  XPUserInterfaceStyle _userInterfaceStyle;
}

-(NSString*)toDrawString;
-(NSFont*)toDrawFont;
-(NSColor*)toDrawColor;
-(NSFont*)neighorFont;
-(SVRSolverTextAttachmentBorderStyle)borderStyle;
-(XPUserInterfaceStyle)userInterfaceStyle;

-(id)initWithString:(NSString*)stringToDraw styles:(SVRSolverTextAttachmentStyles*)styles;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution styles:(SVRSolverTextAttachmentStyles*)styles;
+(id)attachmentWithPreviousSolution:(NSDecimalNumber*)previousSolution
                           operator:(SVRSolverOperator)operator
                             styles:(SVRSolverTextAttachmentStyles*)styles;
+(id)attachmentWithError:(SVRCalculationError)error
                  styles:(SVRSolverTextAttachmentStyles*)styles;

@end

@interface SVRSolverTextAttachmentCell: NSTextAttachmentCell
{
  mm_new NSDictionary *_toDrawAttributes;
}

// MARK: Properties
-(NSDictionary*)toDrawAttributes;
-(id<SVRSolverTextAttachmentProtocol>)SVR_attachment;

// MARK: Init
-(id)initWithAttachment:(NSTextAttachment<SVRSolverTextAttachmentProtocol>*)attachment;
+(id)cellWithAttachment:(NSTextAttachment<SVRSolverTextAttachmentProtocol>*)attachment;

// MARK: Custom Drawing
+(NSDictionary*)toDrawAttributesWithFont:(NSFont*)font
                                   color:(NSColor*)color;
-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;

// MARK: Protocol (Used)
-(NSSize)cellSize;
-(NSPoint)cellBaselineOffset;

// MARK: Protocol (Unused)
-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;

@end
