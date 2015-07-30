//
//  UIScrollView+NBPullToRefresh.h
//  NBPullToRefresh
//
//  Created by NOVA8OSSA on 15/7/30.
//  Copyright (c) 2015年 NB. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NBPullToRefreshViewHeight   60.f
#define NBInfiniteRefreshViewHeight 60.f

@interface NBPullToRefreshView : UIView

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@interface NBInfiniteRefreshView : UIView

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@interface UIScrollView (NBPullToRefresh)

@property (nonatomic, strong, readonly) NBPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong, readonly) NBInfiniteRefreshView *infiniteRefreshView;

- (void)addPullToRefresh:(void (^)(void))pullAction infiniteRefresh:(void (^)(void))infiniteAction;
- (void)stopNBAnimating;

@end
