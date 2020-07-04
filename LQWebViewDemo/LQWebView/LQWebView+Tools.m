//
//  LQWebView+Tools.m
//  LQWebViewDemo
//
//  Created by 刘启强 on 2020/4/15.
//  Copyright © 2020 LiuQiqiang. All rights reserved.
//

#import "LQWebView+Tools.h"

@implementation LQWebView (Tools)

- (NSString *)encodeURL:(NSString *) urlString {
    
    urlString = [self encodeTXT:urlString];
    if ([self isURLContainChinese:urlString]) {
        return [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];
    }
    
    return urlString;
}

- (NSString *) encodeTXT:(NSString *) urlString {
    NSString *suffix = [[urlString lastPathComponent] lowercaseString];
    if ([suffix containsString:@".txt"]) {
        NSString *body = [NSString stringWithContentsOfFile:urlString encoding:NSUTF8StringEncoding error:nil];
        if (body == nil) {
            body = [NSString stringWithContentsOfFile:urlString encoding:0x80000632 error:nil];
        }
        
        if (body == nil) {
            body = [NSString stringWithContentsOfFile:urlString encoding:0x80000631 error:nil];
        }
        
        if (body == nil) {
            body = [NSString stringWithContentsOfFile:urlString encoding:NSASCIIStringEncoding error:nil];
        }
        
        if (body) {
            return body;
        }
    }
    return urlString;
}
//判断是否有中文
-(BOOL)isURLContainChinese:(NSString *) url {

    for(int i=0; i< [url length];i++){
        int a = [url characterAtIndex:i];
        if( a >0x4e00 && a <0x9fff) {
            return YES;
        }
    }
    return NO;
}

//获取应该用什么类型加载
//+ (NSString *)MIMETypeFromUrlString:(NSString *) urlString {
//    
//    NSURL *url = [NSURL URLWithString:urlString];
//    __block NSURLResponse *responseNew = nil;
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            responseNew = response;
//            dispatch_semaphore_signal(semaphore);
//        }] resume];
//    });
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    return responseNew.MIMEType;
//}

- (NSString *)MIMETypeOfFile:(NSString *)fileName {
    
    NSString *suffix = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
    
    NSDictionary *types = @{@"png": @"image/png",
                            @"jpg": @"image/jpeg",
                            @"jpe": @"image/jpeg",
                            @"jpeg": @"image/jpeg",
                            @"bmp": @"image/bmp",
                            @"dib": @"image/bmp",
                            @"gif": @"image/gif",
                            @"mp3": @"audio/mpeg",
                            @"mp4": @"video/mp4",
                            @"mpg4": @"video/mp4",
                            @"m4v": @"video/mp4",
                            @"mpg4": @"video/mp4",
                            @"mp4v": @"video/mp4",
                            @"js": @"application/x-javascript",
                            @"html": @"text/html",
                            @"txt": @"text/plain",
                            @"pdf": @"application/pdf",
                            @"ppt": @"application/vnd.ms-powerpoint",
                            @"rtf": @"application/rtf",
                            @"xls": @"application/vnd.ms-excel",
                            @"zip": @"application/zip",
                            @"doc": @"application/msword",
                            @"text": @"text/plain",
    };
    
    NSString *type = types[suffix];
    if (type == nil || type.length == 0) {
        type = @"application/octet-stream";
    }
    return type;
}
@end
