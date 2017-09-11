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
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
