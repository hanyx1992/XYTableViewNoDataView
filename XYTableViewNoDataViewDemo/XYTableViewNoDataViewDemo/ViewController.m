//
//  ViewController.m
//  XYTableViewNoDataViewDemo
//
//  Created by 韩元旭 on 2017/7/19.
//  Copyright © 2017年 韩元旭. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

#pragma mark - TableView 占位图

- (UIImage *)an_noDataViewImage {
    return [UIImage imageNamed:@"note_list_no_data"];
}

- (NSString *)an_noDataViewMessage {
    return @"都用起来吧, 起飞~";
}

- (UIColor *)an_noDataViewMessageColor {
    return [UIColor blackColor];
}

@end
