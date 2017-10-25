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

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>



@class IJKDemoMediaControl;

@interface IJKVideoViewController : UIViewController<UIGestureRecognizerDelegate>

@property(atomic,strong) NSURL *url;
@property(atomic,assign) BOOL useAVPlayer; //default NO
@property(atomic, retain) id<IJKMediaPlayback> player;


@property(nonatomic, retain) IJKDemoMediaControl *playControll;
- (id)initWithURL:(NSURL *)url;
- (id)initWithContentURLString:(NSString *)aUrl;

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void(^)())completion;

- (IBAction)onClickMediaControl:(id)sender;
- (IBAction)onClickOverlay:(id)sender;
- (IBAction)onClickDone:(id)sender;
- (IBAction)onClickPlay:(id)sender;
- (IBAction)onClickPause:(id)sender;

- (IBAction)didSliderTouchDown;
- (IBAction)didSliderTouchCancel;
- (IBAction)didSliderTouchUpOutside;
- (IBAction)didSliderTouchUpInside;
- (IBAction)didSliderValueChanged;

@end
