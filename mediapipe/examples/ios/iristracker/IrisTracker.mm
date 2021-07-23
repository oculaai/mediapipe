#import "IrisTracker.h"
#import "mediapipe/objc/MPPGraph.h"
#include "mediapipe/framework/formats/landmark.pb.h"

static NSString* const kGraphName = @"iris_tracking_gpu";
static const char* kInputStream = "input_video";
static const char* kOutputStream = "output_video";
static const char* kLandmarksOutputStream = "eye_landmarks_with_iris";
static const char* kVideoQueueLabel = "com.google.mediapipe.example.videoQueue";

@interface IrisTracker() <MPPGraphDelegate> 
@property(nonatomic) MPPGraph* mediapipeGraph;
@end

@interface Landmark()
- (instancetype)initWithX:(float)x y:(float)y z:(float)z;
@end

@implementation IrisTracker {
  /// Input side packet for focal length parameter.
  std::map<std::string, mediapipe::Packet> _input_side_packets;
  mediapipe::Packet _focal_length_side_packet;
}

#pragma mark - Cleanup methods

- (void)dealloc {
    self.mediapipeGraph.delegate = nil;
    [self.mediapipeGraph cancel];
    // Ignore errors since we're cleaning up.
    [self.mediapipeGraph closeAllInputStreamsWithError:nil];
    [self.mediapipeGraph waitUntilDoneWithError:nil];
}

#pragma mark - MediaPipe graph methods

+ (MPPGraph*)loadGraphFromResource:(NSString*)resource {
    // Load the graph config resource.
    NSError* configLoadError = nil;
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    if (!resource || resource.length == 0) {
        return nil;
    }
    NSURL* graphURL = [bundle URLForResource:resource withExtension:@"binarypb"];
    NSData* data = [NSData dataWithContentsOfURL:graphURL options:0 error:&configLoadError];
    if (!data) {
        NSLog(@"Failed to load MediaPipe graph config: %@", configLoadError);
        return nil;
    }
    
    // Parse the graph config resource into mediapipe::CalculatorGraphConfig proto object.
    mediapipe::CalculatorGraphConfig config;
    config.ParseFromArray(data.bytes, data.length);
    
    // Create MediaPipe graph with mediapipe::CalculatorGraphConfig proto object.
    MPPGraph* newGraph = [[MPPGraph alloc] initWithGraphConfig:config];
    [newGraph addFrameOutputStream:kOutputStream outputPacketType:MPPPacketTypePixelBuffer];
    [newGraph addFrameOutputStream:kLandmarksOutputStream outputPacketType:MPPPacketTypeRaw];

    return newGraph;
}

- (instancetype)initWithMaxFramesInFlight:(int)maxFramesInFlight
{
    self = [super init];
    if (self) {
        self.mediapipeGraph = [[self class] loadGraphFromResource:kGraphName];
        self.mediapipeGraph.delegate = self;
        // Set maxFramesInFlight to a small value to avoid memory contention for real-time processing.
        self.mediapipeGraph.maxFramesInFlight = maxFramesInFlight;
        
        _focal_length_side_packet =
            mediapipe::MakePacket<std::unique_ptr<float>>(absl::make_unique<float>(0.0));
        _input_side_packets = {
            {"focal_length_pixel", _focal_length_side_packet},
        };
        [self.mediapipeGraph addSidePackets:_input_side_packets];
    }
    return self;
}

- (void)startGraph {
    // Start running self.mediapipeGraph.
    NSError* error;
    if (![self.mediapipeGraph startWithError:&error]) {
        NSLog(@"Failed to start graph: %@", error);
    }
}

#pragma mark - MPPGraphDelegate methods

// Receives CVPixelBufferRef from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
            fromStream:(const std::string&)streamName timestamp:(const mediapipe::Timestamp &)timestamp {
      if (streamName == kOutputStream) {
          [_delegate irisTracker: self didOutputPixelBuffer: pixelBuffer timestamp:timestamp.Value()];
      }
}

// Receives a raw packet from the MediaPipe graph. Invoked on a MediaPipe worker thread.
- (void)mediapipeGraph:(MPPGraph*)graph
       didOutputPacket:(const ::mediapipe::Packet&)packet
            fromStream:(const std::string&)streamName {
    if (streamName == kLandmarksOutputStream) {
        if (packet.IsEmpty()) { return; }
        const auto& landmarks = packet.Get<::mediapipe::NormalizedLandmarkList>();
        NSMutableArray<Landmark *> *result = [NSMutableArray array];
        for (int i = 0; i < landmarks.landmark_size(); ++i) {
            Landmark *landmark = [[Landmark alloc] initWithX:landmarks.landmark(i).x()
                                                           y:landmarks.landmark(i).y()
                                                           z:landmarks.landmark(i).z()];
            [result addObject:landmark];
        }
        [_delegate irisTracker: self didOutputLandmarks: result timestamp:packet.Timestamp().Value()];
    }
}

- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer timestamp:(long)timestamp {
    [self.mediapipeGraph sendPixelBuffer:imageBuffer
                              intoStream:kInputStream
                              packetType:MPPPacketTypePixelBuffer
                               timestamp:mediapipe::Timestamp(timestamp)];
}

@end


@implementation Landmark

- (instancetype)initWithX:(float)x y:(float)y z:(float)z
{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}

@end
