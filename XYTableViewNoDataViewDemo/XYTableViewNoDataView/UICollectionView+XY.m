//
//  UITableView+AN.m
//  XYTableViewNoDataView
//
//  Created by 韩元旭 on 2017/7/19.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "UICollectionView+XY.h"
#import <objc/runtime.h>

/**
 消除警告
 */
@protocol XYTableViewDelegate <NSObject>
@optional
- (UIView   *)an_noDataView;                //  完全自定义占位图
- (UIImage  *)an_noDataViewImage;           //  使用默认占位图, 提供一张图片,    可不提供, 默认不显示
- (NSString *)an_noDataViewMessage;         //  使用默认占位图, 提供显示文字,    可不提供, 默认为暂无数据
- (UIColor  *)an_noDataViewMessageColor;    //  使用默认占位图, 提供显示文字颜色, 可不提供, 默认为灰色
@end


@implementation UICollectionView (XY)


/**
 加载时, 交换方法
 */
+ (void)load {
    
    Method reloadData    = class_getInstanceMethod(self, @selector(reloadData));
    Method an_reloadData = class_getInstanceMethod(self, @selector(an_reloadData));
    method_exchangeImplementations(reloadData, an_reloadData);
}

/**
 在 ReloadData 的时候检查数据
 */
- (void)an_reloadData {
    
    [self an_reloadData];
    
    //  刷新完成之后检测数据量
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger numberOfSections = [self numberOfSections];
        BOOL havingData = NO;
        for (NSInteger i = 0; i < numberOfSections; i++) {
            if ([self numberOfItemsInSection:i] > 0) {
                havingData = YES;
                break;
            }
        }
        
        [self an_havingData:havingData];
    });
}


/**
 展示占位图
 */
- (void)an_havingData:(BOOL)havingData {
    
    //  不需要显示占位图
    if (havingData) {
        self.backgroundView = nil;
        return ;
    }
    
    //  自定义了占位图
    if ([self.delegate respondsToSelector:@selector(an_noDataView)]) {
        self.backgroundView = [self.delegate performSelector:@selector(an_noDataView)];
        return ;
    }
    
    //  使用自带的
    UIImage  *img   = nil;
    NSString *msg   = @"暂无数据";
    UIColor  *color = [UIColor lightGrayColor];
    
    //  获取图片
    if ([self.delegate    respondsToSelector:@selector(an_noDataViewImage)]) {
        img = [self.delegate performSelector:@selector(an_noDataViewImage)];
    }
    //  获取文字
    if ([self.delegate    respondsToSelector:@selector(an_noDataViewMessage)]) {
        msg = [self.delegate performSelector:@selector(an_noDataViewMessage)];
    }
    //  获取颜色
    if ([self.delegate      respondsToSelector:@selector(an_noDataViewMessageColor)]) {
        color = [self.delegate performSelector:@selector(an_noDataViewMessageColor)];
    }
    
    if (img) {
        self.backgroundView = [self an_defaultNoDataViewWithImage  :img message:msg color:color];
    } else {
        self.backgroundView = [self an_defaultNoDataViewWithMessage:msg color:color];
    }
    
}

/**
 默认没有图片只有文字的占位图
 */
- (UIView *)an_defaultNoDataViewWithMessage:(NSString *)message color:(UIColor *)color {
    
    UILabel *messageLabel       = [UILabel new];
    messageLabel.text           = message;
    messageLabel.textColor      = color;
    messageLabel.font           = [UIFont systemFontOfSize:17];
    messageLabel.textAlignment  = NSTextAlignmentCenter;
    
    [messageLabel sizeToFit];
    return messageLabel;
}

/**
 默认带图片和文字的占位图
 */
- (UIView *)an_defaultNoDataViewWithImage:(UIImage *)image message:(NSString *)message color:(UIColor *)color {
    
    //  计算位置, 垂直居中, 图片默认中心偏上.
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat cY = self.bounds.size.height * (1 - 0.618);
    CGFloat iW = image.size.width;
    CGFloat iH = image.size.height;
    
    //  图片
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.frame        = CGRectMake(cX - iW / 2, cY - iH / 2, iW, iH);
    imgView.image        = image;
    
    
    //  文字
    UILabel *label       = [[UILabel alloc] init];
    label.font           = [UIFont systemFontOfSize:17];
    label.textColor      = color;
    label.text           = message;
    label.textAlignment  = NSTextAlignmentCenter;
    label.frame          = CGRectMake(0, CGRectGetMaxY(imgView.frame) + 24, sW, label.font.lineHeight);
    
    //  视图
    UIView *view         = [[UIView alloc] init];
    [view addSubview:imgView];
    [view addSubview:label];
    return view;
}

@end
