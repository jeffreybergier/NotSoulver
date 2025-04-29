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
#import "NSUserDefaults+Soulver.h"
#import "XPCrossPlatform.h"

@interface SVRSettingsViewController: NSResponder
{
  mm_unretain IBOutlet NSWindow *_window;
  mm_retain   IBOutlet NSView   *_groupGeneralView;
  mm_retain   IBOutlet NSView   *_groupColorView;
  mm_retain   IBOutlet NSView   *_groupFontView;
  mm_unretain IBOutlet NSColorWell *_wellDarkBackground;
  mm_unretain IBOutlet NSColorWell *_wellDarkError;
  mm_unretain IBOutlet NSColorWell *_wellDarkInsertionPoint;
  mm_unretain IBOutlet NSColorWell *_wellDarkOperand;
  mm_unretain IBOutlet NSColorWell *_wellDarkOperator;
  mm_unretain IBOutlet NSColorWell *_wellDarkOther;
  mm_unretain IBOutlet NSColorWell *_wellDarkPrevious;
  mm_unretain IBOutlet NSColorWell *_wellDarkSolution;
  mm_unretain IBOutlet NSColorWell *_wellLightBackground;
  mm_unretain IBOutlet NSColorWell *_wellLightError;
  mm_unretain IBOutlet NSColorWell *_wellLightInsertionPoint;
  mm_unretain IBOutlet NSColorWell *_wellLightOperand;
  mm_unretain IBOutlet NSColorWell *_wellLightOperator;
  mm_unretain IBOutlet NSColorWell *_wellLightOther;
  mm_unretain IBOutlet NSColorWell *_wellLightPrevious;
  mm_unretain IBOutlet NSColorWell *_wellLightSolution;
  mm_unretain IBOutlet NSTextField *_fieldTime;
  mm_unretain IBOutlet NSTextField *_fieldTextMath;
  mm_unretain IBOutlet NSTextField *_fieldTextOther;
  mm_unretain IBOutlet NSTextField *_fieldTextError;
  mm_unretain IBOutlet NSPopUpButton *_popUpTheme;
}

-(void)awakeFromNib;
-(void)configureWellTags;
-(void)populateUI;
-(NSString*)__descriptionForFont:(NSFont*)font;

-(IBAction)choiceChanged:(NSPopUpButton*)sender;
-(IBAction)themeChanged:(NSPopUpButton*)sender;
-(IBAction)colorChanged:(NSColorWell*)sender;
-(IBAction)timeChanged:(NSTextField*)sender;
-(IBAction)fontChangeRequest:(NSButton*)sender;
// FirstResponder message from NSFontManager
-(IBAction)changeFont:(NSFontManager*)sender;

-(IBAction)fontReset:(NSButton*)sender;
-(IBAction)colorReset:(NSButton*)sender;
-(IBAction)timeReset:(NSButton*)sender;

-(BOOL)decodeThemeColor:(SVRThemeColor*)colorPointer
         interfaceStyle:(XPUserInterfaceStyle*)stylePointer
          fromColorWell:(NSColorWell*)sender;

-(BOOL)decodeThemeColor:(SVRThemeColor*)colorPointer
        fromResetButton:(NSButton*)sender;

-(BOOL)decodeThemeFont:(SVRThemeFont*)fontPointer
            fromButton:(NSButton*)sender;


@end
