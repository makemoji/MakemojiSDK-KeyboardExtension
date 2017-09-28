//
//  MEKeyboardEmojiCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 12/27/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardEmojiCollectionViewCell.h"

@implementation MEKeyboardEmojiCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

-(void)prepareForReuse {
    self.imageView.image = nil;
}

@end
