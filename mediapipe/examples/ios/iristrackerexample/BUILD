MIN_IOS_VERSION = "10.0"

load(
    "@build_bazel_rules_apple//apple:ios.bzl",
    "ios_application",
)

load(
    "//mediapipe/examples/ios:bundle_id.bzl",
    "BUNDLE_ID_PREFIX",
    "example_provisioning",
)

ios_application(
    name = "IrisTrackerExampleApp",
    bundle_id = BUNDLE_ID_PREFIX + ".IrisTrackerExample",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = ["Info.plist"],
    minimum_os_version = MIN_IOS_VERSION,
    provisioning_profile = example_provisioning(),
    deps = [":IrisTrackerExampleAppLibrary"],
)

objc_library(
    name = "IrisTrackerExampleAppLibrary",
    srcs = [
        "AppDelegate.mm",
        "SceneDelegate.mm",
        "ViewController.mm",
        "main.m",
    ],
    copts = ["-std=c++17"],
    hdrs = [
        "AppDelegate.h",
        "SceneDelegate.h",
        "ViewController.h",
    ],
    data = [
        "Base.lproj/LaunchScreen.storyboard",
        "Base.lproj/Main.storyboard",
    ],
    sdk_frameworks = [
        "UIKit",
    ],
    deps = [        
        "//mediapipe/examples/ios/iristracker:IrisTrackerLibrary",
    ],
)