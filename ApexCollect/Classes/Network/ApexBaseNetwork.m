//
//  ApexBaseNetwork.m
//  ApexTracker
//
//  Created by 李超 on 2018/10/17.
//  Copyright © 2018年 LiChao. All rights reserved.
//

#import "ApexBaseNetwork.h"

@interface ApexBaseNetwork ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ApexBaseNetwork

+ (instancetype)sharedInstanceNetwork
{
    static ApexBaseNetwork *networkInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkInstance = [[self alloc] init];
    });
    
    return networkInstance;
}

- (NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}

- (NSURLRequest *)getRequestURL:(NSString *)url params:(id)params responseSuccess:(callBackSuccess)success fail:(callBackFailed)failed
{
    NSMutableString *paramString = [NSMutableString new];
    
    if ([params isKindOfClass:[NSDictionary class]]) {
        [params enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            if ([key isKindOfClass:[NSString class]] &&
                [obj isKindOfClass:[NSString class]]) {
                [paramString appendFormat:@"%@=%@&", key, obj];
            }
        }];
    }
    
    if (![paramString isEqualToString:@""]) {
        paramString = [[paramString substringToIndex:[paramString length] - 1] mutableCopy];
    }
    
    NSString *finalRequestUrlString = [[NSString alloc] initWithFormat:@"%@?%@", url, paramString];
    NSURL *finalURL = [NSURL URLWithString:finalRequestUrlString];
    
    if (!finalURL) {
        [[PEXLogger sharedInstance] debug:@"apex_error_URL_parse"];
        return nil;
    }
    
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"%@：%@", @"apex_network_start_get", finalRequestUrlString]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL];
    [request setHTTPMethod:@"GET"];
    
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        
        if (connectionError == nil) {
            [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"%@：%@", @"apex_network_get_succeed", finalRequestUrlString]];
            if (data) {
                [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"get request result:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
            }
            
            if (success) {
                success(response);
            }
        }
        else {
            [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"apex_network_get_fail:%@ \n reason:%@", finalRequestUrlString, [connectionError localizedDescription]]];
            if (failed) {
                failed(connectionError, response);
            }
        }
    }] resume];
    
    return request;
}

- (NSURLRequest *)postRequestURL:(NSString *)url params:(id)params responseSuccess:(callBackSuccess)success fail:(callBackFailed)failed
{
    NSURL *finalURL = [NSURL URLWithString:url];
    
    if (!url) {
        [[PEXLogger sharedInstance] debug:@"apex_error_URL_parse"];
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict removeObjectForKey:@"method"];
    [dict removeObjectForKey:@"requestUrl"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"post request parameter:%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
//    [request setHTTPBody:jsonData];
    
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        
        if (connectionError == nil) {
            [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"%@:%@", @"apex_network_post_succeed", url]];
            if (data) {
                [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"post request result:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
            }
            
            if (success) {
                success(response);
            }
            
        } else {
            [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"apex_network_post_fail:%@ \n reason:%@", url, [connectionError localizedDescription]]];
            
            if (failed) {
                failed(connectionError, response);
            }
        }
        
    }] resume];
    
    return request;
}


//忽略证书验证 信任所有证书
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){//服务器信任证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];//服务器信任证书
        if(completionHandler)
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

////HTTPS认证
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
//
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    __block NSURLCredential *credential = nil;
//
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//        if (credential) {
//            disposition = NSURLSessionAuthChallengeUseCredential;
//        } else {
//            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//        }
//    } else {
//        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    }
//
//    if (completionHandler) {
//        completionHandler(disposition, credential);
//    }
//}


@end
