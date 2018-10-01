//
//  ViewController.m
//  OpenCVTest
//
//  Created by jackyshan on 2018/9/28.
//  Copyright © 2018年 GCI. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import "ViewController.h"
#import <opencv2/imgcodecs/ios.h>

using namespace cv;
using namespace std;

@interface ViewController () {
    CascadeClassifier _faceDetector;
    
    vector<cv::Rect> _faceRects;
    vector<cv::Mat> _faceImgs;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //预设置face探测的参数
    [self preSetFace];
    
    //image转mat
    cv::Mat mat;
    UIImageToMat(self.imageView.image, mat);
    
    //执行face
    [self processImage:mat];
}

- (void)preSetFace {
    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2"
                                                                ofType:@"xml"];
    
    const CFIndex CASCADE_NAME_LEN = 2048;
    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
    CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
    
    _faceDetector.load(CASCADE_NAME);
    
    free(CASCADE_NAME);
}

- (void)processImage:(cv::Mat&)inputImage {
    // Do some OpenCV stuff with the image
    cv::Mat frame_gray;

    //转换为灰度图像
    cv::cvtColor(inputImage, frame_gray, CV_BGR2GRAY);
    
    //图像均衡化
    cv::equalizeHist(frame_gray, frame_gray);

    //分类器识别
    _faceDetector.detectMultiScale(frame_gray, _faceRects,1.1,2,0,cv::Size(30,30));

    vector<cv::Rect> faces;
    faces = _faceRects;
    
    // 在每个人脸上画一个红色四方形
    for(unsigned int i= 0;i < faces.size();i++)
    {
        const cv::Rect& face = faces[i];
        cv::Point tl(face.x,face.y);
        cv::Point br = tl + cv::Point(face.width,face.height);
        // 四方形的画法
        cv::Scalar magenta = cv::Scalar(255, 0, 0, 255);
        cv::rectangle(inputImage, tl, br, magenta, 3, 8, 0);
    }
    UIImage *outputImage = MatToUIImage(inputImage);
    self.imageView.image = outputImage;
}

@end
