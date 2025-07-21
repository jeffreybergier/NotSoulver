//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import <AppKit/AppKit.h>
#import "MATHSolver.h"
#import "XPCrossPlatform.h"

@interface MATHSolverTextAttachment: NSTextAttachment
{
  mm_retain NSString *_string;
  mm_retain NSDictionary *_configuration;
}

+(NSSize)textPadding;

-(NSString*)string;
-(NSFont*)font;
-(NSColor*)foregroundColor;
-(NSColor*)backgroundColor;
-(NSColor*)mixColor;
-(MATHSolverTextAttachmentBackground)background;

-(id)initWithString:(NSString*)stringToDraw styles:(MATHSolverTextAttachmentStyles)styles;
+(id)attachmentWithSolution:(NSDecimalNumber*)solution styles:(MATHSolverTextAttachmentStyles)styles;
+(id)attachmentWithPreviousSolution:(NSDecimalNumber*)previousSolution
                           operator:(MATHSolverOperator)operator
                             styles:(MATHSolverTextAttachmentStyles)styles;
+(id)attachmentWithError:(MATHCalculationError)error
                  styles:(MATHSolverTextAttachmentStyles)styles;

@end

@interface MATHSolverTextAttachmentCell: NSTextAttachmentCell
{
  NSSize _cellSize;
}

// MARK: Properties
-(MATHSolverTextAttachment*)MATH_attachment;

// MARK: Init
-(id)initWithAttachment:(MATHSolverTextAttachment*)attachment;
+(id)cellWithAttachment:(MATHSolverTextAttachment*)attachment;

// MARK: Custom Drawing
+(NSDictionary*)attributesWithFont:(NSFont*)font
                             color:(NSColor*)color;
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
-(void)__drawBackgroundCapsuleFillInRect:(NSRect)_rect;
-(void)__drawBackgroundCapsuleStrokeInRect:(NSRect)_rect;

// MARK: Protocol (Used)
-(NSSize)cellSize;
-(NSSize)__calculateCellSize;
-(NSPoint)cellBaselineOffset;

// MARK: Protocol (Unused)
-(void)highlight:(BOOL)flag
       withFrame:(NSRect)cellFrame
          inView:(NSView*)controlView;

@end

@interface MATHSolverTextAttachment (NSCoding) <XPSecureCoding>
+(BOOL)supportsSecureCoding;
-(BOOL)isEqual:(MATHSolverTextAttachment*)rhs;
-(id)initWithCoder:(NSCoder *)coder;
-(void)encodeWithCoder:(NSCoder*)coder;
@end

@interface MATHSolverTextAttachmentCell (NSCoding) <XPSecureCoding>
+(BOOL)supportsSecureCoding;
-(BOOL)isEqual:(MATHSolverTextAttachmentCell*)rhs;
-(id)initWithCoder:(NSCoder *)coder;
-(void)encodeWithCoder:(NSCoder*)coder;
@end
