//
//  MEKeyboardNativeView.m
//  Makemoji
//
//  Created by steve on 2/19/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEKeyboardNativeView.h"

@interface MEKeyboardNativeView ()

@end

@implementation MEKeyboardNativeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.emojiButtonImageName = @"MEKeyboard-emoji";
        
        self.alphaKeys = [NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObjects:@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p", nil],
                          [NSMutableArray arrayWithObjects:@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l", nil],
                          [NSMutableArray arrayWithObjects:@"z",@"x",@"c",@"v",@"b",@"n",@"m", nil], nil];
        
        self.numericKeys = [NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", nil],
                            [NSMutableArray arrayWithObjects:@"-",@"/",@":",@";",@"(",@")",@"$",@"&",@"@", @"\"", nil],
                            [NSMutableArray arrayWithObjects:@".",@",",@"?",@"!",@"'", nil], nil];
        
        self.symbolKeys = [NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObjects:@"[",@"]",@"{",@"}",@"#",@"%",@"^",@"*",@"+",@"=", nil],
                           [NSMutableArray arrayWithObjects:@"_",@"\\",@"|",@"~",@"<",@">",@"€",@"£",@"¥", @"•", nil],
                           [NSMutableArray arrayWithObjects:@".",@",",@"?",@"!",@"'", nil], nil];
        
        self.keyColor = [UIColor whiteColor];
        self.fontColor = [UIColor blackColor];
        self.shiftColor = [UIColor colorWithRed:0.68 green:0.71 blue:0.74 alpha:1];
        self.borderColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.rowHeight = 42;
        self.betweenRows = 12;
        self.padding = UIEdgeInsetsMake(10, 3, 3, 3);
        self.betweenKeys = 6;
        [self updateKeySize];

        self.rowOne = [[UIView alloc] initWithFrame:CGRectMake(self.padding.top, 0, frame.size.width, self.rowHeight)];
        self.rowOne.backgroundColor = [UIColor clearColor];

        self.rowTwo = [[UIView alloc] initWithFrame:CGRectMake(0, self.padding.top+self.rowHeight, frame.size.width, self.rowHeight)];
        self.rowTwo.backgroundColor = [UIColor clearColor];
        
        self.rowThree = [[UIView alloc] initWithFrame:CGRectMake(0, self.padding.top+(self.rowHeight*2)+(self.betweenRows), frame.size.width, self.rowHeight)];
        self.rowThree.backgroundColor = [UIColor clearColor];

        self.rowFour = [[UIView alloc] initWithFrame:CGRectMake(0, self.padding.top+(self.rowHeight*3)+(self.betweenRows*2), frame.size.width, self.rowHeight)];
        self.rowFour.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.rowOne];
        [self addSubview:self.rowTwo];
        [self addSubview:self.rowThree];
        [self addSubview:self.rowFour];
        self.keyboardState = @"alpha";
        [self layoutKeysWithFrame:frame];
        self.backgroundColor = [UIColor colorWithRed:0.82 green:0.84 blue:0.86 alpha:1];

        self.clipsToBounds = YES;
        self.opaque = YES;
        
    }
    return self;
}

