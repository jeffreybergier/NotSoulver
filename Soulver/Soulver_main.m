#import <AppKit/AppKit.h>

int main(int argc, const char *argv[]) {
#ifdef OS_OPENSTEP
  return NSApplicationMain(argc, argv);
#else
  return 0;
#endif
}
