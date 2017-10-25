//
//  IJKDemoFileDownload.m
//  github.com/foolsparadise
//
//  Created by github.com/foolsparadise on 2/6/17.
//  Copyright © 2017 nil. All rights reserved.
//


#import "IJKDemoFileDownload.h"

/**
 This file forked from http://www.codeweblog.com/ios%E7%BD%91%E7%BB%9C-%E4%BD%BF%E7%94%A8nsurlconnect%E4%B8%8B%E8%BD%BD-%E8%BF%9B%E5%BA%A6-%E6%97%A0%E5%86%85%E5%AD%98%E5%B3%B0%E5%80%BC/
 2017-6.2 and i modify
 */

@interface IJKDemoFileDownload () <NSURLConnectionDataDelegate> {
    NSURLConnection *conn;
}
// 目标路径
@property (nonatomic,copy) NSString *targetPath;
// 文件总大小
@property (nonatomic,assign) long long expectedContentLength;
// 已下载文件的大小
@property (nonatomic,assign) long long fileSize;
@end

@implementation IJKDemoFileDownload

- (void)IJKDemoFileDownloadWithURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:15];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    [conn start];
}

#pragma mark - 代理方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 存放下载文件的目标路径
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *datPath = [documentsDirectory stringByAppendingPathComponent:@"temp.dat"];
    self.targetPath = datPath;
    self.expectedContentLength = response.expectedContentLength;
    self.fileSize = 0;
    [[NSFileManager defaultManager]removeItemAtPath:self.targetPath error:NULL];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.fileSize += data.length;
    //float progress = (float)self.fileSize / self.expectedContentLength;
    //NSLog(@"%f %lu",progress, (unsigned long)data.length);
    [self appendData:data];
}
// 拼接下载的数据块
- (void)appendData:(NSData *)data
{
    NSFileHandle *fp = [NSFileHandle fileHandleForWritingAtPath:self.targetPath];
    if(fp == nil){
        [data writeToFile:self.targetPath atomically:YES];
    }
    else{
        //NSLog(@"IJKDemoFileDownload write");
        [fp seekToEndOfFile];
        [fp writeData:data];
        [fp closeFile];
        if([NSData dataWithContentsOfFile:self.targetPath].length>64){
            //NSLog(@"IJKDemoFileDownload return");
            if(conn) [conn cancel];
            conn = nil;
            return;
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"下载完成");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //NSLog(@"错误");
}

@end
