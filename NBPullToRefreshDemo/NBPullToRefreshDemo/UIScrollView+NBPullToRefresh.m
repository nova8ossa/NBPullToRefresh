//
//  UIScrollView+NBPullToRefresh.m
//  NBPullToRefreshDemo
//
//  Created by NOVA8OSSA on 15/7/30.
//  Copyright (c) 2015年 NB. All rights reserved.
//

#import <objc/runtime.h>
#import "UIScrollView+NBPullToRefresh.h"

static char NBPullToRefreshBlockKey;
static char NBInfiniteRefreshBLockKey;
static char NBPullToRefreshViewKey;
static char NBInfiniteRefreshViewKey;

#pragma mark - NBPullToRefreshView

@implementation NBPullToRefreshView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicatorView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setIsLoading:(BOOL)isLoading {
    
    _isLoading = isLoading;
    
    if (isLoading) {
        _imageView.hidden = YES;
        _indicatorView.hidden = NO;
        [_indicatorView startAnimating];
    }else{
        _imageView.hidden = NO;
        _indicatorView.hidden = YES;
        [_indicatorView stopAnimating];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _indicatorView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    [_imageView sizeToFit];
    _imageView.center = _indicatorView.center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    UITableView *tableView = (UITableView *)self.superview;
    if (tableView.superview == nil && newSuperview == nil) {
        [tableView removeObserver:self forKeyPath:@"contentOffset" context:NULL];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    if (scrollView == object && scrollView.window && [keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (point.y <= -NBPullToRefreshViewHeight) {
            
            [UIView animateWithDuration:0.3 animations:^{
                _imageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            
            if (!scrollView.isTracking && !_isLoading) {
                self.isLoading = YES;
                
                scrollView.contentInset = UIEdgeInsetsMake(fabs(point.y), 0, 0, 0);
                [UIView animateWithDuration:0.3 animations:^{
                    scrollView.contentInset = UIEdgeInsetsMake(NBPullToRefreshViewHeight, 0, 0, 0);
                } completion:^(BOOL finished) {
                    
                    void (^pullToRefreshBlock)(void) = objc_getAssociatedObject(scrollView, &NBPullToRefreshBlockKey);
                    pullToRefreshBlock();
                }];
            }
        }else {
            [UIView animateWithDuration:0.3 animations:^{
                _imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

@end

#pragma mark - NBInfiniteRefreshView

@interface NBInfiniteRefreshView ()

- (void)resetInfiniteRefreshView;

@end

@implementation NBInfiniteRefreshView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicatorView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_label];
    }
    return self;
}

- (void)setIsLoading:(BOOL)isLoading {
    
    _isLoading = isLoading;
    if (isLoading) {
        _label.hidden = YES;
        [_indicatorView startAnimating];
    }else{
        _label.hidden = NO;
        [_indicatorView stopAnimating];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _indicatorView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    [_label sizeToFit];
    _label.center = _indicatorView.center;
}

- (void)resetInfiniteRefreshView {
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGRect rect = CGRectMake(0, contentHeight, scrollView.bounds.size.width, NBInfiniteRefreshViewHeight);
    self.frame = rect;
    self.hidden = (contentHeight == 0) || (contentHeight < scrollView.bounds.size.height);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    UITableView *tableView = (UITableView *)self.superview;
    if (tableView.superview == nil && newSuperview == nil) {
        [tableView removeObserver:self forKeyPath:@"contentOffset" context:NULL];
        [tableView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    if (scrollView == object && scrollView.window) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            
            CGPoint point = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
            CGSize size = scrollView.contentSize;
            if (point.y > 0 && size.height) {
                
                CGFloat fix = point.y;
                if (size.height > scrollView.bounds.size.height) {
                    fix = point.y - (size.height - scrollView.bounds.size.height);
                }
                
                if (!scrollView.isTracking && !_isLoading && fix >= NBInfiniteRefreshViewHeight && !self.hidden) {
                    self.isLoading = YES;
                    
                    void (^infiniteRefreshBLock)(void) = objc_getAssociatedObject(scrollView, &NBInfiniteRefreshBLockKey);
                    if (size.height > scrollView.bounds.size.height) {
                        
                        scrollView.contentInset = UIEdgeInsetsMake(0, 0, fix, 0);
                        [UIView animateWithDuration:0.3 animations:^{
                            scrollView.contentInset = UIEdgeInsetsMake(0, 0, NBInfiniteRefreshViewHeight, 0);
                        } completion:^(BOOL finished) {
                            infiniteRefreshBLock();
                        }];
                    }else{
                        infiniteRefreshBLock();
                    }
                }
            }
        }else if ([keyPath isEqualToString:@"contentSize"]) {
            
            [self resetInfiniteRefreshView];
        }
    }
}

@end


#pragma mark - UIScrollView+NBPullToRefresh

@interface UIScrollView ()

@property (nonatomic, copy) void (^pullToRefreshBlock)(void);
@property (nonatomic, copy) void (^infiniteRefreshBlock)(void);

@end

@implementation UIScrollView (NBPullToRefresh)

- (void)triggerPullToRefresh {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentOffset = CGPointMake(self.contentOffset.x, -NBPullToRefreshViewHeight);
    });
}

- (void)stopNBAnimating {
    
    if (self.pullToRefreshView.isLoading) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentInset = UIEdgeInsetsZero;
        } completion:^(BOOL finished) {
            self.pullToRefreshView.isLoading = NO;
        }];
    }
    
    if (self.infiniteRefreshView.isLoading) {
        
        CGFloat fix = self.contentSize.height - self.bounds.size.height;
        if (fix > 0) {
            if (fix > self.contentOffset.y) {
                self.contentInset = UIEdgeInsetsZero;
                self.infiniteRefreshView.isLoading = NO;
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.contentOffset = CGPointMake(0., fix+NBInfiniteRefreshViewHeight);
                } completion:^(BOOL finished) {
                    self.contentInset = UIEdgeInsetsZero;
                    self.infiniteRefreshView.isLoading = NO;
                }];
            }
        }else{
            self.infiniteRefreshView.isLoading = NO;
        }
    }
    
    [self.infiniteRefreshView resetInfiniteRefreshView];
}

- (void)addPullToRefresh:(void (^)(void))pullAction infiniteRefresh:(void (^)(void))infiniteAction {
    
    self.pullToRefreshBlock = pullAction;
    self.infiniteRefreshBlock = infiniteAction;
    
    if (pullAction && !self.pullToRefreshView) {
        CGRect rect = CGRectMake(0, -NBPullToRefreshViewHeight, self.bounds.size.width, NBPullToRefreshViewHeight);
        NBPullToRefreshView *refreshView = [[NBPullToRefreshView alloc] initWithFrame:rect];
        refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.pullToRefreshView = refreshView;
        [self insertSubview:self.pullToRefreshView atIndex:0];
        
        [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    if (infiniteAction && !self.infiniteRefreshView) {
        CGRect rect = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, NBInfiniteRefreshViewHeight);
        NBInfiniteRefreshView *infiniteView = [[NBInfiniteRefreshView alloc] initWithFrame:rect];
        infiniteView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.infiniteRefreshView = infiniteView;
        [self insertSubview:self.infiniteRefreshView atIndex:0];
        [self.infiniteRefreshView resetInfiniteRefreshView];
        
        [self addObserver:self.infiniteRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self.infiniteRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)setPullToRefreshView:(NBPullToRefreshView *)pullToRefreshView {
    
    objc_setAssociatedObject(self, &NBPullToRefreshViewKey, pullToRefreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NBPullToRefreshView *)pullToRefreshView {
    
    return objc_getAssociatedObject(self, &NBPullToRefreshViewKey);
}

- (void)setInfiniteRefreshView:(NBInfiniteRefreshView *)infiniteRefreshView {
    
    objc_setAssociatedObject(self, &NBInfiniteRefreshViewKey, infiniteRefreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NBInfiniteRefreshView *)infiniteRefreshView {
    
    return objc_getAssociatedObject(self, &NBInfiniteRefreshViewKey);
}

- (void)setPullToRefreshBlock:(void (^)(void))pullToRefreshBlock {
    
    objc_setAssociatedObject(self, &NBPullToRefreshBlockKey, pullToRefreshBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))pullToRefreshBlock {
    
    return objc_getAssociatedObject(self, &NBPullToRefreshBlockKey);
}

- (void)setInfiniteRefreshBlock:(void (^)(void))infiniteRefreshBlock {
    
    objc_setAssociatedObject(self, &NBInfiniteRefreshBLockKey, infiniteRefreshBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))infiniteRefreshBlock {
    
    return objc_getAssociatedObject(self, &NBInfiniteRefreshBLockKey);
}

@end
