//
//  ViewController.m
//  NBPullToRefreshDemo
//
//  Created by NOVA8OSSA on 15/7/30.
//  Copyright (c) 2015年 NB. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+NBPullToRefresh.h"

@interface ViewController ()<UITableViewDataSource> {
    
    UITableView *listView;
    NSMutableArray *list;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    list = [NSMutableArray array];
    
    listView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    listView.dataSource = self;
    listView.tableFooterView = [UIView new];
    [self.view addSubview:listView];
    
    __weak typeof(self) weakSelf = self;
    [listView addPullToRefresh:^{
        
        [weakSelf loadData:NO];
    } infiniteRefresh:^{
        
        [weakSelf loadData:YES];
    }];
    listView.pullToRefreshView.imageView.image = [UIImage imageNamed:@"arrow"];
    listView.infiniteRefreshView.label.text = @"load more...";
}

- (void)loadData:(BOOL)isLoadMore {
    
    if (!isLoadMore) {
        [list removeAllObjects];
    }
    
    [self performSelectorInBackground:@selector(generateData:) withObject:@(10)];
}

- (void)generateData:(NSNumber *)numOfData {
    
    [NSThread sleepForTimeInterval:1.];
    for (NSInteger i = 0; i < numOfData.integerValue; i++) {
        
        NSString *numString = [NSString stringWithFormat:@"%ld", (long)arc4random_uniform(100)];
        [list addObject:numString];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self->listView stopNBAnimating];
        [self->listView reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    if (indexPath.row < list.count) {
        cell.textLabel.text = list[indexPath.row];
    }
    
    return cell;
}

@end
