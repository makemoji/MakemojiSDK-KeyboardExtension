//
//  KeyboardViewController.h
//  Makemoji Keyboard
//
//  Created by steve on 12/26/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEKeyboardNativeView.h"

@interface MEKeyboardViewController : UIInputViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property UICollectionView * navigationCollectionView;
@property UICollectionView * emojiCollectionView;
@property UILabel * sectionLabel;
@property UIButton * shareButton;
@property UIButton * backspaceButton;
@property UIView * alertContainerView;
@property UILabel * alertLabel;
@property UIImageView * alertImageView;
@property MEKeyboardNativeView * keyboardView;
@property NSString * shareText;
@property CGSize outputSize;
@property CGSize emojiInnerSize;
@property NSMutableArray * categories;
@property NSIndexPath * selectedCategoryIndexPath;
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property NSString * navigationCellClass;
-(void)setupLayoutWithSize:(CGSize)size;
@end