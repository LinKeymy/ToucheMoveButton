//
//  TZJTouchMoveButton.m
//  TouZhiJia
//
//  Created by TouzhijiaAdmi on 14/09/2017.
//  Copyright © 2017 Carl. All rights reserved.
//

#import "TZJTouchMoveButton.h"
#import <objc/runtime.h>



#define k_NavBarBottom 64
#define k_TabBarHeight 49
#define k_ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define k_ScreenHeight [UIScreen mainScreen].bounds.size.height

static char kActionHandlerTapBlockKey;

@implementation TZJTouchMoveButton {
    BOOL isHalfInScreen;
    BOOL isMoved;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.stayEdgeDistance = 5;
        self.stayAnimateTime = 0.3;
        [self initStayLocation];
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1;
    // 获取手指当前的点
    UITouch * touch = [touches anyObject];
    CGPoint  curPoint = [touch locationInView:self];
    CGPoint prePoint = [touch previousLocationInView:self];
    
    CGFloat deltaX = curPoint.x - prePoint.x;
    CGFloat deltaY = curPoint.y - prePoint.y;
    
    isMoved = fabs(deltaX) > 1 || fabs(deltaY) > 1 || isMoved;
    CGRect frame = self.frame;
    frame.origin.x += deltaX;
    frame.origin.y += deltaY;
    self.frame = frame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!isMoved) { [super touchesEnded:touches withEvent:event]; }
    isMoved = NO;
    [self moveWithStayment:_stayment];
}

#pragma mark - 设置浮动图片的初始位置
- (void)initStayLocation {
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat initX = k_ScreenWidth - self.stayEdgeDistance - stayWidth;
    CGFloat initY = (k_ScreenHeight - k_NavBarBottom - k_TabBarHeight) * (2.0 / 3.0) + k_NavBarBottom;
    frame.origin.x = initX;
    frame.origin.y = initY;
    self.frame = frame;
    isHalfInScreen = NO;
}

#pragma mark - 根据 _stayment 来移动悬浮图片
- (void)moveStay {
    [self moveWithStayment:_stayment];
}

- (void)moveWithStayment:(Stayment)stay {
    if (stay == 0) {
        return;
    }
    if ((stay & StaymentLeft) && (stay & StaymentRight)) {
        [self moveToLeft:[self shouldMoveToLeft]];
        return;
    }
    [self moveToLeft:(stay & StaymentLeft)];
}

#pragma mark - 移动到屏幕边缘
- (void)moveToLeft:(BOOL)isLeft {
    CGRect frame = self.frame;
    CGFloat destinationX;
    if (isLeft) {
        destinationX = self.stayEdgeDistance;
    }
    else {
        CGFloat stayWidth = frame.size.width;
        destinationX = k_ScreenWidth - self.stayEdgeDistance - stayWidth;
    }
    frame.origin.x = destinationX;
    frame.origin.y = [self moveSafeLocationY];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_stayAnimateTime animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
    }];
    isHalfInScreen = NO;
}

// 设置悬浮图片不高于屏幕顶端，不低于屏幕底端
- (CGFloat)moveSafeLocationY {
    CGRect frame = self.frame;
    CGFloat stayHeight = frame.size.height;
    // 当前view的y值
    CGFloat curY = self.frame.origin.y;
    CGFloat destinationY = frame.origin.y;
    // 悬浮图片的最顶端Y值
    CGFloat stayMostTopY = k_NavBarBottom + _stayEdgeDistance;
    if (curY <= stayMostTopY) {
        destinationY = stayMostTopY;
    }
    // 悬浮图片的底端Y值
    CGFloat stayMostBottomY = k_ScreenHeight - k_TabBarHeight - _stayEdgeDistance - stayHeight;
    if (curY >= stayMostBottomY) {
        destinationY = stayMostBottomY;
    }
    return destinationY;
}

#pragma mark -  判断当前view是否在父界面的左边
- (bool)shouldMoveToLeft {
    CGFloat middleX = [self superview].bounds.size.width / 2.0;
    CGFloat curX = self.frame.origin.x + self.bounds.size.width/2;
    NSLog(@"middlex:%lf, curX:%lf",middleX,curX);
    return curX <= middleX;
}

#pragma mark - 当滚动的时候悬浮图片居中在屏幕边缘
- (void)moveTohalfInScreenWhenScrolling {
    bool isLeft = [self shouldMoveToLeft];
    [self moveStayToMiddleInScreenBorder:isLeft];
    isHalfInScreen = YES;
}

// 悬浮图片居中在屏幕边缘
- (void)moveStayToMiddleInScreenBorder:(BOOL)isLeft {
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat destinationX;
    if (isLeft == YES) {
        destinationX = - stayWidth/2;
    } else {
        destinationX = k_ScreenWidth - stayWidth + stayWidth/2;
    }
    frame.origin.x = destinationX;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
    }];
}

#pragma mark - 设置当前浮动图片的透明度
- (void)setCurrentAlpha:(CGFloat)stayAlpha {
    if (stayAlpha <= 0) { stayAlpha = 1;}
    self.alpha = stayAlpha;
}

#pragma mark -  设置简单的轻点 block事件
- (void)setTapActionWithBlock:(void (^)(void))block {
    [self addTarget:self action:@selector(handleTapAction) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(self, &kActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)handleTapAction {
    void(^action)(void) = objc_getAssociatedObject(self, &kActionHandlerTapBlockKey);
    if (action) {
        self.alpha = 1;
        if (isHalfInScreen == NO) {
            action();
        }
        else {
            [self moveWithStayment:_stayment];
        }
    }
}

- (void)setImageWithName:(NSString *)imageName {
    [self setImage:[UIImage imageNamed:imageName]];
}

- (void)setImage:(UIImage *)image {
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
    [self updateFrameNewImage:image];
}

- (void)updateFrameNewImage:(UIImage *)image {
    CGFloat h = image.size.height;
    CGFloat w = image.size.width;
    CGFloat x = k_ScreenWidth - self.stayEdgeDistance - w;
    self.frame = CGRectMake(x, self.frame.origin.y, w, h);
}

@end
