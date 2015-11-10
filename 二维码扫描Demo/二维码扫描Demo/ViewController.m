//
//  ViewController.m
//  二维码扫描Demo
//
//  Created by 孙菲 on 15/11/3.
//  Copyright © 2015年 孙菲. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "ResultController.h"
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>//用于处理采集信息的代理

{
    AVCaptureSession * session; //输入输出的中间桥梁
    NSTimer * timer;
    UIImageView * lineView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 100, 200, 200)];
    [self.view addSubview:imageView];
    imageView.image = [self createNonInterpolatedUIImageFormCIImage:[self create] withSize:200];
    
}
#pragma mark -创建二维码
//需要CoreImage
-(CIImage *)create{
    // 1、创建过滤器
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2、恢复滤镜的默认属性
    [filter setDefaults];
    // 3、设置内容
    NSString * str = @"生成一个二维码";
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    // 4、获取输出文件
    CIImage * outputImage = [filter outputImage];
    // 5、显示二维码
    return outputImage;
    
}

/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}





#pragma mark -扫描二维码或者条形码
-(void)scan{
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(move) userInfo:nil repeats:YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output =  [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.frame = CGRectMake(50, 100, 200, 200);
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [session startRunning];
    
    lineView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 100, 200, 16)];
    [self.view addSubview:lineView];
    lineView.image = [UIImage imageNamed:@"qrcode_scan_light_green"];
}

#pragma mark - 线的移动
-(void)move
{
    if(lineView.frame.origin.y ==100+200-16){
        lineView.frame = CGRectMake(50, 100, 200, 16);
    }
    
    [UIView animateWithDuration:3 animations:^{
        lineView.frame =CGRectMake(50, 100+200-16, 200, 16);

    }];
}

-(void)dealloc
{
    timer = nil;
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"%@",metadataObject.stringValue);
        ResultController * vc = [[ResultController alloc]init];
        vc.string = metadataObject.stringValue;
        [self presentViewController:vc  animated:YES completion:nil];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
