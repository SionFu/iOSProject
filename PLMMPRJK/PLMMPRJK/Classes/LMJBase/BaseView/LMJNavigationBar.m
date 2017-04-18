//
//  LMJNavigationBar.m
//  PLMMPRJK
//
//  Created by NJHu on 2017/3/31.
//  Copyright © 2017年 GoMePrjk. All rights reserved.
//

#import "LMJNavigationBar.h"


#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define kSmallTouchSize 44.0

#define kLeftMargin 0.0

#define kRightMargin 0.0

#define kDefaultNavBarHeight 64.0

#define kNavBarCenterY(H) ((self.height - kStatusBarHeight - H) * 0.5 + kStatusBarHeight)

#define kViewMargin 5.0

@implementation LMJNavigationBar


#pragma mark - system

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLMJNavigationBarUIOnce];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupLMJNavigationBarUIOnce];
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 是否显示底部条 */
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationIsHideBottomLine:)]) {
        
        self.bottomBlackLineView.hidden = [self.dataSource lmjNavigationIsHideBottomLine:self];
        
    }else
    {
        self.bottomBlackLineView.hidden = NO;
    }
    
    self.leftView.frame = CGRectMake(0, kStatusBarHeight, self.leftView.width, self.leftView.height);
    
    self.rightView.frame = CGRectMake(self.width - self.rightView.width, kStatusBarHeight, self.rightView.width, self.rightView.height);
    
    self.titleView.frame = CGRectMake(0, kStatusBarHeight, self.width - MAX(self.leftView.width, self.rightView.width) * 2 - kViewMargin * 2, self.titleView.height);
    self.titleView.centerX = self.width * 0.5;
    
}



#pragma mark - Setter
- (void)setTitleView:(UIView *)titleView
{
    [_titleView removeFromSuperview];
    [self addSubview:titleView];
    
    _titleView = titleView;
    
    if ([titleView isKindOfClass:[UILabel class]]) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleClick:)];
        
        [titleView addGestureRecognizer:tap];
    }
    
    [self layoutIfNeeded];
}




- (void)setTitle:(NSMutableAttributedString *)title
{
    /**头部标题*/
    UILabel *navTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    
    navTitleLabel.numberOfLines=0;//可能出现多行的标题
    [navTitleLabel setAttributedText:title];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.userInteractionEnabled = YES;
    navTitleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.titleView = navTitleLabel;
}


- (void)setLeftView:(UIView *)leftView
{
    [_leftView removeFromSuperview];
    
    [self addSubview:leftView];
    
    _leftView = leftView;
    
    
    if ([leftView isKindOfClass:[UIButton class]]) {
        
        UIButton *btn = (UIButton *)leftView;
        
        [btn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self layoutIfNeeded];
    
}




- (void)setLmjBackgroundColor:(UIColor *)lmjBackgroundColor
{
    _lmjBackgroundColor = lmjBackgroundColor;
    
    [self setBackgroundImage:[UIImage imageWithColor:lmjBackgroundColor]];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    [self setNavigationBack:backgroundImage];
    
}



- (void)setRightView:(UIView *)rightView
{
    [_rightView removeFromSuperview];
    
    [self addSubview:rightView];
    
    _rightView = rightView;
    
    if ([rightView isKindOfClass:[UIButton class]]) {
        
        UIButton *btn = (UIButton *)rightView;
        
        [btn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self layoutIfNeeded];
}



- (void)setDataSource:(id<LMJNavigationBarDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self setupDataSourceUI];
}


#pragma mark - getter

- (UIImageView *)bottomBlackLineView
{
    return [self findHairlineImageViewUnder:self];
}



#pragma mark - event

- (void)leftBtnClick:(UIButton *)btn
{
    if ([self.lmjDelegate respondsToSelector:@selector(leftButtonEvent:navigationBar:)]) {
        
        [self.lmjDelegate leftButtonEvent:btn navigationBar:self];
        
    }
    
}


- (void)rightBtnClick:(UIButton *)btn
{
    if ([self.lmjDelegate respondsToSelector:@selector(rightButtonEvent:navigationBar:)]) {
        
        [self.lmjDelegate rightButtonEvent:btn navigationBar:self];
        
    }
    
}


-(void)titleClick:(UIGestureRecognizer*)Tap
{
    UILabel *view = (UILabel *)Tap.view;
    if ([self.lmjDelegate respondsToSelector:@selector(titleClickEvent:navigationBar:)]) {
        
        [self.lmjDelegate titleClickEvent:view navigationBar:self];
        
    }
}



#pragma mark - custom

// 设置导航条的背景图片
-(void)setNavigationBack:(UIImage *)image
{
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.backgroundColor = [UIColor clearColor];
    [self setBackIndicatorTransitionMaskImage:image ];
    [self setShadowImage:image];
}

//找查到Nav底部的黑线
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0)
    {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}



