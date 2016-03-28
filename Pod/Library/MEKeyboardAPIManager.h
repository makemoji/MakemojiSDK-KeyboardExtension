//
//  MEKeyboardAPIManager.h
//  Makemoji
//
//  Created by steve on 12/27/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>


@interface MEKeyboardAPIManager : AFHTTPSessionManager
@property NSString * sdkKey;

+(instancetype)client;
-(void)imageViewWithId:(NSString *)emojiId;
-(void)beginImageViewSessionWithTag:(NSString *)tag;
-(void)endImageViewSession;
-(void)clickWithEmoji:(NSDictionary *)emoji;

@end
