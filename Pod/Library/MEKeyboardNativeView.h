//
//  MEKeyboardNativeView.h
//  Makemoji
//
//  Created by steve on 2/19/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEKeyboardNativeView : UIView
    @property UIView * rowOne;
    @property UIView * rowTwo;
    @property UIView * rowThree;
    @property UIView * rowFour;
    @property NSMutableArray * alphaKeys;
    @property NSMutableArray * numericKeys;
    @property NSMutableArray * symbolKeys;
    @property (assign) id <UITextDocumentProxy> textDocumentProxy;
    @property UIButton * shiftKey;
    @property UIButton * deleteKey;
    @property UIButton * returnKey;
    @property UIButton * spaceKey;
    @property UIButton * numberKey;
    @property NSString * keyboardState;
    @property NSTimer * deleteTimer;
    -(void)layoutKeysWithFrame:(CGRect)frame;
@end
