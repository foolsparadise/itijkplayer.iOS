/*
 * Copyright (C) 2015 Gdier
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Created by github.com/foolsparadise on 21/10/2017

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"

@protocol IJKMediaPlayback;

@interface LTSlider:UISlider
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;
@end

@interface IJKDemoMediaControl : UIView


// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, //横向移动
    PanDirectionVerticalMoved    //纵向移动
};

- (void)refreshMediaControl;
- (void)beginDragMediaSlider;
- (void)endDragMediaSlider;
- (void)continueDragMediaSlider;

@property(nonatomic,weak) id<IJKMediaPlayback> delegatePlayer;

/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection     panDirection;
/** 退出按钮 */
@property (strong, nonatomic)  UIButton       *backBtn;
/** 视频名 */
@property (strong, nonatomic)  UILabel        *titleLabel;
/** 是否使用系统播放器 */
@property (nonatomic,strong)   UISwitch       *swithView;
/** 开始播放按钮 */
@property (strong, nonatomic)  UIButton       *playBtn;
/** 当前播放时长label */
@property (strong, nonatomic)  UILabel        *currentTimeLabel;
/** 视频总时长label */
@property (strong, nonatomic)  UILabel        *totalTimeLabel;
/** 缓冲进度条 */
@property (strong, nonatomic)  UIProgressView *progressView;
/** 滑杆 */
@property (strong, nonatomic)  ASValueTrackingSlider       *videoSlider;
/** 全屏按钮 */
@property (strong, nonatomic)  UIButton       *fullScreenBtn;

/** 分享按钮 */
@property (strong, nonatomic)  UIButton       *shareBtn;

/** 顶部导航栏 */
@property (strong, nonatomic)  UIImageView     *topView;

/** 底部导航栏 */
@property (strong, nonatomic)  UIImageView     *bottomView;

@property (strong, nonatomic)  UIButton       *lockBtn;
/** 音量进度 */
@property (nonatomic,strong) UIProgressView   *volumeProgress;

/** 系统菊花 */
@property (nonatomic,strong)UIActivityIndicatorView *activity;
/** 底部toolbar */
@property (nonatomic,strong)UIToolbar *toolbar;

@end
