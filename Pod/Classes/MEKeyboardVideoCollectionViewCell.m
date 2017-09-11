//
//  MEKeyboardVideoCollectionViewCell.m
//  MakemojiSDK-KeyboardExtension
//
//  Created by steve on 7/19/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEKeyboardVideoCollectionViewCell.h"

@implementation MEKeyboardVideoCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.previewImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.previewImage setContentMode:UIViewContentModeScaleAspectFit];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.previewImage];
        
        self.playOverlay = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MEKeyboardPlayOverlay"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.playOverlay.tintColor = [UIColor blackColor];
        self.playOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.playOverlay setContentMode:UIViewContentModeScaleAspectFit];
        self.playOverlay.alpha = 0.60;
        [self.contentView addSubview:self.playOverlay];
        
        self.emojiLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.emojiLabel.text = @"";
        self.emojiLabel.font = [UIFont systemFontOfSize:14];
        self.emojiLabel.textColor = [UIColor whiteColor];
        self.emojiLabel.textAlignment = NSTextAlignmentCenter;
        self.emojiLabel.numberOfLines = 2;
        self.emojiLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.emojiLabel];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.previewImage.frame = CGRectMake(12.5, 10, self.contentView.frame.size.width-25, self.contentView.frame.size.height-50);
    self.playOverlay.frame = CGRectMake(5,5,30,30);
    
    self.emojiLabel.frame = CGRectMake(10, self.previewImage.frame.size.height+self.previewImage.frame.origin.y, self.contentView.frame.size.width-20, self.contentView.frame.size.height-self.previewImage.frame.size.height-self.previewImage.frame.origin.y);
}

-(void)prepareForReuse {
    self.previewImage.image = nil;
}

@end
