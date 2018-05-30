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

#import "IJKDemoMediaControl.h"
#import <AVFoundation/AVFoundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>



@implementation LTSlider
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    //y轴方向改变手势范围
    rect.origin.y = rect.origin.y -10;
    rect.size.height = rect.size.height + 20;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    return result;
}

@end


static NSString * formatTimeInterval(CGFloat seconds)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    if (h > 0) {
        return [NSString stringWithFormat:@"%ld:%0.2ld:%0.2ld", (long)h,(long)m,(long)s];
    }
    return [NSString stringWithFormat:@"%0.2ld:%0.2ld",(long)m,(long)s];
}



@implementation IJKDemoMediaControl
{
    BOOL _isMediaSliderBeingDragged;
}

- (void)beginDragMediaSlider
{
    _isMediaSliderBeingDragged = YES;
}

- (void)endDragMediaSlider
{
    _isMediaSliderBeingDragged = NO;
}

- (void)continueDragMediaSlider
{
    [self refreshMediaControl];
}

/**
 *  刷新控件，包括时间 进度度
 */
- (void)refreshMediaControl
{
    float Percentage = self.delegatePlayer.playableDuration / self.delegatePlayer.duration;
    self.progressView.progress = Percentage;
    // duration
    NSTimeInterval duration = self.delegatePlayer.duration;
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        self.videoSlider.maximumValue = duration;
        self.totalTimeLabel.text = formatTimeInterval(intDuration);
    } else {
        self.totalTimeLabel.text = @"--:--";
        self.videoSlider.maximumValue = 1.0f;
    }
    
    
    // position
    NSTimeInterval position;
    if (_isMediaSliderBeingDragged) {
        position = self.videoSlider.value;
    } else {
        position = self.delegatePlayer.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    if (intDuration > 0) {
        self.videoSlider.value = position;
    } else {
        self.videoSlider.value = 0.0f;
    }
    self.currentTimeLabel.text = formatTimeInterval(intPosition);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    if (self.alpha) {
        [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
    }
}




-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self.topView addSubview:self.titleLabel];
    [self.topView addSubview:self.backBtn];
    [self.topView addSubview:self.swithView];

    
    [self.bottomView addSubview:self.toolbar];
    [self.bottomView addSubview:self.currentTimeLabel];
    [self.bottomView addSubview:self.totalTimeLabel];
    [self.bottomView addSubview:self.videoSlider];
    [self.bottomView addSubview:self.progressView];
    
    [self.topView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.height.equalTo(@(self.topView.image.size.height));
    }];
    
    [self.bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottom).offset(@10);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.height.equalTo(@(self.bottomView.image.size.height));
    }];
    
    UIImage *image = [UIImage imageNamed:@"ico_return_nor"];
    [self.backBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(@15);
        make.centerY.equalTo(self.topView.centerY);
        make.size.equalTo(CGSizeMake(image.size.width, image.size.height));
    }];
    [self.swithView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(@-15);
        make.centerY.equalTo(self.topView.centerY);
        make.size.equalTo(CGSizeMake(image.size.width, image.size.height));
    }];
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.top).offset(@0);
        make.left.equalTo(self.backBtn.right).offset(@15);
        make.right.equalTo(self.swithView.right).offset(-image.size.width-15);
        make.bottom.equalTo(self.topView.bottom).offset(@0);
    }];
    
    [self.toolbar makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.left);
        make.right.equalTo(self.bottomView.right);
        make.bottom.equalTo(self.bottomView.bottom);
        make.height.equalTo(@80);
    }];

    [self.currentTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.left).offset(@10);
        make.bottom.equalTo(self.toolbar.top);
    }];
    
    [self.totalTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView.right).offset(@-10);
        make.bottom.equalTo(self.toolbar.top);
    }];
    
    [self.videoSlider makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.right).offset(@10);
        make.right.equalTo(self.totalTimeLabel.left).offset(@-10);
        make.centerY.equalTo(self.totalTimeLabel.centerY);
        make.height.equalTo(@10);
    }];
    
    [self.progressView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.right).offset(@10);
        make.right.equalTo(self.totalTimeLabel.left).offset(@-10);
        make.centerY.equalTo(self.totalTimeLabel.centerY).offset(@0.5);
        make.height.equalTo(@10);
    }];
    
    [self.bottomView bringSubviewToFront:self.videoSlider];
}


