//
//  JEDrawerLayout.m
//  JEDrawerLayout
//
//  Created by Diana on 4/12/16.
//  Copyright © 2016 evideo. All rights reserved.
//

#define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_7_0

#import "JEDrawerLayout.h"
#import <Accelerate/Accelerate.h>



#pragma mark - Private Classes

#define ScreenSize [[UIScreen mainScreen] bounds].size
#define ScreenWidth MIN(ScreenSize.width, ScreenSize.height)

@interface RNCalloutItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSInteger itemIndex;
@property (nonatomic, strong) UIColor *originalBackgroundColor;

@end

@implementation RNCalloutItemView

- (instancetype)init {
    if (self = [super init]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = self.bounds.size.height/2;
    self.imageView.frame = CGRectMake(0, 0, inset, inset);
    self.imageView.center = CGPointMake(inset, inset);
}

- (void)setOriginalBackgroundColor:(UIColor *)originalBackgroundColor {
    _originalBackgroundColor = originalBackgroundColor;
    self.backgroundColor = originalBackgroundColor;
}

@end

#pragma mark - Public Classes

@interface JEDrawerLayout ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIImageView *blurView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *borderColors;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) NSMutableIndexSet *selectedIndices;

@end

static JEDrawerLayout *rn_frostedMenu;

@implementation JEDrawerLayout

+ (instancetype)visibleSidebar {
    return rn_frostedMenu;
}

- (instancetype)init {
    if (self = [super init]) {
        _isSingleSelect = NO;
        _contentView = [[UIScrollView alloc] init];
        _contentView.alwaysBounceHorizontal = NO;
        _contentView.alwaysBounceVertical = YES;
        _contentView.bounces = YES;
        _contentView.clipsToBounds = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.delegate = self;
        
        _width = ScreenWidth*3/4;
        _animationDuration = 0.25f;
        _itemSize = CGSizeMake(_width/2, _width/2);
        _itemViews = [NSMutableArray array];
        _tintColor = [UIColor colorWithWhite:0.2 alpha:0.73];
        _borderWidth = 2;
        _itemBackgroundColor = [UIColor lightGrayColor];
        
        
        [_images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
            RNCalloutItemView *view = [[RNCalloutItemView alloc] init];
            view.itemIndex = idx;
            view.clipsToBounds = YES;
            view.imageView.image = image;
            [_contentView addSubview:view];
            
            [_itemViews addObject:view];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //    [self.navigationItem setLeftBarButtonItem:nil];
    
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:self.tapGesture];
}

- (BOOL)shouldAutorotate {
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ([self isViewLoaded] && self.view.window != nil) {
        self.view.alpha = 0;
        self.view.alpha = 1;
        
        [self layoutSubviews];
    }
}

#pragma mark - Show

- (void)animateSpringWithView:(RNCalloutItemView *)view idx:(NSUInteger)idx initDelay:(CGFloat)initDelay {
#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED
    [UIView animateWithDuration:0.5
                          delay:(initDelay + idx*0.1f)
         usingSpringWithDamping:10
          initialSpringVelocity:50
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         view.layer.transform = CATransform3DIdentity;
                         view.alpha = 1;
                     }
                     completion:nil];
#endif
}

- (void)animateFauxBounceWithView:(RNCalloutItemView *)view idx:(NSUInteger)idx initDelay:(CGFloat)initDelay {
    [UIView animateWithDuration:0.2
                          delay:(initDelay + idx*0.1f)
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut
                     animations:^{
                         view.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
                         view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1 animations:^{
                             view.layer.transform = CATransform3DIdentity;
                         }];
                     }];
}

- (void)showInViewController:(UIViewController *)controller animated:(BOOL)animated {
    
    if (rn_frostedMenu != nil) {
        [rn_frostedMenu dismissAnimated:NO completion:nil];
    }
    
    rn_frostedMenu = self;
    
    [self rn_addToParentViewController:controller callingAppearanceMethods:YES];
    self.view.frame = controller.view.bounds;
    
    CGFloat parentWidth = self.view.bounds.size.width;
    
    CGRect contentFrame = self.view.bounds;
    contentFrame.origin.x = _showFromRight ? parentWidth : -_width;
    contentFrame.size.width = _width;
    self.contentView.frame = contentFrame;
    
    [self layoutItems];
    
    CGRect blurFrame = CGRectMake(_showFromRight ? self.view.bounds.size.width : 0, 0, 0, self.view.bounds.size.height);
    
    self.blurView.frame = blurFrame;
    self.blurView.contentMode = _showFromRight ? UIViewContentModeTopRight : UIViewContentModeTopLeft;
    self.blurView.clipsToBounds = YES;
    [self.view insertSubview:self.blurView belowSubview:self.contentView];
    
    contentFrame.origin.x = _showFromRight ? parentWidth - _width : 0;
    blurFrame.origin.x = contentFrame.origin.x;
    blurFrame.size.width = _width;
    
    void (^animations)() = ^{
        self.contentView.frame = contentFrame;
        self.blurView.frame = blurFrame;
    };
    
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:kNilOptions
                         animations:animations
                         completion:nil];
    }
    else{
        animations();
    }
    
    
}

