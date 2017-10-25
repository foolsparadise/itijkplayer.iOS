//
//  ViewController.m
//  ijkDemoProject
//
//  Created by foolsparadise on 21/10/2017.
//  Copyright © 2016 github.com/foolsparadise All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *title = @"http://www.wowza.com/_h264/BigBuckBunny_175k.mov";
    NSURL *url = [NSURL URLWithString:@"http://www.wowza.com/_h264/BigBuckBunny_175k.mov"];
    //    IJKVideoViewController *player = [[IJKVideoViewController alloc] initWithURL:url];
    //    player.useAVPlayer = YES;
    //    [self.navigationController pushViewController:player animated:YES];
    [IJKVideoViewController presentFromViewController:self withTitle:title URL:url completion:^{
        
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
