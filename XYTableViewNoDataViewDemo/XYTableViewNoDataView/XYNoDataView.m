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

/**
 销毁时, 移除别人对自己的监听
 */
- (void)dealloc {
    if (self.observerObject) {
        [self removeObserver:self.observerObject forKeyPath:kXYNoDataViewObserveKeyPath];
    }
}

@end
