# ijkplayerDemo  
This project based on https://github.com/Bilibili/ijkplayer. An optimized tutorial Demo for how to use it.  
So releaseNote:   
Add file type check.  
Optimize ijkplayer performance.  
Increase ijkplayer format compatibility.  
If file component is .mp4 or .mov, use system support framework MPMoviePlayerController(embed in ijkplayer framework), others use ijkplayer framework.  
## ~~ijkplayer.bak folder~~  
~~forked from https://github.com/Bilibili/ijkplayer at 2017-6-9 and no modify~~  
~~removed! If you need, git clone https://github.com/Bilibili/ijkplayer~~  
## ijkDemoProject folder  
I writed a Demo for howto use , within one player demo UI  
## IJKDemoFileDownload .h .m <- i created  
create for type check  
## IJKDemoMediaControl .h .m <- i created  
create for media control panel  
## IJKMoviePlayerViewController .m <- i modified , only for merge or comparison forked IJKMoviePlayerViewController file  
forked from https://github.com/Bilibili/ijkplayer at 2017-6-9 and i modify
## How to use  
1. git clone https://github.com/Bilibili/ijkplayer  
cd config  
rm module.sh  
ln -s module-default.sh module.sh  
complied IJKMediaFramework.framework, (open ijkplayer.bak folder see README.md how to , or goto https://github.com/Bilibili/ijkplayer to see how to)  
2. add framework  
```  
IJKMediaFramework.framework <- you complied  
libstdc++.tbd  
AudioToolbox.framework  
AVFoundation.framework  
CoreGraphics.framework  
CoreMedia.framework  
CoreVideo.framework  
libbz2.tbd  
libz.tbd  
MediaPlayer.framework  
MobileCoreServices.framework  
OpenGLES.framework  
QuartzCore.framework  
UIKit.framework  
VideoToolbox.framework  
```  
3. open ios/IJKMediaDemo/IJKMediaDemo folder, and add this files  
```  
IJKCommon.h  
IJKDemoHistory .h .m
IJKMediaControl .h .m
IJKMoviePlayerViewController .h .m .xib
```  
to your project.  
copy i modified files to your project  
```  
IJKDemoFileDownload .h .m <- i created  
IJKMoviePlayerViewController .m <- i modified  
```  
4. add ios/IJKMediaDemo/XCAssets/MoviePlayerImages.xcassets folder to your project   
Now, File List  
![DemoProjectFilelist.png](https://github.com/foolsparadise/ijkplayerDemo/blob/master/DemoProjectFilelist.png)  
5. be sure files has code:  
```  
AppDelegate.h  
#import <UIKit/UIKit.h>  
@interface AppDelegate : UIResponder   <UIApplicationDelegate>  
@property (strong, nonatomic) UIWindow *window;  
@property (strong, nonatomic) UIViewController *viewController;  
@end
```  
```  
AppDelegate.m  
#import "ViewController.h"  
 (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
    // Override point for customization after application launch.  
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];  
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];  
    self.viewController = navigationController;  
    self.window.rootViewController = self.viewController;  
    [self.window makeKeyAndVisible];  
    return YES;  
}  
```  
6. use  
```  
#import "IJKMoviePlayerViewController.h"  
[IJKVideoViewController presentFromViewController:self withTitle:@"Test" URL:[NSURL URLWithString:@"http://192.168.0.2:8081/test/test.mkv"] completion:^{
        [self.navigationController popViewControllerAnimated:NO];  
    }];  
```  
7. About ijkplayer, VLC, mediaPlayer.framework/MPMoviePlayerController, AVFounditon.framework/AVPlayer, AVKit/AVPlayerViewcontroller  
After test video files,  
4k KFHD (3840×2160) resolution, length of at least 1 hours video, different video formats,  
i suggest use ijkplayer, because its better than others, now at 2017-6.  
