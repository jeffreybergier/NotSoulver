![Screenshot of the app running in OpenStep](README/screenshot16.png)

# \[Not\] Soulver for OpenStep 4.2
A rudimentary calculator inspired by [Soulver](https://github.com/soulverteam) written in ancient Objective C that compiles and runs in OpenStep 4.2. The calculator logic also compiles and runs properly in Xcode 16. I guess that says a lot about the stability of Objective C and Foundation over the years.

## Disclaimer
This software is NOT related to [Soulver](https://github.com/soulverteam) by Zac Cohan. This application was inspired by Soulver and created as a learning exercise. You should purchase and use [Soulver](https://github.com/soulverteam) by Zac Cohan instead of using this software.

## How to Use
This application parses the mathematical formulas out of the text and solves them them inline. The equal sign is used to indicate you would like the problem to be solved.

### App Features
- Full PEMDAS order of operations support
- NSDocument support
- Keyboard input support
- Syntax highlighting with custom fonts
- Themeing and dark mode support

## How it Works
Description to be provided

### Technical Features
- Ancient Objective-C
    - ❌ No Automatic Reference Counting
    - ❌ No Property Synthesization
    - ❌ No Blocks
    - ❌ No Fast Enumeration → Use `NSEnumerator`
    - ❌ No Collection Literals → Use `nil` terminated initializers
- Ancient Foundation: Only uses Foundation API that were available in Mac OS X 10.0 🥵
    - e.g. [`[NSFont userFixedPitchFontOfSize:]`](https://developer.apple.com/documentation/appkit/nsfont/1531381-userfixedpitchfontofsize?language=objc#)
    - e.g. [`[NSSet member:]`](https://developer.apple.com/documentation/foundation/nsset/1412896-member?language=objc#)
- [`SLRE.h/c` Regex](./Soulver/slre.h) Added to bring REGEX to ancient systems

### Known Problems
- Nested parenthesis not supported
- NSTextAttachments with solutions are not always aligned properly
