//
//  MEKeyboardGifCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 1/4/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEKeyboardGifCollectionViewCell.h"

@implementation MEKeyboardGifCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
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
