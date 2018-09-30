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

@property (nonatomic, assign) CGFloat scale;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scale = 2;
    
    //预设置face探测的参数
    [self preSetFace];
    
    //image转mat
    cv::Mat mat;
    UIImageToMat(self.imageView.image, mat);
    
    //执行face
    [self processImage:mat];
    
    //获得image
//    self.imageView.image = MatToUIImage(_faceImgs[0]);

    //画框
    [self setRedLayer];
    
}

- (void)setRedLayer {
    NSArray *detectedFaces = [self detectedFaces];
    cv::Mat mat;
    //转换成cv::Mat
    UIImageToMat(self.imageView.image, mat);

    for (NSValue *val in detectedFaces) {
        CGRect r = [val CGRectValue];
        //画框
        UIView *faceBox = [[UIView alloc] initWithFrame:r];
        faceBox.layer.borderWidth = 3;
        faceBox.layer.borderColor = [UIColor redColor].CGColor;
        faceBox.backgroundColor = [UIColor clearColor];
        [self.view addSubview:faceBox];

    }
    
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

- (NSArray *)detectedFaces {
    NSMutableArray *facesArray = [NSMutableArray array];
    CGFloat scale = _scale;
    for( vector<cv::Rect>::const_iterator r = _faceRects.begin(); r != _faceRects.end(); r++ )
    {
//        CGRect faceRect = CGRectMake((r->x+ r->width-1)/_scale, _scale*r->y, r->width/_scale, r->height/_scale);
        CGRect faceRect = CGRectMake(r->x, r->y, r->width, r->height);

        [facesArray addObject:[NSValue valueWithCGRect:faceRect]];
    }
    
    NSLog(@"%@", facesArray);
    return facesArray;
}

- (void)processImage:(cv::Mat&)image {
    // Do some OpenCV stuff with the image
    //转换为灰度图像
    
    cv::cvtColor(image, image, CV_BGR2GRAY);

    [self detectAndDrawFacesOn:image scale:_scale];
}

- (void)detectAndDrawFacesOn:(Mat&)inputMat scale:(double)scale
{
    //图像均衡化
    cv::equalizeHist(inputMat, inputMat);
    //定义向量，存储识别出的位置

    //分类器识别
    _faceDetector.detectMultiScale(inputMat, _faceRects, 1.1, 3, 0);
    //转换为Frame，保存在数组中
}


@end
