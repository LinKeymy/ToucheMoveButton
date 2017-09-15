//
//  TZJTouchMoveButton.h
//  TouZhiJia
//
//  Created by TouzhijiaAdmi on 14/09/2017.
//  Copyright © 2017 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_OPTIONS(NSUInteger, Stayment) {
    // 如果左和右兜停靠，请用或运算: StaymentLeft | StaymentRight
    StaymentLeft =     1 << 0,    // 停靠左侧
    StaymentRight =  1 << 1,    // 停靠右侧
};


@interface TZJTouchMoveButton : UIButton

//悬浮图片停留的方式(默认为StaymentRight)
@property(nonatomic, assign) Stayment stayment;

// 悬浮图片左右边距
@property (nonatomic, assign) CGFloat stayEdgeDistance;

//悬浮图片停靠的动画事件
@property (nonatomic, assign) CGFloat stayAnimateTime;

// 设置简单的轻点 block事件
- (void)setTapActionWithBlock:(void (^)(void))block;

// 根据 imageName 改变FloatView的image
- (void)setImageWithName:(NSString *)imageName;

// 当滚动的时候悬浮图片居中在屏幕边缘
- (void)moveTohalfInScreenWhenScrolling;

// 设置当前浮动图片的透明度
- (void)setCurrentAlpha:(CGFloat)stayAlpha;

@end
