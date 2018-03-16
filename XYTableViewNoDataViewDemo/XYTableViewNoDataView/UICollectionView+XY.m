//
//  UITableView+XY.m
//  XYTableViewNoDataView
//
//  Created by 韩元旭 on 2017/7/19.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "UICollectionView+XY.h"
#import "XYNoDataView.h"
#import <objc/runtime.h>

/**
 消除警告
 */
@protocol XYTableViewDelegate <NSObject>
@optional
- (UIView   *)xy_noDataView;                //  完全自定义占位图
- (UIImage  *)xy_noDataViewImage;           //  使用默认占位图, 提供一张图片,    可不提供, 默认不显示
- (NSString *)xy_noDataViewMessage;         //  使用默认占位图, 提供显示文字,    可不提供, 默认为暂无数据
- (UIColor  *)xy_noDataViewMessageColor;    //  使用默认占位图, 提供显示文字颜色, 可不提供, 默认为灰色
- (NSNumber *)xy_noDataViewCenterYOffset;   //  使用默认占位图, CenterY 向下的偏移量
@end


@implementation UICollectionView (XY)

/**
 加载时, 交换方法
 */
+ (void)load {
    //  只交换一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            
        Method reloadData    = class_getInstanceMethod(self, @selector(reloadData));
        Method xy_reloadData = class_getInstanceMethod(self, @selector(xy_reloadData));
        method_exchangeImplementations(reloadData, xy_reloadData);
        
        Method dealloc       = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
        Method xy_dealloc    = class_getInstanceMethod(self, @selector(xy_dealloc));
        method_exchangeImplementations(dealloc, xy_dealloc);
    });
}

/**
 在 ReloadData 的时候检查数据
 */
- (void)xy_reloadData {
    
    [self xy_reloadData];
    
    //  忽略第一次加载
    if (![self isInitFinish]) {
        [self xy_havingData:YES];
        [self setIsInitFinish:YES];
        return ;
    }
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
        
        [self xy_havingData:havingData];
    });
}

/**
 展示占位图
 */
- (void)xy_havingData:(BOOL)havingData {
    
    //  不需要显示占位图
    if (havingData) {
        [self freeNoDataViewIfNeeded];
        self.backgroundView = nil;
        return ;
    }
    
    //  不需要重复创建
    if (self.backgroundView) {
        return ;
    }
    
    //  自定义了占位图
    if ([self.delegate respondsToSelector:@selector(xy_noDataView)]) {
        self.backgroundView = [self.delegate performSelector:@selector(xy_noDataView)];
        return ;
    }
    
    //  使用自带的
    UIImage  *img   = nil;
    NSString *msg   = @"暂无数据";
    UIColor  *color = [UIColor lightGrayColor];
    CGFloat  offset = 0;
    
    //  获取图片
    if ([self.delegate    respondsToSelector:@selector(xy_noDataViewImage)]) {
        img = [self.delegate performSelector:@selector(xy_noDataViewImage)];
    }
    //  获取文字
    if ([self.delegate    respondsToSelector:@selector(xy_noDataViewMessage)]) {
        msg = [self.delegate performSelector:@selector(xy_noDataViewMessage)];
    }
    //  获取颜色
    if ([self.delegate      respondsToSelector:@selector(xy_noDataViewMessageColor)]) {
        color = [self.delegate performSelector:@selector(xy_noDataViewMessageColor)];
    }
    //  获取偏移量
    if ([self.delegate        respondsToSelector:@selector(xy_noDataViewCenterYOffset)]) {
        offset = [[self.delegate performSelector:@selector(xy_noDataViewCenterYOffset)] floatValue];
    }
    
    //  创建占位图
    self.backgroundView = [self xy_defaultNoDataViewWithImage  :img message:msg color:color offsetY:offset];
}

/**
 默认的占位图
 */
- (UIView *)xy_defaultNoDataViewWithImage:(UIImage *)image message:(NSString *)message color:(UIColor *)color offsetY:(CGFloat)offset {
    
    //  计算位置, 垂直居中, 图片默认中心偏上.
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat cY = self.bounds.size.height * (1 - 0.618) + offset;
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
    XYNoDataView *view   = [[XYNoDataView alloc] init];
    [view addSubview:imgView];
    [view addSubview:label];
    
    //  实现跟随 TableView 滚动
    [view addObserver:self forKeyPath:kXYNoDataViewObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return view;
}


/**
 监听
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kXYNoDataViewObserveKeyPath]) {
        
        /**
         在 TableView 滚动 ContentOffset 改变时, 会同步改变 backgroundView 的 frame.origin.y
         可以实现, backgroundView 位置相对于 TableView 不动, 但是我们希望
         backgroundView 跟随 TableView 的滚动而滚动, 只能强制设置 frame.origin.y 永远为 0
         兼容 MJRefresh
         */
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if (frame.origin.y != 0) {
            frame.origin.y  = 0;
            self.backgroundView.frame = frame;
        }
    }
}

#pragma mark - 属性

/**
 设置已经加载完成数据了
 */
- (void)setIsInitFinish:(BOOL)finish {
    objc_setAssociatedObject(self, @selector(isInitFinish), @(finish), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 是否已经加载完成数据
 */
- (BOOL)isInitFinish {
    id obj = objc_getAssociatedObject(self, _cmd);
    return [obj boolValue];
}

/**
 移除 KVO 监听
 */
- (void)freeNoDataViewIfNeeded {
    
    if ([self.backgroundView isKindOfClass:[XYNoDataView class]]) {
        [self.backgroundView removeObserver:self forKeyPath:kXYNoDataViewObserveKeyPath context:nil];
    }
}

- (void)xy_dealloc {
    [self freeNoDataViewIfNeeded];
    [self xy_dealloc];
    NSLog(@"CollectionView + XY 视图正常销毁");
}

@end
