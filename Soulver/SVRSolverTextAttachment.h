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

// TODO: Refactor this to be more smart
// It needs purpose(previousSolution/Solution), NSDecimalNumber, Error as input
@class SVRSolverTextAttachmentCell;

@interface SVRSolverTextAttachment: NSTextAttachment
{
  mm_retain NSDecimalNumber *_solution;
  SVRSolverError _error;
}

-(NSDecimalNumber*)solution;
-(SVRSolverError)error;
-(NSString*)stringForDrawing;
-(id)initWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution error:(SVRSolverError)error;
-(NSString*)description;

@end


// TODO: Refactor this to be more dumb
// It needs beforeFont, afterFont, stringToDraw
@interface SVRSolverTextAttachmentCell: NSTextAttachmentCell
{
  mm_new NSString *_description;
}

// MARK: Properties
-(BOOL)shouldDrawError;
-(NSString*)description;

// MARK: Init
-(id)initWithAttachment:(SVRSolverTextAttachment*)attachment;
+(id)cellWithAttachment:(SVRSolverTextAttachment*)attachment;

// MARK: Custom Drawing
-(void)drawSolutionWithFrame:(NSRect)cellFrame
                   textFrame:(NSRect)textFrame
                      inView:(NSView*)controlView;
-(void)drawErrorWithFrame:(NSRect)cellFrame
                textFrame:(NSRect)textFrame
                   inView:(NSView*)controlView;
-(NSDictionary*)attributesForDrawingSolution;
-(NSDictionary*)attributesForDrawingError;

// MARK: Protocol (Used)
-(NSSize)cellSize;
-(NSPoint)cellBaselineOffset;
-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView*)controlView;
-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;

@end
