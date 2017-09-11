//
//  MEKeyboardAPIManager.m
//  Makemoji
//
//  Created by steve on 12/27/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardAPIManager.h"
#import "MEKeyboardAPIConstants.h"
#import <AdSupport/AdSupport.h>

@interface MEKeyboardAPIManager ()
    @property NSDate * imageViewSessionStart;
    @property NSString * externalUserId;
    @property NSMutableDictionary * imageViews;
    @property NSMutableArray * emojiClicks;
    @property NSDate * clickSessionStart;
@end

@implementation MEKeyboardAPIManager
@synthesize sdkKey = _sdkKey;


+(instancetype)client
{
    static MEKeyboardAPIManager * requests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                                diskCapacity:200 * 1024 * 1024
                                                                    diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        requests = [[MEKeyboardAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kMEKeyboardSSLBaseUrl]];
        [requests.reachabilityManager startMonitoring];
    });
    return requests;
}

-(void)setSdkKey:(NSString *)sdkKey {
    _sdkKey = sdkKey;
    MEKeyboardAPIManager *manager = [MEKeyboardAPIManager client];
    
    NSString * deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] == YES) {
        deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    
    [manager.requestSerializer setValue:deviceId forHTTPHeaderField:@"makemoji-deviceId"];
    [manager.requestSerializer setValue:@"3pk 1.1" forHTTPHeaderField:@"makemoji-version"];
    [manager.requestSerializer setValue:sdkKey forHTTPHeaderField:@"makemoji-sdkkey"];
}

-(NSString *)sdkKey {
    return  _sdkKey;
}

-(void)imageViewWithId:(NSString *)emojiId {
    
    
    MEKeyboardAPIManager * apiManager = [MEKeyboardAPIManager client];
    
    if (apiManager.imageViewSessionStart != nil) {
        if (fabs([apiManager.imageViewSessionStart timeIntervalSinceNow]) > 30) {
            [apiManager endImageViewSession];
            apiManager.imageViews = nil;
            apiManager.imageViewSessionStart = nil;
        }
    }
    
    if (apiManager.imageViews == nil) {
        apiManager.imageViews = [NSMutableDictionary dictionary];
    }
    
    if (apiManager.imageViewSessionStart == nil) {
        apiManager.imageViewSessionStart = [NSDate date];
    }
    
    NSMutableDictionary * viewDict = [apiManager.imageViews objectForKey:emojiId];
    
    if (viewDict == nil) {
        NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:emojiId, @"1", nil] forKeys:[NSArray arrayWithObjects:@"emoji_id", @"views", nil]];
        [apiManager.imageViews setObject:newDict forKey:emojiId];
    } else {
        NSString * viewNumber = [viewDict objectForKey:@"views"];
        NSInteger viewCount = [viewNumber integerValue];
        viewCount++;
        [viewDict setObject:[NSString stringWithFormat:@"%li", (long)viewCount] forKey:@"views"];
        [apiManager.imageViews setObject:viewDict forKey:emojiId];
    }
}

-(void)beginImageViewSessionWithTag:(NSString *)tag {
    MEKeyboardAPIManager * apiManager = [MEKeyboardAPIManager client];
    if (apiManager.imageViewSessionStart == nil) {
        apiManager.imageViewSessionStart = [NSDate date];
    }
}

