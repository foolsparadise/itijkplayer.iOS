/*
 * Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
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

#import "IJKMoviePlayerViewController.h"
#import "IJKDemoHistory.h"
#import "IJKDemoMediaControl.h"

//i added
#import "IJKDemoFileDownload.h"


@implementation IJKVideoViewController

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void(^)())completion {
    IJKDemoHistoryItem *historyItem = [[IJKDemoHistoryItem alloc] init];
    
    historyItem.title = title;
    historyItem.url = url;
    [[IJKDemoHistory instance] add:historyItem];
    
    [viewController presentViewController:[[IJKVideoViewController alloc] initWithURL:url] animated:YES completion:completion];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}
- (id)initWithContentURLString:(NSString *)aUrl
{
    self = [super init];
    if (self) {
        NSURL *url;
        if (aUrl == nil) {
            aUrl = @"";
        }
        if ([aUrl rangeOfString:@"/"].location == 0) {
            //本地
            url = [NSURL fileURLWithPath:aUrl];
        }
        else {
            url = [NSURL URLWithString:aUrl];
        }

        self.url = url;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.playControll refreshMediaControl];
}
/**
 URL file type check
 
 @param videoURL URL
 @return default mov use MPMoviePlayerController, others use IJKFFMoviePlayerController
 */
- (NSString *)contentTypeOfVideo:(NSURL *)videoURL
{
    // system DCIM 系统相册
    //file:///var/mobile/Media/DCIM/101APPLE/IMG_xxxx.mp4
    // sandbox 沙盒
    //file:///var/mobile/Containers/Data/Application/xxxx-xxx-xxx-xxx-xxx-xxxx/Documents/xxxx.mov
    
    if([videoURL.absoluteString containsString:@"/var/mobile/Media/DCIM"]) { // system DCIM 系统相册
        return @"mov";
    }
    else if ([videoURL.absoluteString containsString:@"/var/mobile/Containers/Data/Applicatio"]) { // sandbox 沙盒文件
        NSData *data = [NSData dataWithContentsOfURL:videoURL];
        uint8_t c;
        [data getBytes:&c length:1];
        switch (c) {
            // file type check, can add by yourself, 遇到问题视频可以自已加处理
            case 0x52: { NSLog(@"avi"); return @"avi"; }
	    case 0xff: { NSLog(@"avi"); return @"avi"; }
            // case 0x6D: { NSLog(@"mov"); return @"mov"; }
            case 0x00: {
                if ([data length] < 12)
                {
                    return @"avi";
                }
                if (data.length >= 12) {
                    //....ftyp此处为文件类型头
                    NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding].lowercaseString;
                    if ([testString isEqualToString:@"ftypqt"] ||
                        [testString isEqualToString:@"ftypisom"] ||
                        [testString isEqualToString:@"ftyp3gp"] ||
                        [testString isEqualToString:@"ftypmmp4"] ||
                        [testString isEqualToString:@"ftyp3g2a"] ||
                        [testString isEqualToString:@"ftypm4a"] ||
                        [testString isEqualToString:@"ftypm4v"] ||
                        [testString isEqualToString:@"ftypmp4"] ||
                        [testString isEqualToString:@"ftypmp42"] ||
                        [testString isEqualToString:@"ftypf4v"]
                        ) {
                        return @"mov";
                    }
                }
            }
        }
        return @"avi";
    }
    else {}
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *datPath = [documentsDirectory stringByAppendingPathComponent:@"temp.dat"];
    
    
    /*
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t queueGroup = dispatch_group_create();
    dispatch_group_async(queueGroup, aQueue, ^{
        IJKDemoFileDownload *ijL = [[IJKDemoFileDownload alloc] init];
        [ijL IJKDemoFileDownloadWithURL:videoURL];
    });
    dispatch_group_wait(queueGroup, DISPATCH_TIME_FOREVER);
    
    NSInteger count = 0;
    while ([NSData dataWithContentsOfFile:datPath].length<32) {
        count++;
        if(count>10)
            return @"avi";
        usleep(10);
    }
     */
    //2018.5.优化，注释掉代码块并使用下面代码块
    dispatch_semaphore_t semaphore_IJKDemoFileDownload = dispatch_semaphore_create(0);
    dispatch_queue_t queue_IJKDemoFileDownload  = dispatch_queue_create("semaphore_IJKDemoFileDownload", NULL);
    dispatch_async(queue_IJKDemoFileDownload , ^(void) {
        [IJKDemoFileDownload IJKDemoFileDownloadWithURL:videoURL.absoluteString WithBlock:^(bool isOK) {
            dispatch_semaphore_signal(semaphore_IJKDemoFileDownload);
        }];
    });
    dispatch_semaphore_wait(semaphore_IJKDemoFileDownload,DISPATCH_TIME_FOREVER);
    
    
    NSData *data = [NSData dataWithContentsOfFile:datPath];
    if([NSData dataWithContentsOfFile:datPath].length<64) return @"avi";
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        // file type check, can add by yourself, 遇到问题视频可以自已加处理
        case 0x52: { NSLog(@"avi"); return @"avi"; }
	case 0xff: { NSLog(@"avi"); return @"avi"; }
        // case 0x6D: { NSLog(@"mov"); return @"mov"; }
        case 0x00: {
                if ([data length] < 12)
                {
                    return @"avi";
                }
                if (data.length >= 12) {
                    //....ftyp此处为文件类型头
                    NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding].lowercaseString;
                    if ([testString isEqualToString:@"ftypqt"] ||
                        [testString isEqualToString:@"ftypisom"] ||
                        [testString isEqualToString:@"ftyp3gp"] ||
                        [testString isEqualToString:@"ftypmmp4"] ||
                        [testString isEqualToString:@"ftyp3g2a"] ||
                        [testString isEqualToString:@"ftypm4a"] ||
                        [testString isEqualToString:@"ftypm4v"] ||
                        [testString isEqualToString:@"ftypmp4"] ||
                        [testString isEqualToString:@"ftypmp42"] ||
                        [testString isEqualToString:@"ftypf4v"]
                        ) {
                        return @"mov";
                    }
                }
            }
            
    }
    
    return @"avi";
}
#define EXPECTED_IJKPLAYER_VERSION (1 << 16) & 0xFF) |
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif


    self.playControll = [[IJKDemoMediaControl alloc] initWithFrame:self.view.bounds];
    [self.playControll.backBtn addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.playControll.fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playControll.playBtn addTarget:self action:@selector(onClickPlay:) forControlEvents:UIControlEventTouchUpInside];//onClickPlay
    [self.playControll.videoSlider addTarget:self action:@selector(didSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.playControll.videoSlider addTarget:self action:@selector(didSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.playControll.videoSlider addTarget:self action:@selector(didSliderTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [self.playControll.videoSlider addTarget:self action:@selector(didSliderTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.playControll.videoSlider addTarget:self action:@selector(didSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    tap.delegate = self;
    [self.playControll.videoSlider addGestureRecognizer:tap];
    IJKDemoHistoryItem *item = [[[IJKDemoHistory instance] list] firstObject];
    if (item) {
        self.playControll.titleLabel.text = item.title;
    }
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];

    //    if (!_useAVPlayer) {
    //        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    //        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    //    }else
    //    {
    //        IJKMPMoviePlayerController *vc = [[IJKMPMoviePlayerController alloc] initWithContentURL:self.url];
    //        vc.controlStyle = MPMovieControlStyleNone;
    //        self.player = vc;
    //    }
    
    // file type check i added 2017-10
    if ([[self contentTypeOfVideo:self.url] containsString:@"mov"]) {
        // if mov , default use MPMoviePlayerController
        IJKMPMoviePlayerController *vc = [[IJKMPMoviePlayerController alloc] initWithContentURL:self.url];
        vc.controlStyle = MPMovieControlStyleNone;
        self.player = vc;
        
    }
    else {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
        
    }
   
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    [self.player setPauseInBackground:YES];

    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    [self.view addSubview:self.playControll];

    self.playControll.delegatePlayer  = self.player;
    self.playControll.playBtn.selected = YES;

    [self readyForHidden];
    
    
    // 添加平移手势，用来控制音量、亮度、快进快退
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    [self.view addGestureRecognizer:pan];
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//    [self.view addGestureRecognizer:tap];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        //
        self.playControll.fullScreenBtn.selected = YES;
    }
    
    else if (orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        //
        self.playControll.fullScreenBtn.selected = YES;
    }
    
    else if (orientation == UIInterfaceOrientationPortrait)
    {
        //
        self.playControll.fullScreenBtn.selected = NO;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self installMovieNotificationObservers];

    [self.player prepareToPlay];
    self.playControll.playBtn.selected = YES;
    
//    [LTBackupStateView setStateViewHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [LTBackupStateView setStateViewHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 手势方法

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.playControll.videoSlider];
    CGFloat value = (self.playControll.videoSlider.maximumValue - self.playControll.videoSlider.minimumValue) * (touchPoint.x / self.playControll.videoSlider.frame.size.width );
    [self.playControll.videoSlider setValue:value];
    [self didSliderValueChanged];
}

- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    //    //根据在view上Pan的位置，确定是调音量还是亮度
    //    CGPoint locationPoint = [pan locationInView:self];
    //
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self.view];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        { // 开始移动
            // 使用绝对值来判断移动的方向
            self.playControll.alpha = 1;
            
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.playControll.panDirection = PanDirectionHorizontalMoved;
            }
            else if (x < y){ // 垂直移动
                self.playControll.panDirection = PanDirectionVerticalMoved;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
             self.playControll.alpha = 1;
            
            switch (self.playControll.panDirection)
            {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
//                    [self progressSliderValueChanged:self.playControll.videoSlider];
                    
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            [self readyForHidden];
            
            switch (self.playControll.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self didSliderTouchUpInside];
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
- (void)verticalMoved:(CGFloat)value
{
    // 更改系统的音量
//    self.volumeViewSlider.value -= value / 10000;// 越小幅度越小
}
-(void)horizontalMoved:(CGFloat)value
{
    self.playControll.videoSlider.value += value/1000;
}


#pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    if ([anyTouch.view isKindOfClass:[UIToolbar class]] ||[anyTouch.view isKindOfClass:[UIImageView class]]) {
        return;
    }
  
    if (self.playControll.alpha) {
        [self hide];
    }else
    {
        [self show];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelDelayedHide];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self readyForHidden];
}

#pragma mark - Overlayer hidden show
- (void)readyForHidden
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:8];
}