-(void)layoutKeysWithFrame:(CGRect)frame {
    
    self.shiftKey = [self keyboardButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
    self.shiftKey.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.shiftKey addTarget:self action:@selector(shiftKeyPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.shiftKey setTintColor:self.fontColor];
    self.shiftKey.tag = 111;
    if ([self.keyboardState isEqualToString:@"alpha"]) {
        [self.shiftKey setImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEShiftButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.shiftKey setImageEdgeInsets:UIEdgeInsetsMake(11, 10, 11, 10)];
    } else {
        self.shiftKey.tag = 333;
        [self.shiftKey setTitle:@"#+=" forState:UIControlStateNormal];
    }
    
    [self.rowThree addSubview:self.shiftKey];
 
    NSMutableArray * rowOneChars;
    NSMutableArray * rowTwoChars;
    NSMutableArray * rowThreeChars;
    
    rowOneChars = [self.alphaKeys objectAtIndex:0];
    rowTwoChars = [self.alphaKeys objectAtIndex:1];
    rowThreeChars = [self.alphaKeys objectAtIndex:2];
    
    for (NSString * character in rowOneChars) {
        UIButton * charButton = [self characterButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
        [charButton setTitle:character forState:UIControlStateNormal];
        [self.rowOne addSubview:charButton];
    }
    
    for (NSString * character in rowTwoChars) {
        UIButton * charButton = [self characterButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
        [charButton setTitle:character forState:UIControlStateNormal];
        [self.rowTwo addSubview:charButton];
    }
    
    for (NSString * character in rowThreeChars) {
        UIButton * charButton = [self keyboardButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
        [charButton setTitle:character forState:UIControlStateNormal];
        [charButton setTag:666];
        [charButton addTarget:self action:@selector(didPressCharacterKey:) forControlEvents:UIControlEventTouchUpInside];
        [self.rowThree addSubview:charButton];
    }
    
    self.deleteKey = [self keyboardButtonWithSize:CGSizeMake(self.shiftKey.frame.size.width, self.rowThree.frame.size.height)];
    [self.deleteKey setTintColor:self.fontColor];
    [self.deleteKey setBackgroundColor:self.shiftColor];
    [self.deleteKey setImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEDeleteBackwardsButtonLarge" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.deleteKey addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.deleteKey addTarget:self action:@selector(deleteButtonRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.rowThree addSubview:self.deleteKey];

    self.numberKey = [self keyboardButtonWithSize:CGSizeMake(41, self.rowFour.frame.size.height)];
    [self.numberKey setBackgroundColor:self.shiftColor];
    self.numberKey.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.numberKey addTarget:self action:@selector(numberKeyPressed:) forControlEvents:UIControlEventTouchUpInside];
    if ([self.keyboardState isEqualToString:@"alpha"]) {
        [self.numberKey setTitle:@"123" forState:UIControlStateNormal];
    } else {
        [self.numberKey setTitle:@"ABC" forState:UIControlStateNormal];
    }
    [self.rowFour addSubview:self.numberKey];

    
    self.globeButton = [self keyboardButtonWithSize:CGSizeMake(41, self.defaultKeySize.height)];
    [self.globeButton setTintColor:self.fontColor];
    [self.globeButton setImageEdgeInsets:UIEdgeInsetsMake(11, 10.5, 11, 10.5)];
    [self.globeButton setBackgroundColor:self.shiftColor];
    [self.globeButton setImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEGlobeButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.globeButton addTarget:self action:@selector(globeKeyPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.globeButton.frame = CGRectZero;
    [self.rowFour addSubview:self.globeButton];
    
    self.emojiButton = [self keyboardButtonWithSize:CGSizeMake(41, self.defaultKeySize.height)];
    [self.emojiButton setImageEdgeInsets:UIEdgeInsetsMake(11, 6, 11, 6)];
    [self.emojiButton setBackgroundColor:self.shiftColor];
    [self.emojiButton setTintColor:self.fontColor];
    [self.emojiButton setImage:[UIImage imageNamed:self.emojiButtonImageName] forState:UIControlStateNormal];
    [self.emojiButton addTarget:self action:@selector(emojiKeyPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.emojiButton.frame = CGRectZero;
    [self.rowFour addSubview:self.emojiButton];
    
    self.spaceKey = [self keyboardButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
    self.spaceKey.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.spaceKey setTitle:@"space" forState:UIControlStateNormal];
    [self.spaceKey addTarget:self action:@selector(spaceButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.spaceKey addTarget:self action:@selector(spaceButtonRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.rowFour addSubview:self.spaceKey];
    
    self.returnKey = [self keyboardButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.rowFour.frame.size.height)];
    self.returnKey.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.returnKey setBackgroundColor:self.shiftColor];
    [self.returnKey setTitle:@"return" forState:UIControlStateNormal];
    [self.returnKey addTarget:self action:@selector(returnKeyPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.rowFour addSubview:self.returnKey];

}

-(void)globeKeyPressed:(id)sender {
    if ([self.inputViewController respondsToSelector:@selector(meKeyboardNativeView:didTapGlobeButton:)]) {
        [self.inputViewController meKeyboardNativeView:self didTapGlobeButton:self.globeButton];
    }
}

-(void)emojiKeyPressed:(id)sender {
    if ([self.inputViewController respondsToSelector:@selector(meKeyboardNativeView:didTapEmojiButton:)]) {
        [self.inputViewController meKeyboardNativeView:self didTapEmojiButton:self.emojiButton];
    }
}

-(void)returnKeyPressed:(id)sender {
    [self.textDocumentProxy insertText:@"\n"];
    if ([self.inputViewController respondsToSelector:@selector(meKeyboardNativeView:didInsertText:)]) {
        [self.inputViewController meKeyboardNativeView:self didInsertText:@"\n"];
    }
}

-(void)numberKeyPressed:(id)sender {
    if (![self.keyboardState isEqualToString:@"number"]) {
        [self.numberKey setTitle:@"ABC" forState:UIControlStateNormal];
        self.keyboardState = @"number";
            UIButton * charButton = [self characterButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
            [self.rowTwo addSubview:charButton];
            [[self.rowThree viewWithTag:666] removeFromSuperview];
            [[self.rowThree viewWithTag:666] removeFromSuperview];
       
        [self setupNumberKeys];

    } else {
        self.keyboardState = @"alpha";

        [[self.rowTwo viewWithTag:666] removeFromSuperview];
        UIButton * charButton = [self characterButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
        [self.rowThree addSubview:charButton];
        charButton = [self characterButtonWithSize:CGSizeMake(self.defaultKeySize.width, self.defaultKeySize.height)];
        [self.rowThree addSubview:charButton];

        [self setupAlpha];
    }
    [self updateLayout:self.frame];
}

-(void)setupSymbolKeys {
    [self.shiftKey setImage:nil forState:UIControlStateNormal];
    [self.shiftKey setTitle:@"123" forState:UIControlStateNormal];
    [self.shiftKey setBackgroundColor:self.shiftColor];
    [self setupKeys:self.symbolKeys];
}

-(void)setupNumberKeys {
    [self.shiftKey setImage:nil forState:UIControlStateNormal];
    [self.shiftKey setTitle:@"#+=" forState:UIControlStateNormal];
    [self.shiftKey setBackgroundColor:self.shiftColor];
    [self setupKeys:self.numericKeys];
}


-(void)setupKeys:(NSMutableArray *)keys {
[UIView performWithoutAnimation:^{

    int position = 0;
    
    for (UIButton * button in self.rowOne.subviews) {
        if (button.tag == 666) {
            [button setTitle:[[keys objectAtIndex:0] objectAtIndex:position] forState:UIControlStateNormal];
            [button layoutIfNeeded];
            position++;
        }
    }

    position = 0;
    for (UIButton * button in self.rowTwo.subviews) {
        if (button.tag == 666) {
            [button setTitle:[[keys objectAtIndex:1] objectAtIndex:position] forState:UIControlStateNormal];
            [button layoutIfNeeded];
            position++;
        }
    }
    
    position = 0;
    for (UIButton * button in self.rowThree.subviews) {
        if (button.tag == 666 && ([[keys objectAtIndex:2] count]) > position) {
            [button setTitle:[[keys objectAtIndex:2] objectAtIndex:position] forState:UIControlStateNormal];
            [button layoutIfNeeded];
            position++;
        }
    }

}];

}

-(void)shiftKeyPressed:(id)sender {

    if ([self.keyboardState isEqualToString:@"number"]) {
        if ([self.shiftKey.titleLabel.text isEqualToString:@"#+="]) {
            [self setupSymbolKeys];
        } else {
            [self setupNumberKeys];
        }
        return;
    }

    if (self.shiftKey.tag == 111) {
        [self shiftUp:YES];
    } else {
        [self shiftUp:NO];
    }

}

-(void)setupAlpha {
    [self.numberKey setTitle:@"123" forState:UIControlStateNormal];
    [self.shiftKey setTitle:@"" forState:UIControlStateNormal];
    [self setupKeys:self.alphaKeys];
    [self shiftUp:YES];
}


-(void)shiftUp:(BOOL)yes {
    if (![self.keyboardState isEqualToString:@"alpha"]) { return; }
    SEL sel = @selector(lowercaseString);
    
    if (yes) {
        sel = @selector(uppercaseString);
        [self.shiftKey setBackgroundColor:self.keyColor];
        self.shiftKey.tag = 222;
        [self.shiftKey setImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEShiftButtonEnabled" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    } else {
        [self.shiftKey setBackgroundColor:self.shiftColor];
        self.shiftKey.tag = 111;
        [self.shiftKey setImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEShiftButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }
    
[UIView performWithoutAnimation:^{
    
    NSMutableArray * views = [NSMutableArray array];
    for(UIButton * view in self.rowOne.subviews) {
        if (view.tag == 666) { [views addObject:view]; }
    }
    
    [views enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitle:[[[self.alphaKeys objectAtIndex:0] objectAtIndex:idx] performSelector:sel] forState:UIControlStateNormal];
        [obj layoutIfNeeded];
    }];

    NSMutableArray * views2 = [NSMutableArray array];
    for(UIButton * view in self.rowTwo.subviews) {
        if (view.tag == 666) { [views2 addObject:view]; }
    }
    
    [views2 enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTitle:[[[self.alphaKeys objectAtIndex:1] objectAtIndex:idx] performSelector:sel] forState:UIControlStateNormal];
            [obj layoutIfNeeded];
    }];
    
    NSMutableArray * views3 = [NSMutableArray array];
    for(UIButton * view in self.rowThree.subviews) {
        if (view.tag == 666) { [views3 addObject:view]; }
    }
    
    [views3 enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitle:[[[self.alphaKeys objectAtIndex:2] objectAtIndex:idx] performSelector:sel] forState:UIControlStateNormal];
         [obj layoutIfNeeded];
    }];
    
}];
}

-(void)didPressCharacterKey:(id)sender {
    UIButton * button = (UIButton *)sender;
    [self.textDocumentProxy insertText:button.titleLabel.text];
    if ([self.inputViewController respondsToSelector:@selector(meKeyboardNativeView:didInsertText:)]) {
        [self.inputViewController meKeyboardNativeView:self didInsertText:button.titleLabel.text];
    }
    if (self.shiftKey.tag == 222) { [self shiftUp:NO]; }
}

-(void)deleteBackwards:(UITapGestureRecognizer*)gesture {
    [self.textDocumentProxy deleteBackward];
    if ([self.inputViewController respondsToSelector:@selector(meKeyboardNativeView:didInsertText:)]) {
        [self.inputViewController meKeyboardNativeView:self didInsertText:@""];
    }
}

-(void)deleteButtonTapped {
    [self deleteBackwards:nil];
    self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(deleteRepeat) userInfo:nil repeats:YES];
}

-(void)deleteButtonRelease {
    [self.deleteTimer invalidate];
    self.deleteTimer = nil;
}

-(void)deleteRepeat {
    [self deleteBackwards:nil];
    if (self.deleteTimer) {
        NSTimeInterval lastInterval = self.deleteTimer.timeInterval;
        lastInterval -= 0.01;
        if (lastInterval < 0.02) {
            lastInterval = 0.02;
        }
        [self.deleteTimer invalidate];
        self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:lastInterval target:self selector:@selector(deleteRepeat) userInfo:nil repeats:YES];
    }
}

-(void)spaceButtonTapped {
    [self.textDocumentProxy insertText:@" "];
    if ([self.inputViewController respondsToSelector:@selector(meKeyboardNativeView:didInsertText:)]) {
        [self.inputViewController meKeyboardNativeView:self didInsertText:@" "];
    }
    self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(spaceRepeat) userInfo:nil repeats:YES];
}

-(void)spaceButtonRelease {
    [self.deleteTimer invalidate];
    self.deleteTimer = nil;
}

-(void)spaceRepeat {
    [self.textDocumentProxy insertText:@" "];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout:self.frame];
}

-(void)updateKeySize {
    int divider = (int)[[self.alphaKeys objectAtIndex:0] count];
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat possibleWidth = screenFrame.size.width - (self.padding.left + self.padding.right) - (self.betweenKeys * 9);
    CGFloat keyWidth = possibleWidth / divider;
    CGFloat keyHeight = (self.frame.size.height - (self.betweenRows * 3) - self.padding.top - self.padding.bottom) / 4;
    self.defaultKeySize = CGSizeMake(keyWidth, keyHeight);
}

-(void)updateLayout:(CGRect)frame {

[UIView performWithoutAnimation:^{
    [self updateKeySize];

    self.rowOne.frame = CGRectMake(0, self.padding.top, frame.size.width, self.rowHeight);
    self.rowTwo.frame = CGRectMake(0, self.padding.top+(self.rowHeight+self.betweenRows), frame.size.width, self.rowHeight);
    self.rowThree.frame = CGRectMake(0, self.padding.top+((self.rowHeight+self.betweenRows)*2), frame.size.width, self.rowHeight);
    self.rowFour.frame = CGRectMake(0, self.padding.top+((self.rowHeight+self.betweenRows)*3)-2, frame.size.width, self.rowHeight);
    
    CGFloat xpos = self.padding.left;
    for (UIButton * charButton in self.rowOne.subviews) {
        if (charButton.tag == 666) {
            charButton.frame = CGRectMake(xpos, 0, self.defaultKeySize.width, self.defaultKeySize.height);
            xpos = xpos+self.defaultKeySize.width+self.betweenKeys;
        }
    }
    
    xpos = self.rowTwo.frame.size.width - (self.padding.left + self.padding.right) - ([self.rowTwo.subviews count] * self.defaultKeySize.width) - (([self.rowTwo.subviews count] - 1) * self.betweenKeys);
    xpos = ceilf(xpos / 2);
    if (xpos <= self.padding.left) { xpos = self.padding.left; }
    
    for (UIButton * charButton in self.rowTwo.subviews) {
        if (charButton.tag == 666) {
            charButton.frame = CGRectMake(xpos, 0, self.defaultKeySize.width, self.defaultKeySize.height);
            xpos = xpos+self.defaultKeySize.width+self.betweenKeys;
        }
    }
    
    self.shiftKey.frame = CGRectMake(self.padding.left, 0, self.defaultKeySize.height, self.defaultKeySize.height);
    xpos = self.rowTwo.frame.size.width - (self.padding.left + self.padding.right) - ([self.rowTwo.subviews count] * self.defaultKeySize.width) - (([self.rowTwo.subviews count] - 1) * self.betweenKeys);
    xpos =  ceilf((xpos / 2) + self.defaultKeySize.width+self.betweenKeys);
   
    CGFloat rowThreeKeyWidth = self.defaultKeySize.width;
    if (self.rowThree.subviews.count == 7) {
        xpos = self.padding.left+self.shiftKey.frame.size.width+self.betweenKeys+self.padding.left;
        rowThreeKeyWidth = (frame.size.width - xpos - (5 * self.betweenKeys) - (2 * self.padding.left) - self.deleteKey.frame.size.width - self.padding.right) / 5;
    }
    
    for (UIButton * charButton in self.rowThree.subviews) {
        if (charButton.tag == 666) {
            charButton.frame = CGRectMake(xpos, 0, rowThreeKeyWidth, self.defaultKeySize.height);
            xpos = xpos+rowThreeKeyWidth+self.betweenKeys;
        }
    }

    self.deleteKey.frame = CGRectMake(self.rowFour.frame.size.width-self.padding.right-self.defaultKeySize.height, 0, self.defaultKeySize.height, self.defaultKeySize.height);
    self.numberKey.frame = CGRectMake(self.padding.left, 0, 40.5, self.defaultKeySize.height);
    self.globeButton.frame = CGRectMake(self.padding.left+self.numberKey.frame.size.width+self.betweenKeys, 0, 41, self.defaultKeySize.height);
    self.emojiButton.frame = CGRectMake(self.globeButton.frame.size.width+self.globeButton.frame.origin.x+self.betweenKeys, 0, self.defaultKeySize.width, self.defaultKeySize.height);
    self.returnKey.frame = CGRectMake(self.rowFour.frame.size.width-self.padding.right-87.5, 0, 87.5, self.defaultKeySize.height);
    CGFloat spaceWidth = frame.size.width - (self.emojiButton.frame.size.width+self.emojiButton.frame.origin.x+self.betweenKeys) - self.returnKey.frame.size.width - self.betweenKeys - self.padding.right;
    self.spaceKey.frame = CGRectMake(self.emojiButton.frame.size.width+self.emojiButton.frame.origin.x+self.betweenKeys, 0, spaceWidth, self.defaultKeySize.height);
}];
}


-(UIButton *)keyboardButtonWithSize:(CGSize)size {
    UIButton * charButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [charButton setBackgroundColor:self.keyColor];
    charButton.titleLabel.numberOfLines = 1;
    charButton.titleLabel.font = [UIFont systemFontOfSize:24];
    charButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    charButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentNone;
    [charButton setTitleColor:self.fontColor forState:UIControlStateNormal];
    [charButton setFrame:CGRectMake(0, 0, size.width, size.height)];
    charButton.layer.shadowColor = [[UIColor colorWithWhite:0.54 alpha:1] CGColor];
    charButton.layer.shadowOffset = CGSizeMake(0, 1);
    charButton.layer.shadowRadius = 0;
    charButton.layer.cornerRadius = 5;
    charButton.layer.shadowOpacity = 0.9;
    charButton.opaque = YES;
    return charButton;
}

-(UIButton *)characterButtonWithSize:(CGSize)size {
    UIButton * button =  [self keyboardButtonWithSize:size];
    [button setTag:666];
    [button addTarget:self action:@selector(didPressCharacterKey:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
