//
//  MEKeyboardNavigationCollectionViewCell.m
//  Makemoji
//
//  Created by steve on 12/26/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardNavigationCollectionViewCell.h"

@implementation MEKeyboardNavigationCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.cornerRadius = 15;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.imageView.center = self.contentView.center;
        [self.imageView setImage:[UIImage imageNamed:@"defaultnavicon"]];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.imageView.alpha = 0.70;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.imageView.alpha = 1.0;
        self.contentView.backgroundColor = [UIColor colorWithRed:0.82 green:0.847 blue:0.874 alpha:1];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.imageView.alpha = 0.75;
    }
}

@end
