/*
 * Copyright (C) 2013-2015 Bilibili
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

#import "IJKMoviePlayerViewController.h"
#import "IJKMediaControl.h"
#import "IJKCommon.h"
#import "IJKDemoHistory.h"

//i added
#import "IJKDemoFileDownload.h"

@implementation IJKVideoViewController

- (void)dealloc
{
}

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void (^)())completion {
    IJKDemoHistoryItem *historyItem = [[IJKDemoHistoryItem alloc] init];
    
    historyItem.title = title;
    historyItem.url = url;
    [[IJKDemoHistory instance] add:historyItem];
    
    [viewController presentViewController:[[IJKVideoViewController alloc] initWithURL:url] animated:YES completion:completion];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self initWithNibName:@"IJKMoviePlayerViewController" bundle:nil];
    if (self) {
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

/**
 URL file type check

 @param videoURL URL
 @return default mov use MPMoviePlayerController, others use IJKFFMoviePlayerController
 */
- (NSString *)contentTypeOfVideo:(NSURL *)videoURL
{
    // system DCIM
    //file:///var/mobile/Media/DCIM/101APPLE/IMG_xxxx.mp4
    // sandbox
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
            // case 0x6D: { NSLog(@"mov"); return @"mov"; }
        }
        return @"mov";
    }
    else {}
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *datPath = [documentsDirectory stringByAppendingPathComponent:@"temp.dat"];
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t queueGroup = dispatch_group_create();
    dispatch_group_async(queueGroup, aQueue, ^{
        IJKDemoFileDownload *ijL = [[IJKDemoFileDownload alloc] init];
        [ijL IJKDemoFileDownloadWithURL:videoURL];
    });
    dispatch_group_wait(queueGroup, DISPATCH_TIME_FOREVER);
    
    NSInteger count = 0;
    while ([NSData dataWithContentsOfFile:datPath].length<16) {
        count++;
        if(count>3)
            return @"avi";
        sleep(1);
    }
    
    
    NSData *data = [NSData dataWithContentsOfFile:datPath];
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        // file type check, can add by yourself, 遇到问题视频可以自已加处理
        case 0x52: { NSLog(@"avi"); return @"avi"; }
        // case 0x6D: { NSLog(@"mov"); return @"mov"; }            

    }
    
    return @"mov";
}
#define EXPECTED_IJKPLAYER_VERSION (1 << 16) & 0xFF) | 
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];

    IJKFFOptions *options = [IJKFFOptions optionsByDefault];

    // file type check i added 2017-6
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

    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    [self.view addSubview:self.mediaControl];

    self.mediaControl.delegatePlayer = self.player;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self installMovieNotificationObservers];

    [self.player prepareToPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBAction

- (IBAction)onClickMediaControl:(id)sender
{
    [self.mediaControl showAndFade];
}

- (IBAction)onClickOverlay:(id)sender
{
    [self.mediaControl hide];
}

- (IBAction)onClickDone:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickHUD:(UIBarButtonItem *)sender
{
    if ([self.player isKindOfClass:[IJKFFMoviePlayerController class]]) {
        IJKFFMoviePlayerController *player = self.player;
        player.shouldShowHudView = !player.shouldShowHudView;
        
        sender.title = (player.shouldShowHudView ? @"HUD On" : @"HUD Off");
    }
}

- (IBAction)onClickPlay:(id)sender
{
    [self.player play];
    [self.mediaControl refreshMediaControl];
}

- (IBAction)onClickPause:(id)sender
{
    [self.player pause];
    [self.mediaControl refreshMediaControl];
}

- (IBAction)didSliderTouchDown
{
    [self.mediaControl beginDragMediaSlider];
}

- (IBAction)didSliderTouchCancel
{
    [self.mediaControl endDragMediaSlider];
}

- (IBAction)didSliderTouchUpOutside
{
    [self.mediaControl endDragMediaSlider];
}

- (IBAction)didSliderTouchUpInside
{
    self.player.currentPlaybackTime = self.mediaControl.mediaProgressSlider.value;
    [self.mediaControl endDragMediaSlider];
}

- (IBAction)didSliderValueChanged
{
    [self.mediaControl continueDragMediaSlider];
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
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
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
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
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