- (void)readyForShow
{
    [self performSelector:@selector(show) withObject:nil afterDelay:5];
}

- (void)show
{
    [UIView animateWithDuration:0.6 animations:^{
        self.playControll.alpha = 1;
    }];
    
    [self cancelDelayedHide];
    [self.playControll refreshMediaControl];
}

- (void)hide
{
    [UIView animateWithDuration:1 animations:^{
        self.playControll.alpha = 0;
    }];
    
    [self cancelDelayedHide];
    [self.playControll refreshMediaControl];
}

- (void)cancelDelayedHide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
}


#pragma mark IBAction

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)fullScreenBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self interfaceOrientation:(sender.selected==YES)?UIInterfaceOrientationLandscapeLeft:UIInterfaceOrientationPortrait];
}


- (void)dismissViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dimissIJKPlayer" object:nil];
    if ([self.player isKindOfClass:[IJKMPMoviePlayerController class]]) {
        [self.player shutdown];
        [self removeMovieNotificationObservers];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)onClickPlay:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.player isPlaying])
    {
        [self.player pause];
    }else
    {
        [self.player play];
    }
    [self.playControll refreshMediaControl];
}


- (IBAction)didSliderTouchDown
{
    [self.playControll beginDragMediaSlider];
}

- (IBAction)didSliderTouchCancel
{
    [self.playControll endDragMediaSlider];
}

- (IBAction)didSliderTouchUpOutside
{
    [self.playControll endDragMediaSlider];
}

- (IBAction)didSliderTouchUpInside
{
    [self cancelDelayedHide];
    self.player.currentPlaybackTime = self.playControll.videoSlider.value;
    [self.playControll endDragMediaSlider];
    [self.playControll refreshMediaControl];
    [self readyForHidden];
}

- (IBAction)didSliderValueChanged
{
    [self.playControll continueDragMediaSlider];
    [self cancelDelayedHide];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    IJKMPMovieLoadState loadState = _player.loadState;

    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
        NSLog(@"缓存完了");
         [self.playControll.activity stopAnimating];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
         NSLog(@"开始缓存");
        [self.playControll.activity startAnimating];
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            self.playControll.playBtn.selected = NO;
            break;

        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;

        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward

    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            self.playControll.playBtn.selected = NO;
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            self.playControll.playBtn.selected = YES;
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            self.playControll.playBtn.selected = NO;
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

@end
