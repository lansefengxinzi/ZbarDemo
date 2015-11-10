//
//  ResultController.m
//  二维码扫描Demo
//
//  Created by 孙菲 on 15/11/3.
//  Copyright © 2015年 孙菲. All rights reserved.
//

#import "ResultController.h"

@interface ResultController ()

@end

@implementation ResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, 100, 100)];
    [self.view addSubview:label];
    label.text =self.string;
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