-(void)endImageViewSession {
    MEKeyboardAPIManager *manager = [MEKeyboardAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary * sending = [[MEKeyboardAPIManager client] imageViews];
    [sending setObject:[[MEKeyboardAPIManager client] imageViewSessionStart] forKey:@"date"];
    manager.imageViewSessionStart = nil;
    manager.imageViews = nil;
    
    [manager POST:@"emoji/viewTrack" parameters:sending success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}


-(void)clickWithEmoji:(NSDictionary *)emoji {
    
    MEKeyboardAPIManager * apiManager = [MEKeyboardAPIManager client];
    if (apiManager.emojiClicks == nil) {
        apiManager.emojiClicks = [NSMutableArray array];
        apiManager.clickSessionStart = [NSDate date];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:emoji];
    
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:[NSDate date]];
    
    [dict setObject:dateString forKey:@"click"];
    if ([dict objectForKey:@"image_url"]) {
        [dict removeObjectForKey:@"image_url"];
    }
    
    if ([dict objectForKey:@"username"]) {
        [dict removeObjectForKey:@"username"];
    }
    
    if ([dict objectForKey:@"access"]) {
        [dict removeObjectForKey:@"access"];
    }
    
    if ([dict objectForKey:@"origin_id"]) {
        [dict removeObjectForKey:@"origin_id"];
    }
    
    if ([dict objectForKey:@"likes"]) {
        [dict removeObjectForKey:@"likes"];
    }
    
    if ([dict objectForKey:@"deleted"]) {
        [dict removeObjectForKey:@"deleted"];
    }
    
    if ([dict objectForKey:@"created"]) {
        [dict removeObjectForKey:@"created"];
    }
    
    if ([dict objectForKey:@"remoji"]) {
        [dict removeObjectForKey:@"remoji"];
    }
    
    if ([dict objectForKey:@"shares"]) {
        [dict removeObjectForKey:@"shares"];
    }
    
    if ([dict objectForKey:@"legacy"]) {
        [dict removeObjectForKey:@"legacy"];
    }
    
    if ([dict objectForKey:@"link_url"]) {
        [dict removeObjectForKey:@"link_url"];
    }
    
    if ([dict objectForKey:@"name"]) {
        [dict removeObjectForKey:@"name"];
    }
    
    if ([dict objectForKey:@"flashtag"]) {
        [dict removeObjectForKey:@"flashtag"];
    }
    
    
    [apiManager.emojiClicks addObject:dict];
    
    if (apiManager.emojiClicks.count > 25) {
        NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:apiManager.emojiClicks options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [apiManager POST:@"emoji/clickTrackBatch" parameters:@{@"emoji": jsonString} success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        apiManager.emojiClicks = nil;
        apiManager.clickSessionStart = nil;
        
    }
    
}

+(NSArray *)unlockedGroups {
    NSUserDefaults * usrInfo = [[NSUserDefaults alloc] initWithSuiteName:@"MakemojiSDK"];
    if (usrInfo == nil) {
        return [NSArray array];
    }
    NSArray * unlockedGroups = [usrInfo objectForKey:@"MEUnlockedGroups"];
    if (unlockedGroups != nil && unlockedGroups.count > 0) {
        return unlockedGroups;
    }
    return [NSArray array];
}

+(void)unlockCategory:(NSString *)category {
    NSMutableArray * unlocked = [NSMutableArray array];
    
    NSUserDefaults * usrInfo = [[NSUserDefaults alloc] initWithSuiteName:@"MakemojiSDK"];
    __weak NSString * catName = category;
    
    if (usrInfo != nil) {
        NSArray * unlockedGroups = [usrInfo objectForKey:@"MEUnlockedGroups"];
        if (unlockedGroups != nil) {
            unlocked = [NSMutableArray arrayWithArray:unlockedGroups];
            for (NSString * arCatName in unlocked) {
                if ([arCatName isEqualToString:category]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *userInfo = @{@"category_name": catName};
                        [[NSNotificationCenter defaultCenter] postNotificationName:MEKeyboardCategoryUnlockedSuccessNotification object:nil userInfo:userInfo];
                    });
                    return;
                }
            }
        }
    }
    
    NSString * url = @"emoji/unlockGroup";
    MEKeyboardAPIManager * manager = [MEKeyboardAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:url parameters:@{@"category_name" : category} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSUserDefaults * userInfo = [[NSUserDefaults alloc] initWithSuiteName:@"MakemojiSDK"];
        [unlocked addObject:category];
        [userInfo setObject:[NSArray arrayWithArray:unlocked] forKey:@"MEUnlockedGroups"];
        [userInfo synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{@"category_name": catName};
            [[NSNotificationCenter defaultCenter] postNotificationName:MEKeyboardCategoryUnlockedSuccessNotification object:nil userInfo:userInfo];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{@"category_name": catName};
            [[NSNotificationCenter defaultCenter] postNotificationName:MEKeyboardCategoryUnlockedFailedNotification object:error userInfo:userInfo];
        });
    }];
    
}

@end
