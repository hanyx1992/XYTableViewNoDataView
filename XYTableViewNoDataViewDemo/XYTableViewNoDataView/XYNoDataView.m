//
//  XYNoDataView.m
//  XYTableViewNoDataViewDemo
//
//  Created by 韩元旭 on 2017/11/3.
//  Copyright © 2017年 韩元旭. All rights reserved.
//

#import "XYNoDataView.h"

NSString * const kXYNoDataViewObserveKeyPath = @"frame";

@implementation XYNoDataView

- (void)dealloc {
    NSLog(@"占位视图正常销毁");
}

@end
