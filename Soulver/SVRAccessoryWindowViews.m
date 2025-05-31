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

#import "SVRAccessoryWindowViews.h"

@implementation SVRAccessoryWindowKeypadView: NSView

-(id)init;
{
  SVRAccessoryWindowKeypadViewKind kind = SVRAccessoryWindowKeypadViewKind1;
  
  self = [super init];
  XPParameterRaise(self);
  
  for (kind=SVRAccessoryWindowKeypadViewKind1; kind<=SVRAccessoryWindowKeypadViewKindLog; kind++)
  {
    [self addSubview:[[self class] newButtonOfKind:kind]];
  }
  
  return self;
}

+(NSButton*)newButtonOfKind:(SVRAccessoryWindowKeypadViewKind)kind;
{
  SEL buttonAction = @selector(keypadAppend:);
  NSRect buttonRect = [self rectForButtonOfKind:kind];
  NSButton *button = nil;
  button = [[[NSButton alloc] initWithFrame:buttonRect] autorelease];
  [button setTitle:[NSString stringWithFormat:@"%d", (int)kind]];
  [button setTag:kind];
  [button setBezelStyle:NSBezelStyleRegularSquare];
  [button setAction:buttonAction];
  return button;
}

+(NSRect)rectForButtonOfKind:(SVRAccessoryWindowKeypadViewKind)kind;
{
  static const XPFloat paddingWindow = 4;
  static const XPFloat paddingButton = 4;
  static const XPFloat paddingExtra  = 6;
  static const NSSize  buttonSize    = {40, 32};
  static const NSSize  equalSize     = {84, 32};
  XPInteger column     = -1;
  XPInteger row        = -1;
  XPFloat   rowPadding = 0;
  NSRect    output     = NSZeroRect;
  
  switch (kind) {
    case SVRAccessoryWindowKeypadViewKind1:
    case SVRAccessoryWindowKeypadViewKindNegative:
    case SVRAccessoryWindowKeypadViewKind4:
    case SVRAccessoryWindowKeypadViewKind7:
    case SVRAccessoryWindowKeypadViewKindAdd:
    case SVRAccessoryWindowKeypadViewKindMultiply:
    case SVRAccessoryWindowKeypadViewKindPower:
    case SVRAccessoryWindowKeypadViewKindDelete:
      column = 0;
      break;
    case SVRAccessoryWindowKeypadViewKindEqual:
    case SVRAccessoryWindowKeypadViewKind0:
    case SVRAccessoryWindowKeypadViewKind2:
    case SVRAccessoryWindowKeypadViewKind5:
    case SVRAccessoryWindowKeypadViewKind8:
    case SVRAccessoryWindowKeypadViewKindSubtract:
    case SVRAccessoryWindowKeypadViewKindDivide:
    case SVRAccessoryWindowKeypadViewKindRoot:
      column = 1;
      break;
    case SVRAccessoryWindowKeypadViewKindDecimal:
    case SVRAccessoryWindowKeypadViewKind3:
    case SVRAccessoryWindowKeypadViewKind6:
    case SVRAccessoryWindowKeypadViewKind9:
    case SVRAccessoryWindowKeypadViewKindBRight:
    case SVRAccessoryWindowKeypadViewKindBLeft:
    case SVRAccessoryWindowKeypadViewKindLog:
      column = 2;
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRAccessoryWindowKeypadViewKind(%d)", (int)kind);
      break;
  }
  
  switch (kind) {
    case SVRAccessoryWindowKeypadViewKindDelete:
    case SVRAccessoryWindowKeypadViewKindEqual:
      row = 0;
      break;
    case SVRAccessoryWindowKeypadViewKindNegative:
    case SVRAccessoryWindowKeypadViewKind0:
    case SVRAccessoryWindowKeypadViewKindDecimal:
      row = 1;
      break;
    case SVRAccessoryWindowKeypadViewKind1:
    case SVRAccessoryWindowKeypadViewKind2:
    case SVRAccessoryWindowKeypadViewKind3:
      row = 2;
      break;
    case SVRAccessoryWindowKeypadViewKind4:
    case SVRAccessoryWindowKeypadViewKind5:
    case SVRAccessoryWindowKeypadViewKind6:
      row = 3;
      break;
    case SVRAccessoryWindowKeypadViewKind7:
    case SVRAccessoryWindowKeypadViewKind8:
    case SVRAccessoryWindowKeypadViewKind9:
      row = 4;
      break;
    case SVRAccessoryWindowKeypadViewKindAdd:
    case SVRAccessoryWindowKeypadViewKindSubtract:
    case SVRAccessoryWindowKeypadViewKindBRight:
      row = 5;
      break;
    case SVRAccessoryWindowKeypadViewKindMultiply:
    case SVRAccessoryWindowKeypadViewKindDivide:
    case SVRAccessoryWindowKeypadViewKindBLeft:
      row = 6;
      break;
    case SVRAccessoryWindowKeypadViewKindPower:
    case SVRAccessoryWindowKeypadViewKindRoot:
    case SVRAccessoryWindowKeypadViewKindLog:
      row = 7;
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRAccessoryWindowKeypadViewKind(%d)", (int)kind);
      break;
  }
  
  
  if (row > 0) {
    rowPadding += paddingExtra;
  }
  if (row > 4) {
    rowPadding += paddingExtra;
  }
  
  output.origin = NSMakePoint(((paddingButton + buttonSize.width ) * column) + paddingWindow,
                              ((paddingButton + buttonSize.height) * row   ) + paddingWindow + rowPadding);
  output.size = kind == SVRAccessoryWindowKeypadViewKindEqual
                      ? equalSize
                      : buttonSize;
  return output;
}

@end
