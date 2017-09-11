//
//  KeyboardViewController.m
//  Emoji Keyboard
//
//  Created by steve on 3/28/16.
//  Copyright © 2016 Stephen Schroeder. All rights reserved.
//

#import "KeyboardViewController.h"
#import "MEKeyboardAPIManager.h"

@interface KeyboardViewController ()
@end

@implementation KeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[MEKeyboardAPIManager client] setSdkKey:@"940ced93abf2ca4175a4a865b38f1009d8848a58"];
        self.shareText = @"Check out the Makemoji App: http://appstore.com/makemoji";
    }
    return self;
}

@end
