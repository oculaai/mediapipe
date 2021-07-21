#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class Landmark;
@class IrisTracker;

@protocol TrackerDelegate <NSObject>
- (void)irisTracker: (IrisTracker*)irisTracker didOutputLandmarks: (NSArray<Landmark *> *)landmarks;
- (void)irisTracker: (IrisTracker*)irisTracker didOutputPixelBuffer: (CVPixelBufferRef)pixelBuffer;
@end

@interface IrisTracker : NSObject
- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer;
@property (weak, nonatomic) id <TrackerDelegate> delegate;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