#pragma mark - Lazyload
- (UIImageView *)topView
{
    if (!_topView) {
        _topView = [UIImageView new];
        [_topView setImage:[UIImage imageNamed:@"bg_playfull_top"]];
        _topView.userInteractionEnabled = YES;
    }
    return _topView;
}

- (UIImageView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [UIImageView new];
        [_bottomView setImage:[UIImage imageNamed:@"bg_playfull_bottom"]];
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"ico_return_nor"] forState:UIControlStateNormal];
         _backBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backBtn;
}
- (UISwitch *)swithView
{
    if (!_swithView) {
        _swithView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        _swithView.onTintColor = RGBCOLOR(235, 101, 61);
        //[_swithView addTarget:self action:@selector(swithViewClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _swithView;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,100, 100)];
        _titleLabel.text = @"";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return _titleLabel;
}
- (UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"ico_play_share_nor"];
        [_shareBtn setImage:image forState:UIControlStateNormal];
        _shareBtn.frame = CGRectMake(0, 0,image.size.width, image.size.height);
        
    }
    return _shareBtn;
}


- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         UIImage *image = [UIImage imageNamed:@"ico_play_play_play_nor"];
        [_playBtn setImage:[UIImage imageNamed:@"ico_play_play_play_nor"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"ico_play_play_break_nor"] forState:UIControlStateSelected];
        _playBtn.frame = CGRectMake(0, 0,image.size.width, image.size.height);
    }
    return _playBtn;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         UIImage *image = [UIImage imageNamed:@"ico_play_fullscreen_nor"];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ico_play_fullscreen_nor"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ico_play_smallscreen_nor"] forState:UIControlStateSelected];
         _fullScreenBtn.frame = CGRectMake(0, 0,image.size.width, image.size.height);
    }
    return _fullScreenBtn;
}


- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
       _progressView.progressViewStyle = UIProgressViewStyleBar;
        _progressView.progressTintColor    = [UIColor whiteColor];
        _progressView.trackTintColor       = [UIColor clearColor];
        _progressView.transform = CGAffineTransformMakeScale(1,0.18f);
    }
    return _progressView;
}
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
- (ASValueTrackingSlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider = [[ASValueTrackingSlider alloc]init];
        _videoSlider.autoAdjustTrackColor = NO;
        [_videoSlider setThumbImage:[UIImage imageNamed:@"ico_play_process"] forState:UIControlStateNormal];
        _videoSlider.minimumTrackTintColor = RGBCOLOR(16 ,125 ,230);
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];

    }
    return _videoSlider;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10,60, 30)];
       _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.font = [UIFont systemFontOfSize:15];

    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10,60, 30)];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return _totalTimeLabel;
}

- (UIToolbar *)toolbar
{
    if (!_toolbar) {
        
        UIToolbar *btoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
        btoolbar.userInteractionEnabled = YES;
        [btoolbar setBarStyle:UIBarStyleBlackTranslucent];
        [btoolbar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [btoolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
        
        //占位符
        UIBarButtonItem *itemPlace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *shareitem = [[UIBarButtonItem alloc] initWithCustomView:self.shareBtn];
        UIBarButtonItem *playitem = [[UIBarButtonItem alloc] initWithCustomView:self.playBtn];
        UIBarButtonItem *fullitem = [[UIBarButtonItem alloc] initWithCustomView:self.fullScreenBtn];
        
        NSArray *items = @[shareitem,itemPlace,playitem,itemPlace,fullitem];
        btoolbar.items = items;

        _toolbar = btoolbar;
    }
    return _toolbar;
}


@end