- (void)showAnimated:(BOOL)animated {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    [self showInViewController:controller animated:animated];
}

- (void)show {
    [self showAnimated:YES];
}

#pragma mark - Dismiss

- (void)dismiss {
    [self dismissAnimated:YES completion:nil];
}

- (void)dismissAnimated:(BOOL)animated {
    [self dismissAnimated:animated completion:nil];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        if (completion) {
            completion(finished);
        }
    };
    
    
    
    
    if (animated) {
        CGFloat parentWidth = self.view.bounds.size.width;
        CGRect contentFrame = self.contentView.frame;
        contentFrame.origin.x = self.showFromRight ? parentWidth : -_width;
        
        CGRect blurFrame = self.blurView.frame;
        blurFrame.origin.x = self.showFromRight ? parentWidth : 0;
        blurFrame.size.width = 100;
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.contentView.frame = contentFrame;
                             self.blurView.frame = blurFrame;
                         }
                         completion:completionBlock];
    }
    else {
        completionBlock(YES);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self removeFromParentViewController];
    [self didMoveToParentViewController:self];
    
    
    [UIView animateWithDuration:1.f animations:^{
        CGRect frame = self.view.frame;
        //        frame.origin.x = -self.menuViewSize;
        frame.origin.x = self.view.bounds.size.width;
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    
    [self.view endEditing:YES];
    CGPoint location = [recognizer locationInView:self.view];
    if (! CGRectContainsPoint(self.contentView.frame, location)) {
        [self dismissAnimated:YES completion:nil];
    }
}

#pragma mark Keyboard Show And Hide

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect frame = self.view.frame;
    if (frame.origin.y >= 0.0) {
        frame.origin.y -= [self keyboardHeight:notification];
        self.view.frame = frame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect frame = self.view.frame;
    if (frame.origin.y < 0.0) {
        frame.origin.y += [self keyboardHeight:notification];
        self.view.frame = frame;
    }
}

- (float)keyboardHeight:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    float keyboardHeight = keyboardSize.height;
    return keyboardHeight;
}



- (void)layoutSubviews {
    CGFloat x = self.showFromRight ? self.parentViewController.view.bounds.size.width - _width : 0;
    self.contentView.frame = CGRectMake(x, 0, _width, self.parentViewController.view.bounds.size.height);
    self.blurView.frame = self.contentView.frame;
    
    [self layoutItems];
}

- (void)layoutItems {
    CGFloat leftPadding = (self.width - self.itemSize.width)/2;
    CGFloat topPadding = leftPadding;
    [self.itemViews enumerateObjectsUsingBlock:^(RNCalloutItemView *view, NSUInteger idx, BOOL *stop) {
        CGRect frame = CGRectMake(leftPadding, topPadding*idx + self.itemSize.height*idx + topPadding, self.itemSize.width, self.itemSize.height);
        view.frame = frame;
        view.layer.cornerRadius = frame.size.width/2.f;
    }];
    
    NSInteger items = [self.itemViews count];
    self.contentView.contentSize = CGSizeMake(0, items * (self.itemSize.height + leftPadding) + leftPadding);
}

- (NSInteger)indexOfTap:(CGPoint)location {
    __block NSUInteger index = NSNotFound;
    
    [self.itemViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(view.frame, location)) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    point.y = 0.f;
    point.x = 0.f;
    
    scrollView.contentOffset = point;
}

- (void)rn_addToParentViewController:(UIViewController *)parentViewController callingAppearanceMethods:(BOOL)callAppearanceMethods {
    
    if (callAppearanceMethods) [self beginAppearanceTransition:YES animated:NO];
    //    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];
    //    [self didMoveToParentViewController:self];
    if (callAppearanceMethods) [self endAppearanceTransition];
}


@end
