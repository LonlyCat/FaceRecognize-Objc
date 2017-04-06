//
//  BSFaceDetector.m
//  FaceRecognize-Objc
//
//  Created by LonlyCat on 2017/2/9.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSFaceDetector.h"
#import <CoreMedia/CoreMedia.h>

@implementation BSFaceDetector
{
    std::vector<cv::Mat>  _faceImgs;
    std::vector<cv::Rect> _faceRects;
    
    cv::CascadeClassifier faceDetector;
}

+ (BSFaceDetector *)shareInstance
{
    static BSFaceDetector  *recognizer;
    static dispatch_once_t   onceToken;
    dispatch_once(&onceToken, ^{
        
        recognizer = [[BSFaceDetector alloc] init];
    });
    
    return recognizer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"lbpcascade_frontalface"
                                                                    ofType:@"xml"];
        const CFIndex CASCADE_NAME_LEN = 2048;
        char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
        CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
        
        
        faceDetector.load(CASCADE_NAME);
    }
    return self;
}

#pragma mark - 
+ (cv::Mat)detectorFaceWithCIImage:(CGImageRef)image
{
    BSFaceDetector *detector = [BSFaceDetector shareInstance];
    
    cv::Mat img = [detector processImage:image];
//    [detector detectorWithImage:img];
    return img;
}

+ (NSArray *)currentFaces
{
    BSFaceDetector *detector = [BSFaceDetector shareInstance];
    return [detector detectedFaces];
}

+ (CIImage *)CIImageWithCVMat:(cv::Mat)mat
{
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize()*mat.total()];
    CGColorSpaceRef colorSpace;
    
    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(mat.cols,                                   //width
                                        mat.rows,                                   //height
                                        8,                                          //bits per component
                                        8 * mat.elemSize(),                         //bits per pixel
                                        mat.step[0],                                //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    CIImage *finalImage = [CIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
#pragma mark - private function

- (cv::Mat)processImage:(CGImageRef)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    
    cv::Mat color(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(color.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    color.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
    CGContextRelease(contextRef);
    
    return color;
}

- (void)detectorWithImage:(cv::Mat)img
{
    std::vector<cv::Mat> faceImages;
    cv::Mat smallImg( cvRound (img.rows/2), cvRound(img.cols/2), CV_8UC1 );
    
    double scalingFactor = 1.1;     // 用不同的尺度遍历检测不同大小的人脸，scalingFactor决定每次遍历尺度会变大多少倍。
    int minNeighbors = 2;           // 拥有少于minNeighbors个符合条件的邻居像素人脸区域会被拒绝掉。
    int flags = 0;                  // 1.x的遗留物，始终设置为0
    cv::Size minSize(30,30);        // 寻找的人脸区域大小的最小值
    
    //faceRects向量会包含对识别获得的所有人脸区域。识别的人脸图像可以通过cv::Mat的()运算符提取出，方式为：cv::Mat faceImg = img(aFaceRect)
    self->faceDetector.detectMultiScale(smallImg, self->_faceRects,
                                         scalingFactor, minNeighbors, flags,
                                         minSize);
}

- (NSArray *)detectedFaces {
    NSMutableArray *facesArray = [NSMutableArray array];
    for( std::vector<cv::Rect>::const_iterator r = _faceRects.begin(); r != _faceRects.end(); r++ )
    {
        CGRect faceRect = CGRectMake(2*r->x/720., 2*r->y/1280., 2*r->width/720., 2*r->height/1280.);
        [facesArray addObject:[NSValue valueWithCGRect:faceRect]];
    }
    return facesArray;
}

@end
