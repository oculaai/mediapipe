//
//  ViewController.m
//  IrisTrackerExample
//
//  Created by Minh DrMinh on 22/07/2021.
//

#import "ViewController.h"
#import "mediapipe/examples/ios/iristracker/IrisTracker.h"

@interface ViewController ()

@property IrisTracker *tracker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tracker = [[IrisTracker alloc] init];
}


@end
