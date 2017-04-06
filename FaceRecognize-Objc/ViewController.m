//
//  ViewController.m
//  FaceRecognize-Objc
//
//  Created by LonlyCat on 2017/2/9.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "ViewController.h"

#import "VideoViewController.h"
#import "CameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonAction:(id)sender {
    
    CameraViewController  *cameraVC = [[CameraViewController alloc] init];
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (IBAction)videoButtonAction:(id)sender {
    
    VideoViewController  *videoVC = [[VideoViewController alloc] init];
    [self presentViewController:videoVC animated:YES completion:nil];
}

@end
