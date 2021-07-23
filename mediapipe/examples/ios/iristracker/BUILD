load("@build_bazel_rules_apple//apple:ios.bzl", "ios_framework")

ios_framework(
    name = "IrisTracker",
    hdrs = [
        "IrisTracker.h",
    ],
    infoplists = ["Info.plist"],
    bundle_id = "com.minhdv.IrisTracker",
    families = ["iphone", "ipad"],
    minimum_os_version = "10.0",
    deps = [
        ":IrisTrackerLibrary",
        "@ios_opencv//:OpencvFramework",
    ],
)

objc_library(
    name = "IrisTrackerLibrary",
    srcs = [
        "IrisTracker.mm",
    ],
    hdrs = [
        "IrisTracker.h",
    ],
    copts = ["-std=c++17"],
    data = [
        "//mediapipe/graphs/iris_tracking:iris_tracking_gpu.binarypb",
        "//mediapipe/modules/face_detection:face_detection_short_range.tflite",
        "//mediapipe/modules/face_landmark:face_landmark.tflite",
        "//mediapipe/modules/iris_landmark:iris_landmark.tflite",
    ],
    visibility = ["//mediapipe:__subpackages__"],
    deps = [
        "//mediapipe/objc:mediapipe_framework_ios",
    ] + select({
        "//mediapipe:ios_i386": [],
        "//mediapipe:ios_x86_64": [],
        "//conditions:default": [
            "//mediapipe/graphs/iris_tracking:iris_tracking_gpu_deps",
            "//mediapipe/framework/formats:landmark_cc_proto",
        ],
    }),
)