- (void)setupDataSourceUI
{
    
    /** 导航条的高度 */
    
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationHeight:)]) {
        
        self.size = CGSizeMake(kScreenWidth, [self.dataSource lmjNavigationHeight:self]);
        
    }else
    {
        self.size = CGSizeMake(kScreenWidth, kDefaultNavBarHeight);
    }
    
    /** 是否显示底部黑线 */
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationIsHideBottomLine:)]) {
        
        self.bottomBlackLineView.hidden = [self.dataSource lmjNavigationIsHideBottomLine:self];
        
    }else
    {
        self.bottomBlackLineView.hidden = NO;
    }
    
    /** 背景图片 */
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarBackgroundImage:)]) {
        
        self.backgroundImage = [self.dataSource lmjNavigationBarBackgroundImage:self];
    }
    
    /** 背景色 */
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationBackgroundColor:)]) {
        
        self.lmjBackgroundColor = [self.dataSource lmjNavigationBackgroundColor:self];
    }
    
    
    /** 导航条中间的 View */
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarTitleView:)]) {
        
        self.titleView = [self.dataSource lmjNavigationBarTitleView:self];
        
        
        
    }else if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarTitle:)])
    {
        /**头部标题*/
        UILabel *navTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
        
        navTitleLabel.numberOfLines=0;//可能出现多行的标题
        [navTitleLabel setAttributedText:[self.dataSource lmjNavigationBarTitle:self]];
        navTitleLabel.textAlignment = NSTextAlignmentCenter;
        navTitleLabel.backgroundColor = [UIColor clearColor];
        navTitleLabel.userInteractionEnabled = YES;
        navTitleLabel.lineBreakMode = NSLineBreakByClipping;
        
        self.titleView = navTitleLabel;
    }
    
    
    /** 导航条的左边的 view */
    /** 导航条左边的按钮 */
    
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarLeftView:)]) {
        
        self.leftView = [self.dataSource lmjNavigationBarLeftView:self];
        
    }else if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarLeftButtonImage:navigationBar:)])
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSmallTouchSize, kSmallTouchSize)];
        
        btn.titleLabel.font = CHINESE_SYSTEM(16);
        
        UIImage *image = [self.dataSource lmjNavigationBarLeftButtonImage:btn navigationBar:self];
        
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        self.leftView = btn;
    }
    
    /** 导航条右边的 view */
    /** 导航条右边的按钮 */
    if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarRightView:)]) {
        
        self.rightView = [self.dataSource lmjNavigationBarRightView:self];
        
    }else if ([self.dataSource respondsToSelector:@selector(lmjNavigationBarRightButtonImage:navigationBar:)])
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSmallTouchSize, kSmallTouchSize)];
        
        btn.titleLabel.font = CHINESE_SYSTEM(16);
        
        UIImage *image = [self.dataSource lmjNavigationBarRightButtonImage:btn navigationBar:self];
        
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        self.rightView = btn;
    }
    
}


- (void)setupLMJNavigationBarUIOnce
{
    
    self.clipsToBounds = YES;
}





@end










