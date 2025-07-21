# MathEdit for OpenStep
## Screenshots
![Screenshot of the app running in OpenStep](README/screenshot44.png)
[Mac OS X 10.2 Jaguar](README/screenshot46.png)・
[Mac OS X 10.4 Tiger](README/screenshot47.png)・
[Mac OS X 10.6 Snow Leopard](README/screenshot48.png)・
[OS X 10.8 Mountain Lion](README/screenshot49.png)・
[OS X 10.10 Yosemite](README/screenshot27.png)・
[macOS 10.12 Sierra](README/screenshot28.png)・
[macOS 10.15 Catalina](README/screenshot50.png)・
[macOS 15 Sequoia](README/screenshot51.png)

## What is MathEdit
A calculator application I wrote as a learning exercise. Its a traditional Mac
document-based application that sort of looks like TextEdit, but when you write
math equations into it and type `=` then it solves them for you in-line. It sort
of resembles the "Math Notes" feature Apple added to Notes in macOS 15 Sequoia
but MathEdit has one trick up its sleeve… it runs on every version of Mac OS X,
including Mac OS X's predecessor OpenStep.

## Why MathEdit
I wrote MathEdit as a learning exercise. It was supposed to be an experiment in
learning how to develop for OpenStep, i.e. without Swift, without ARC, without
Blocks, without Properties, etc. But I ended up learning a whole lot more. I can
honestly say that learning how to develop for OpenStep will bring you much
closer to how Cocoa and Cocoa Touch actually work. The OpenStep documentation is
wonderful and you get the sense that every object in Foundation and AppKit was
delightfully crafted with its own personality and quirks. It has been a joy to
bring a single codebase through 30 years of Apple Operating System history.

## For Users
### Features
   - ✅ In-line math expression solving
   - ✅ PEMDAS order of operations
   - ✅ Basic operators `+ - / * ^`
   - ✅ Roots e.g. `4R256=` (cube root of 256)
   - ✅ Logarithms e.g. `10L1000=` (log base 10 of 1000)
   - ✅ Carries over previous solution
   - ✅ Syntax highlighting
   - ✅ Theme-able with customer fonts and colors
   - ✅ Dark Mode
   - ✅ Physical keyboard and Virtual Keypad
   - ✅ Autosave and Autoresume so data is never lost

### How to Download
The app is a normal Mac app saved in ZIP format. The [builds](Builds/) folder
contains builds for each version of Mac OS X sorted by date the build was made.
Use the newest date in the newest operating system possible.

- [Z15 - Sequoia](Builds/Z15%20-%20Sequoia/): **Notarized Universal Apple Silicon and Intel builds** that run on macOS 10.14 and up
   - **This is the recommended build to run on any modern Mac**
- [X15 - Catalina](Builds/X15%20-%20Catalina/): Universal Apple Silicon and Intel 64 bit builds that run on macOS 10.14 and up
- [X8 - Mountain Lion](Builds/X8%20-%20Mountain%20Lion/): Intel 64 bit builds that run on Mac OS X 10.7 and up
- [X6 - Snow Leopard](Builds/X6%20-%20Snow%20Leopard/): Intel 64 and 32 bit builds that run on Mac OS X 10.6 and up
- [X4 - Tiger](Builds/X4%20-%20Tiger/): Universal Intel 32 bit and PowerPC 32 bit builds that run on Mac OS X 10.4 and 10.5
- [X2 - Jaguar](Builds/X2%20-%20Jaguar/): PowerPC 32 bit builds that run on Mac OS X 10.2 and 10.3
- X0 - Cheetah: I admit that I never built a version for Mac OS X 10.0, but the Jaguar version *should* run
- [42 - OpenStep](Builds/42%20-%20OpenStep/) Universal Intel 32 bit and Motorola 68K 32 bit builds that run on OpenStep 4.2

