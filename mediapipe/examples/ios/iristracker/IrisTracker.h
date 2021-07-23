#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class Landmark;
@class IrisTracker;

@protocol TrackerDelegate <NSObject>
- (void)irisTracker: (IrisTracker*)irisTracker didOutputLandmarks:(NSArray<Landmark *> *)landmarks timestamp:(long)timestamp;
- (void)irisTracker: (IrisTracker*)irisTracker didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer timestamp:(long)timestamp;
@end

@interface IrisTracker : NSObject
- (instancetype)initWithMaxFramesInFlight:(int)maxFramesInFlight;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer timestamp:(long)timestamp;
@property (weak, nonatomic) id <TrackerDelegate> delegate;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
