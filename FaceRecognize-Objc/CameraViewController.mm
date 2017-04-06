//
//  CameraViewController.m
//  FaceRecognize-Objc
//
//  Created by LonlyCat on 2017/2/9.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "CameraViewController.h"

#import "BSFaceDetector.h"
#import "FaceAnimator.hpp"

#import <GLKit/GLKit.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController ()
<
AVCaptureVideoDataOutputSampleBufferDelegate
>

@property (strong, nonatomic) GLKView      *previewView;
@property (strong, nonatomic) CIContext    *ciContext;
@property (strong, nonatomic) EAGLContext  *glContext;

@property (strong, nonatomic) CIDetector   *faceDetector;

@property (strong, nonatomic) AVCaptureSession      *session;

@end

@implementation CameraViewController
{
    FaceAnimator::Parameters parameters;
    cv::Ptr<FaceAnimator> faceAnimator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupPreiverView];
    [self setupCaptureSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPreiverView {
    
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _ciContext = [CIContext contextWithEAGLContext:_glContext];
    
    _previewView = [[GLKView alloc] initWithFrame:self.view.bounds context:_glContext];
    [self.view addSubview:_previewView];
}

- (void)setupCaptureSession {
    
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
    
    _session = [[AVCaptureSession alloc] init];
    if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    
    AVCaptureDevice  *device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].lastObject;
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [device lockForConfiguration:nil];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [device unlockForConfiguration];
    }
    
    NSError  *error;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (!error) {
        
        [_session addInput:deviceInput];
    }
    
    AVCaptureVideoDataOutput  *deviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [deviceOutput setAlwaysDiscardsLateVideoFrames:YES];
    [deviceOutput setSampleBufferDelegate:self queue:dispatch_queue_create("buffer delegate", 0)];
    [_session addOutput:deviceOutput];
    
    AVCaptureConnection  *connect = [deviceOutput connectionWithMediaType:AVMediaTypeVideo];
    connect.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [_session startRunning];
    
    faceAnimator = new FaceAnimator(parameters);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    
    CVPixelBufferRef  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage  *image = [CIImage imageWithCVPixelBuffer:imageBuffer];
    
    CGImageRef imgeRef = [_ciContext createCGImage:image fromRect:image.extent];
    cv::Mat mat = [BSFaceDetector detectorFaceWithCIImage:imgeRef];
    faceAnimator->detectAndAnimateFaces(mat);
    
    image = [BSFaceDetector CIImageWithCVMat:mat];
    
    [_previewView bindDrawable];
    CGFloat  scale = [UIScreen mainScreen].scale;
    [_ciContext drawImage:image
                   inRect:CGRectMake(0,
                                     0,
                                     _previewView.frame.size.width * scale,
                                     _previewView.frame.size.height * scale)
                 fromRect:image.extent];
    [_previewView display];
}

@end
