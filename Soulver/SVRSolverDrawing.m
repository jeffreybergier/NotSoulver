//
// MIT License
//
// Copyright (c) 2025 Jeffrey Bergier
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

#import "SVRSolverDrawing.h"

@implementation SVRSolverDrawing

/* Consider Using NSGradient on 10.5+
 NSGradient *gradient = nil;
 NSArray *colors = nil;
 NSColor *colorLight = nil;
 NSColor *colorDark = nil;
 
 colorLight = [color blendedColorWithFraction:0.3 ofColor:[NSColor whiteColor]];
 colorDark  = [color blendedColorWithFraction:0.3 ofColor:[NSColor blackColor]];
 gradient = [[[NSGradient alloc] initWithColors:colors] autorelease];
 [gradient drawInBezierPath:path angle:90];
 colors = [NSArray arrayWithObjects:colorDark, color, colorLight, nil];
*/

+(void)drawBackgroundInRect:(NSRect)_rect
                       type:(int)type
                      color:(NSColor*)color;
{
  // Prepare Object Variables
  id path = nil;
  NSColor *colorDark = nil;
  
  // Prepare Drawing Settings
  XPFloat stroke = 2.0;
  NSRect rect = NSInsetRect(_rect, stroke, stroke);
  XPFloat radius = NSHeight(rect) / 2.0;
  colorDark  = [color blendedColorWithFraction:0.3 ofColor:[NSColor blackColor]];
  
  NSCParameterAssert(color);
  
  // Define the path
  path = [XPBezierPath XP_bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
  if (path) {
    // Draw
    [color setFill];
    [colorDark setStroke];
    [path fill];
    [path setLineWidth:stroke];
    [path stroke];
  } else {
    NSDrawWhiteBezel(_rect, _rect);
  }
}

@end
