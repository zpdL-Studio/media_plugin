#import "ZpdlStudioMediaPlugin.h"
#if __has_include(<zpdl_studio_media_plugin/zpdl_studio_media_plugin-Swift.h>)
#import <zpdl_studio_media_plugin/zpdl_studio_media_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zpdl_studio_media_plugin-Swift.h"
#endif

@implementation ZpdlStudioMediaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZpdlStudioMediaPlugin registerWithRegistrar:registrar];
}
@end
