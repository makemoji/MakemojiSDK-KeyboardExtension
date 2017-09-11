//
//  MEKeyboardReusableHeaderView.m
//  Pods
//
//  Created by steve on 2/17/17.
//
//

#import "MEKeyboardReusableHeaderView.h"

@implementation MEKeyboardReusableHeaderView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    self.userInteractionEnabled = NO;
    self.sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.sectionLabel.text = @"";
    self.sectionLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
    self.sectionLabel.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:self.sectionLabel];
}

-(void)layoutSubviews {
    CGRect oldFrame = self.sectionLabel.frame;
    oldFrame.origin.x = 12;
    oldFrame.origin.y = 10;
    self.sectionLabel.frame = oldFrame;
}

@end
