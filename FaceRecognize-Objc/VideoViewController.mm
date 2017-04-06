//
//  VideoViewController.m
//  FaceRecognize-Objc
//
//  Created by LonlyCat on 2017/2/9.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "VideoViewController.h"

#import "BSFaceDetector.h"
#import "FaceAnimator.hpp"

#import <GLKit/GLKit.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoViewController ()

@property (strong, nonatomic) AVPlayer          *player;
@property (strong, nonatomic) AVPlayerItem      *playerItem;
@property (strong, nonatomic) AVPlayerItemVideoOutput  *videoOutput;

@property (strong, nonatomic) GLKView           *playerView;
@property (strong, nonatomic) EAGLContext       *glContext;
@property (strong, nonatomic) CIContext         *ciContext;

@end

@implementation VideoViewController
{
    FaceAnimator::Parameters parameters;
    cv::Ptr<FaceAnimator> faceAnimator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupPlayerView];
    [self setupPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPlayerView
{
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _ciContext = [CIContext contextWithEAGLContext:_glContext];
    
    _playerView = [[GLKView alloc] initWithFrame:self.view.bounds context:_glContext];
    [self.view addSubview:_playerView];
    
    [EAGLContext setCurrentContext:_glContext];
    
    UIImage* resImage = [UIImage imageNamed:@"glasses.png"];
    UIImageToMat(resImage, parameters.glasses, true);
    cvtColor(parameters.glasses, parameters.glasses, CV_BGRA2RGBA);
    
    resImage = [UIImage imageNamed:@"mustache.png"];
    UIImageToMat(resImage, parameters.mustache, true);
    cvtColor(parameters.mustache, parameters.mustache, CV_BGRA2RGBA);
    
    // Load Cascade Classisiers
    NSString* filename = [[NSBundle mainBundle]
                          pathForResource:@"lbpcascade_frontalface"
                          ofType:@"xml"];
    parameters.faceCascade.load([filename UTF8String]);
    
    filename = [[NSBundle mainBundle]
                pathForResource:@"haarcascade_mcs_eyepair_big"
                ofType:@"xml"];
    parameters.eyesCascade.load([filename UTF8String]);
    
    filename = [[NSBundle mainBundle]
                pathForResource:@"haarcascade_mcs_mouth"
                ofType:@"xml"];
    parameters.mouthCascade.load([filename UTF8String]);
    faceAnimator = new FaceAnimator(parameters);
}

- (void)setupPlayer
{ // http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8
    // http://pili-live-hls.live.dev.demodemo.cc/xiaoyang-live-test/odfwp8kp.m3u8
    NSURL *url = [NSURL URLWithString:@"http://pili-live-hls.live.dev.demodemo.cc/xiaoyang-live-test/oi1afxyo.m3u8"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    _playerItem = [AVPlayerItem playerItemWithAsset:asset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:NULL];
    [_playerItem addOutput:_videoOutput];
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [_player play];
}

- (void)displayLinkCallback:(CADisplayLink *)sender{
    
    CMTime outputItemTime = kCMTimeInvalid;
    
    // Calculate the nextVsync time which is when the screen will be refreshed next.
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    
    outputItemTime = [_videoOutput itemTimeForHostTime:nextVSync];
    
    if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef buffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        
        CIImage  *image = [CIImage imageWithCVPixelBuffer:buffer];
        
        CGImageRef imgeRef = [_ciContext createCGImage:image fromRect:image.extent];
        cv::Mat mat = [BSFaceDetector detectorFaceWithCIImage:imgeRef];
        faceAnimator->detectAndAnimateFaces(mat);
        
        image = [BSFaceDetector CIImageWithCVMat:mat];
        
        [_playerView bindDrawable];
        CGFloat  scale = [UIScreen mainScreen].scale;
        [_ciContext drawImage:image inRect:CGRectMake(0,
                                                      0,
                                                      _playerView.frame.size.width * scale,
                                                      _playerView.frame.size.height * scale)
                     fromRect:image.extent];
        [_playerView display];
        
        CFRelease(buffer);
        CFRelease(imgeRef);
    }
}

@end