## For Developers
### Watch My Try! Swift Tokyo 2025 Talk
[![Youtube: I Built an App for NeXTSTEP or:](https://img.youtube.com/vi/dwpsVqsQG5s/0.jpg)](https://www.youtube.com/watch?v=dwpsVqsQG5s)
### Features
Because MathEdit for OpenStep uses Cocoa and Objective-C API's from 1996 it
doesn't use any modern features at all:
   - ❌ No Swift
   - ❌ No Autolayout
   - ❌ No Automatic Reference Counting
   - ❌ No Property Syntax
   - ❌ No Blocks Syntax ([thank goodness](https://fuckingblocksyntax.com))
   - ❌ No Dot Syntax
   - ❌ No Fast Enumeration
   - ❌ No Collection Literals
   - ❌ No Dispatch Queues

### Guide to the Builds
The app is a normal Mac app saved in ZIP format. The [builds](Builds/) folder
contains builds for each version of Mac OS X sorted by date the build was made.
Use the newest date in the newest operating system possible.

| Folder                                                | Build OS        | Build IDE             | Build SDK      | Minimum OS   | Maximum OS  | Architecture   |
|-------------------------------------------------------|-----------------|-----------------------|----------------|--------------|------------ |----------------|
| [Z15 - Sequoia](Builds/15%20-%20Sequoia/)             | macOS 15.5      | Xcode 16.4            | MacOSX15.5.sdk | macOS 11     |macOS 15     |`x86_64` `arm64`|
| [X15 - Catalina](Builds/X15%20-%20Catalina/)          | macOS 10.15.7   | Xcode 12.4            | MacOSX11.1.sdk | macOS 10.14  |macOS 15     |`x86_64` `arm64`|
| [X8 - Mountain Lion](Builds/X8%20-%20Mountain%20Lion/)| OS X 10.8.5     | Xcode 5.1.1           | MacOSX10.9.sdk | Mac OS X 10.7|macOS 15     |`x86_64`        |
| [X6 - Snow Leopard](Builds/X6%20-%20Snow%20Leopard/)  | Mac OS X 10.6.8 | Xcode 4.2             | MacOSX10.6.sdk | Mac OS X 10.6|macOS 15     |`x86_64` `i386` |
| [X4 - Tiger](Builds/X4%20-%20Tiger/)                  | Mac OS X 10.4.11| Xcode 2.5             | MacOSX10.4u.sdk| Mac OS X 10.4|macOS 10.14  |`ppc` `i386`    |
| [X2 - Jaguar](Builds/X2%20-%20Jaguar/)                | Mac OS X 10.2.8 | Project Builder 2.1   | n/a            | Mac OS X 10.0|Mac OS X 10.6|`ppc`           |
| [42 - OpenStep](Builds/42%20-%20OpenStep/)            | OpenStep 4.2    | Project Builder v300.2| n/a            | OpenStep 4.2 |OpenStep 4.2 |`m68k` `i386`   |

### How to Build from Source
In OpenStep, the Project Builder file is always called
[`PB.project`](MathEdit/PB.project) and, as far as I can tell, it cannot be
renamed. Because of this every other Project Builder and Xcode project file is
called `PBXN` where the `N` is replaced with the version of Mac OS X it was
created from. In general, you should open the PB file that is less than or equal
to the OS you are running. In general, this means you will open
[PBX15.xcodeproj](MathEdit/PBX15.xcodeproj) unless you are running a really old
version of OS X. From there it works exactly like any other Xcode project, just
build and run.

Why not open [PBZ15.xcodeproj](MathEdit/PBZ15.xcodeproj)? This Xcode project was
created in macOS 15 Sequoia which means it should be the recommended option
given the instructions above. However, this Xcode project has signing enabled
for notarization and this may make it hard to build on computers that do not
have a signed in developer account and a macOS provisioning profile. So you can
use this one, but expect for there to be errors on first build.

### Important Classes
- [`MATHDocument`](MathEdit/MATHDocument.h): Very minimal `NSDocument` subclass. It has almost no logic. 
- [`MATHDocumentModelController`](MathEdit/MATHDocumentModelController.h): Detects when the model changes and then uses `MATHSolver` to resolve and regenerate the string attributes.
- [`NSTextStorage`](https://developer.apple.com/documentation/appkit/nstextstorage?language=objc): This is the model class, its directly modified by `NSTextView` (Note that `NSTextStorage` is just a special subclass of `NSMutableAttributedString` that is built into AppKit).
- [`MATHSolver`](MathEdit/MATHSolver.h): This is a set of classes that take the model and solve the math expressions. These classes are all functional in that they rely on no external state. They only modify the model passed to them.
   - [`MATHSolverScanner`](MathEdit/MATHSolverScanner.h): A class that uses `XPRegularExpression` to scan the string for Operators, Numbers, Brackets, and Expressions. It stores them as `NSSet<NSValue<NSRange>>`.
   - [`MATHSolverExpressionTagger`](MathEdit/MATHSolverExpressionTagger.h): This is a set of class methods that take the ranges found by `MATHSolverScanner` and applies special attributes in the attributed string so they can be read later. These attributes include the value of numbers stored as `NSNumber`.
   - [`MATHSolverSolutionTagger`](MathEdit/MATHSolverSolutionTagger.h): This is a class method that reads the tags stored by `MATHSolverExpressionTagger`, solves the expressions and replaces the `=` with a special text attachment `MATHSolverTextAttachment`.
   - [`MATHSolverStyler`](MathEdit/MATHSolverStyler.h): This is a class method that reads the tags stored by `MATHSolverExpressionTagger` and applies the Cocoa attributes to apply Fonts and Colors
   - [`MATHSolverTextAttachment`](MathEdit/MATHSolverTextAttachment.h): This is a special subclass of [`NSTextAttachment`](https://developer.apple.com/documentation/appkit/nstextattachment?language=objc) that takes an [`NSDecimalNumber`](https://developer.apple.com/documentation/foundation/nsdecimalnumber?language=objc) or an error and renders in the string.
- [`XPDocument`](MathEdit/XPDocument.h): OpenStep unfortunately does not have `NSDocument` so `XPDocument` is a minimal implementation of the `NSDocument` API for use in OpenStep. Of course, this implementation works in Mac OS X as well, but `NSDocument` improves so much in every version of OS X, that from the very first build in Mac OS X 10.2 Jaguar, I switch the superclass of `MATHDocument` to the Apple implementation of `NSDocument`.
- [`XPRegularExpression`](MathEdit/XPRegularExpression.h): `NSRegularExpression` was added to the platform very late (Mac OS X 10.7 Lion) so I wrote this minimal implementation of the `NSRegularExpression` API. I have not yet switched to the Apple implementation in supported systems, but I want to try eventually.
   - [`slre.c`](MathEdit/slre.h): Super Light Regular Expression is a single-file C library I found that compiles in OpenStep and every version of OS X. `XPRegularExpression` wraps this to provide the actual regex capability.

### CrossPlatform Approach
The real honest truth is that, the source compatibility in Objective C and
AppKit is so good that the pure OpenStep version of this app works perfectly in
OS X as is. Yes, there are ton of deprecated API warnings as well as implicit
integer type conversions. But it all works… **WHICH IS AMAZING!** But this was
not enough, I also had a few goals:

- Support the newest features
- Use the newest API
- No warnings on any platform (and no silencing)
- No symbol collisions

Its important to note that this approach was easy with perfect foresight. In
real life, I think supporting old OS versions is very difficult and that is
largely because you don't know what is coming. But in MathEdit I knew exactly
what was coming. Because of that I could literally design perfect API that will
fit in the system in the future like XPInteger, XPDocument, XPRegularExpression,
etc.

#### The Problem with -[NSObject respondsToSelector:]
This API and this capability in Objective-C is amazing and allows for really
dynamic programming. However, I was not looking for dynamic programming. I am
not dynamically adding and removing methods from my classes. Rather, I am just
moving forward in time. In this case I found `respondsToSelector` and its
counterpart `performSelector:` to be limiting. Yes, it was easy to check if a
class responds to the newer API. But when trying to use the API, I ran into
issues where warnings were raised due to the older systems not knowing about
that newer selector. You can remove those by using `performSelector:` but that
only works if all types involved in the method call are Object types, and that
is frequently not the case. And to be honest, I didn't really feel like digging
out `NSInvocation` to try and solve that problem. So that led to my more modern
and dare I even say "Swifty" solution… handle everything at compile time with
macros.

### [XPCrossPlatform](MathEdit/XPCrossPlatform.h): My Cross Platform Helper
This file handles most of the CrossPlatform work. Everything in the
CrossPlatform file has a prefix of `XP` to prevent symbol collisions. It mostly
uses `#define` to solve problems and It has several types of problems it solves:

- AFF or Anti-Feature Flags: `#define` macros for when OS X is missing features. These later get `#undef` based on the build SDK (not runtime). 
   - Anti-Feature Flags are designed in such a way that you can comment out the `#undef` directives and the app works with old API's, including original OpenStep compatible API's. There are deprecation warnings when using such old API's but Apple has not removed any of these API's from the system in 30 years, which is pretty incredible🤯
   - `AFF_NSScrollViewMagnificationNone`
   - `AFF_NSDocumentNone`
   - `AFF_FormalProtocolsNone`
   - `AFF_NSViewControllerNone`
- Symbol changes: `typedef` and `#define` declarations when new types were introduced or changed
   - `int`→`NSInteger`＝`XPInteger`
   - `NSOKButton`→`NSModalResponseOK`=`XPModalResponseOK`
   - `NSCenterTextAlignment`→`NSTextAlignmentCenter`=`XPTextAlignmentCenter`
- API Improvements: Usually introducing a new API that does the same thing but with some improvement such as error handling
   - `-[NSData dataWithContentsOfFile:]`→`-[NSData dataWithContentsOfURL:options:error:]`=`-[NSData XP_dataWithContentsOfURL:options:error:]`
   - This new category method uses #ifdef to check the Anti-Feature Flags (mentioned above) to do the right thing based on build SDK.
- Whole new API: These are the hardest and the most fragile. Dealing with these has different approaches, none of which are very good.
   - `NSURL` did not exist in OpenStep, so it is `#define XPURL NSString` in OpenStep
   - `NSError` was not introduced until 10.3 Panther, so it is `#define XPError NSNumber` in Jaguar and before
   - For more complex types I wrote a complete implementation like [`XPDocument`](MathEdit/XPDocument.h) and [`XPRegularExpression`](MathEdit/XPRegularExpression.h)

That said, one of the major problems with using `#define` and `#ifdef` is that
that code is totally ignored by the compiler on the unsupported system. So I try
not to put very much code in these kinds of blocks. For example,
[`XPDocument`](MathEdit/XPDocument.h) for OpenStep fully compiles in every
version of OS X even though it is not used.

#### Lets Talk About Apple Documentation
When doing this cross-platform work its so important to know which version of OS
X an API was introduced. And the Apple documentation, helpfully tells you this…
but for some reason, its often wrong. Its no just wrong for certain methods or
APIs, but its wrong for entire classes! I found ChatGPT to be more reliable than
Apple's docs for this. But really the only way to know is to try on each OS. Its
quite annoying.

I'll give you some examples:
- [`NSError`](https://developer.apple.com/documentation/foundation/nserror?language=objc) was introduced in 10.3, but Apple docs show 10.0 (on their website) and 10.2 (in Xcode)
- [`NSModalResponseOK`](https://developer.apple.com/documentation/appkit/nsapplication/modalresponse/ok?language=objc) was introduced in in 10.9, but the docs just say macOS with no version.
- [`NSWindowStyleMaskTitled`](https://developer.apple.com/documentation/appkit/nswindow/stylemask-swift.struct/titled?language=objc)) was a particularly annoying example because the API Docs and Header files have no version info (indicating 10.0) but this API was not introduced until 10.12 Sierra!

So yeah, be careful out there and make sure you compile on every OS… or just use
deprecated API because they still work with no issues.

## Known Issues
- [#35 Support Unicode](https://github.com/jeffreybergier/MathEdit/issues/35)
- [#39 Support Nested Parenthesis](https://github.com/jeffreybergier/MathEdit/issues/39)
- [#48 Support RTF/D Documents](https://github.com/jeffreybergier/MathEdit/issues/48)
- [#54 Fix NSAttributedString Tests](https://github.com/jeffreybergier/MathEdit/issues/54)
- [#55 Fix NSBezierPath Tests](https://github.com/jeffreybergier/MathEdit/issues/55)

## What was \[Not\]Soulver for OpenStep
\[Not\]Soulver was the original name for MathEdit. MathEdit was inspired by
[Soulver](https://github.com/soulverteam) by Zac Cohan but is not related in any
way. If you want a high quality calculator app for your Mac you should purchase
and use [Soulver](https://github.com/soulverteam).
