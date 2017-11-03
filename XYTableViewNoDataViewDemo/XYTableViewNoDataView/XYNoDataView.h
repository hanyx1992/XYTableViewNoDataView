//
//  XYNoDataView.h
//  XYTableViewNoDataViewDemo
//
//  Created by 韩元旭 on 2017/11/3.
//  Copyright © 2017年 韩元旭. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kXYNoDataViewObserveKeyPath;

@interface XYNoDataView : UIView

/// 观察者
@property (nonatomic, weak) id observerObject;

@end
