//
//  BSFaceDetector.h
//  FaceRecognize-Objc
//
//  Created by LonlyCat on 2017/2/9.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/highgui_c.h>
#endif

@interface BSFaceDetector : NSObject

+ (CIImage *)CIImageWithCVMat:(cv::Mat)mat;
+ (cv::Mat)detectorFaceWithCIImage:(CGImageRef)image;
+ (NSArray *)currentFaces;

@end
