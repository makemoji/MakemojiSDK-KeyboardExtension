//
//  KeyboardViewController.m
//  Makemoji Keyboard
//
//  Created by steve on 12/26/15.
//  Copyright © 2015 Makemoji. All rights reserved.
//

#import "MEKeyboardViewController.h"
#import "MEKeyboardAPIManager.h"
#import "MEKeyboardNavigationCollectionViewCell.h"
#import "MEKeyboardEmojiCollectionViewCell.h"
#import "MEKeyboardGifCollectionViewCell.h"
#import "MEKeyboardVideoCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Tint.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import "MEKeyboardReusableHeaderView.h"

@interface MEKeyboardViewController ()

@property (nonatomic, strong) UIButton *emptyView;
@property NSTimer * deleteTimer;
@property NSLayoutConstraint * heightConstraint;
@property CGFloat landscapeHeight;
@property CGFloat portraitHeight;
@property BOOL isLandscape;
@property UILabel * fullAccessLabel;
@property UILabel * addEmojiLabel;
@property NSString * userId;
@property UIActivityIndicatorView * activityIndicator;
@property NSString * searchWord;
@property NSMutableArray * searchEmoji;
@property BOOL ignoreScrollSelection;
@property NSDictionary *lastSharedEmoji;
@property NSInteger visibleSection;
@property CGFloat currentHeight;
@end

@implementation MEKeyboardViewController {
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.portraitHeight = 258;
        self.landscapeHeight = 191;
        self.currentHeight = 191;
        self.ignoreScrollSelection = NO;
        self.shareText = @"";
        self.emojiInnerSize = CGSizeMake(61.44, 61.44);
        self.outputSize = CGSizeMake(71.44, 71.44);
        self.navigationCellClass = @"MEKeyboardNavigationCollectionViewCell";
        self.mainBackgroundColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.945 alpha:1];
        self.displayVideoCollection = NO;
        self.enableUpdates = YES;
        self.enableTrending = YES;
        self.enableUsed = YES;
        self.disableNavScrolling = NO;
        self.searchWord = @"";
        self.searchEmoji = [NSMutableArray array];
        self.keyboardImageName = @"MEKeyboard-keyboard";
        self.visibleSection = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SDImageCache sharedImageCache] setMaxMemoryCountLimit:2];
    [[SDWebImageDownloader sharedDownloader] setExecutionOrder:SDWebImageDownloaderLIFOExecutionOrder];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    if (self.navigationCellClass == nil) {
        self.navigationCellClass = @"MEKeyboardNavigationCollectionViewCell";
    }
    
    [self.inputView setBackgroundColor:self.mainBackgroundColor];
    [self.view setBackgroundColor:self.mainBackgroundColor];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator sizeToFit];
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];
    
    self.allEmoji = [NSMutableDictionary dictionary];
    self.categories = [NSMutableArray array];
    NSMutableArray * arr = [NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Keyboard",@"name", nil]];
    self.categories = arr;
    
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.925 green:0.933 blue:0.945 alpha:1]];
    
    self.emptyView = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.emptyView setBackgroundColor:[UIColor clearColor]];
    [self.emptyView setUserInteractionEnabled:NO];
    self.emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.emptyView];
    
    // Perform custom UI setup here
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextKeyboardButton.tintColor = [UIColor colorWithRed:0.34 green:0.36 blue:0.39 alpha:1];
    self.nextKeyboardButton.titleLabel.textColor = [UIColor colorWithRed:0.34 green:0.36 blue:0.39 alpha:1];
    [self.nextKeyboardButton setTitleColor:[UIColor colorWithRed:0.34 green:0.36 blue:0.39 alpha:1] forState:UIControlStateNormal];

    [self.nextKeyboardButton setImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEGlobeButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    //[self.nextKeyboardButton setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextKeyboardButton];
    
    UICollectionViewFlowLayout * navigationLayout = [[UICollectionViewFlowLayout alloc] init];
       navigationLayout.itemSize = CGSizeMake(30,30);
    
    [navigationLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    navigationLayout.minimumInteritemSpacing = 4;
    navigationLayout.minimumLineSpacing = 0;
    
    self.navigationCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:navigationLayout];
    [self.navigationCollectionView registerClass:NSClassFromString(self.navigationCellClass) forCellWithReuseIdentifier:@"Category"];
    [self.navigationCollectionView setDelegate:self];
    [self.navigationCollectionView setBackgroundColor:[UIColor clearColor]];
    self.navigationCollectionView.showsHorizontalScrollIndicator = NO;
    self.navigationCollectionView.dataSource = self;
    //self.navigationCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationCollectionView];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    UICollectionViewFlowLayout * newLayout2 = [[UICollectionViewFlowLayout alloc] init];
    newLayout2.itemSize = CGSizeMake(frame.size.width/8,34);
    [newLayout2 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    newLayout2.minimumInteritemSpacing = 0;
    newLayout2.minimumLineSpacing = 0;
    newLayout2.sectionHeadersPinToVisibleBounds = YES;
    self.emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:newLayout2];
    [self.emojiCollectionView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
    self.emojiCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.emojiCollectionView setShowsHorizontalScrollIndicator:NO];
    //[self.emojiCollectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.emojiCollectionView registerClass:[MEKeyboardEmojiCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
    [self.emojiCollectionView registerClass:[MEKeyboardGifCollectionViewCell class] forCellWithReuseIdentifier:@"EmojiGif"];
    [self.emojiCollectionView registerClass:[MEKeyboardVideoCollectionViewCell class] forCellWithReuseIdentifier:@"Video"];
    [self.emojiCollectionView registerClass:[MEKeyboardReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section"];

    [self.emojiCollectionView setBackgroundColor:[UIColor clearColor]];

    self.emojiCollectionView.pagingEnabled = NO;
    [self.emojiCollectionView setDelegate:self];
    self.emojiCollectionView.dataSource = self;
    [self.view addSubview:self.emojiCollectionView];

    
    //search collection view
    
    UICollectionViewFlowLayout * newLayout3 = [[UICollectionViewFlowLayout alloc] init];
    newLayout3.itemSize = CGSizeMake(frame.size.width/8,34);
    [newLayout3 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    newLayout3.minimumInteritemSpacing = 0;
    newLayout3.minimumLineSpacing = 0;
    self.searchCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:newLayout3];
    [self.searchCollectionView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
    self.searchCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.searchCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.searchCollectionView registerClass:[MEKeyboardEmojiCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
    [self.searchCollectionView registerClass:[MEKeyboardGifCollectionViewCell class] forCellWithReuseIdentifier:@"EmojiGif"];
    [self.searchCollectionView registerClass:[MEKeyboardVideoCollectionViewCell class] forCellWithReuseIdentifier:@"Video"];
    
    
    [self.searchCollectionView setBackgroundColor:[UIColor clearColor]];
    
    self.searchCollectionView.pagingEnabled = YES;
    [self.searchCollectionView setDelegate:self];
    self.searchCollectionView.dataSource = self;
    [self.view addSubview:self.searchCollectionView];
    self.searchCollectionView.hidden = YES;
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setTitle:@"SHARE KEYBOARD" forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self.shareButton addTarget:self action:@selector(shareKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];

    self.backspaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [self.backspaceButton setImage:[[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/MEDeleteBackwardsButtonLarge" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.backspaceButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.backspaceButton addTarget:self action:@selector(deleteButtonRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.backspaceButton.imageView setTintColor:[UIColor colorWithRed:0.309 green:0.33 blue:0.364 alpha:1]];
    [self.view addSubview:self.backspaceButton];
    
    self.alertContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.alertContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    self.alertContainerView.alpha = 0;
    self.alertContainerView.layer.cornerRadius = 10;
    
    [self.view addSubview:self.alertContainerView];
    [self.view sendSubviewToBack:self.alertContainerView];
    
    self.alertLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.alertLabel.font = [UIFont boldSystemFontOfSize:14];
    self.alertLabel.textColor = [UIColor whiteColor];
    self.alertLabel.text = @"Emoji Copied!";
    [self.alertLabel sizeToFit];
    [self.alertContainerView addSubview:self.alertLabel];
    
    self.alertImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.alertContainerView addSubview:self.alertImageView];

    
    self.fullAccessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.fullAccessLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    self.fullAccessLabel.text = @"Full Access must be enabled to use the keyboard.";
    self.fullAccessLabel.textColor = [UIColor whiteColor];
    self.fullAccessLabel.numberOfLines = 2;
    self.fullAccessLabel.font = [UIFont boldSystemFontOfSize:18];
    self.fullAccessLabel.textAlignment = NSTextAlignmentCenter;
    self.fullAccessLabel.hidden = YES;
    [self.view addSubview:self.fullAccessLabel];
    [self.view sendSubviewToBack:self.fullAccessLabel];
    
    self.addEmojiLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.addEmojiLabel.backgroundColor = [UIColor clearColor];
    self.addEmojiLabel.text = @"Use the Makemoji app to create your own emoji.";
    self.addEmojiLabel.textColor = [UIColor darkGrayColor];
    self.addEmojiLabel.numberOfLines = 2;
    self.addEmojiLabel.font = [UIFont boldSystemFontOfSize:18];
    self.addEmojiLabel.textAlignment = NSTextAlignmentCenter;
    self.addEmojiLabel.hidden = YES;
    [self.view addSubview:self.addEmojiLabel];
    [self.view sendSubviewToBack:self.addEmojiLabel];
    
    
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:self.portraitHeight];
    self.heightConstraint.priority = UILayoutPriorityRequired - 1;
    
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self hideNoData];
        } else {
            if (self.enableUpdates == YES) {
                [self showNoDataWithMessage:@"You must be connected to the internet to use this keyboard."];
            }
        }
        
        if ([self isOpenAccessGranted] == NO) {
            [self showNoDataWithMessage:@"Full Access must be enabled to use this keyboard."];
        }
    }];
    
    
    [self loadFromDisk:@"categories"];
    [self loadFromDisk:@"emojiwall"];
    
    if (self.enableUpdates == YES) {
        NSString * url = @"emoji/categories";
        MEKeyboardAPIManager * manager = [MEKeyboardAPIManager client];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [self hideNoData];
            NSError * error;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
            [self saveToDisk:jsonData withFilename:@"categories"];
            self.categories = responseObject;
            [self loadedCategoryData];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (self.categories.count == 0) {
                [self showNoDataWithMessage:@"No data recieved. Please connect to the internet."];
                NSMutableArray * arr = [NSMutableArray array];
                [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Keyboard",@"name", nil]];
                self.categories = arr;
            }
            [self.navigationCollectionView reloadData];
        }];
    }
    

    self.keyboardView = [[MEKeyboardNativeView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 216)];
    self.keyboardView.textDocumentProxy = self.textDocumentProxy;
    [self.view addSubview:self.keyboardView];
    self.keyboardView.hidden = YES;
    self.keyboardView.inputViewController = self;

    [[MEKeyboardAPIManager client] beginImageViewSessionWithTag:@"3pk"];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.emojiCollectionView == collectionView) {
        if (self.categories.count > 0) {
            NSString * catName =  [[self.categories objectAtIndex:section] objectForKey:@"name"];
            if ([catName isEqualToString:@"Keyboard"]) {
                return CGSizeZero;
            }
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
            CGSize textSize = [[catName uppercaseString] sizeWithAttributes:attributes];
            textSize.width += 12;
            return textSize;
        }
        return CGSizeMake(50, 30);
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (collectionView == self.emojiCollectionView && kind == UICollectionElementKindSectionHeader) {
        MEKeyboardReusableHeaderView * header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section" forIndexPath:indexPath];
        if (header == nil) {
            header = [[MEKeyboardReusableHeaderView alloc] initWithFrame:CGRectZero];

            //[header addSubview:self.buyAllButton];
        }
        NSString * catName =  [[self.categories objectAtIndex:indexPath.section] objectForKey:@"name"];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
        CGSize textSize = [[catName uppercaseString] sizeWithAttributes:attributes];
        header.sectionLabel.text = [catName uppercaseString];
        [header.sectionLabel sizeToFit];
        return header;
    }
    
    return reusableview;
}



-(NSInteger)leftmostVisibleSection {
    NSArray * visibleItems = [self.emojiCollectionView indexPathsForVisibleItems];
    if (visibleItems.count == 0) {
        return 0;
    }
    NSIndexPath * firstItem = [visibleItems objectAtIndex:0];
    return firstItem.section;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.emojiCollectionView && self.ignoreScrollSelection == NO) {
        NSInteger catIndex = [self leftmostVisibleSection];
        if (self.categories.count > 0 && self.visibleSection != catIndex) {
            self.visibleSection = catIndex;
            [self.navigationCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:catIndex inSection:0]  animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }

}

-(void)meKeyboardNativeView:(MEKeyboardNativeView *)inputView didInsertText:(NSString *)text {
    
    NSString * documentContext = [self.textDocumentProxy documentContextBeforeInput];

    NSUInteger length = documentContext.length;
    self.searchWord = @"";

    if (length > 0 && [[NSCharacterSet letterCharacterSet] characterIsMember:[documentContext characterAtIndex:(length - 1)]]) {
        NSArray * components = [documentContext componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        if (components.count > 0) {
            self.searchWord = [components objectAtIndex:components.count-1];
        }
    }

    
    if (self.searchWord.length > 0) {
        
        NSString * searchStringTrim = [self.searchWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        __weak MEKeyboardViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flashtag contains[c] %@", searchStringTrim];
            NSMutableArray * newResults;
            weakSelf.searchEmoji = [NSMutableArray array];
            
            for (NSString * section in self.allEmoji.allKeys) {
                if (![section isEqualToString:@"Osemoji"]
                    && ![section isEqualToString:@"Trending"]
                    && ![section isEqualToString:@"Audio Emoji"]
                    && ![section isEqualToString:@"Gifs"]
                    && ![section isEqualToString:@"Used"] && ![self isCategoryLocked:section]) {
                    
                    newResults = [NSMutableArray arrayWithArray:[[weakSelf.allEmoji objectForKey:section] filteredArrayUsingPredicate:predicate]];
                    
                    if (newResults.count > 0) {
                        [newResults enumerateObjectsUsingBlock:^(id x, NSUInteger index, BOOL *stop){

                            if ([[[x objectForKey:@"flashtag"] lowercaseString] hasPrefix:[searchStringTrim lowercaseString]]) {
                                [weakSelf.searchEmoji insertObject:x atIndex:0];
                            } else {
                                [weakSelf.searchEmoji addObject:x];
                            }
                            
                        }];
                    }
                }
            
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchCollectionView reloadData];
            });
        });
        
        return;
    }
    
    self.searchEmoji = [NSMutableArray arrayWithArray:[self trendingEmoji]];
    [self.searchCollectionView reloadData];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (size.width > size.height) {
        self.isLandscape = YES;
    } else {
        self.isLandscape = NO;
    }
    
    [self setupLayoutWithSize:size];
}

-(void)viewDidLayoutSubviews {
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
        [(UICollectionViewFlowLayout *)self.navigationCollectionView.collectionViewLayout setMinimumLineSpacing:0];
        [self.navigationCollectionView.collectionViewLayout invalidateLayout];
    }
    else{
        [(UICollectionViewFlowLayout *)self.navigationCollectionView.collectionViewLayout setMinimumLineSpacing:26];
        [self.navigationCollectionView.collectionViewLayout invalidateLayout];
    }

}

-(void)shareKeyboard {
    [self trackShareWithEmojiId:@"0"];
    [self.textDocumentProxy insertText:self.shareText];
}

-(void)deleteBackwards:(UITapGestureRecognizer*)gesture {
    [self.textDocumentProxy deleteBackward];
}

-(void)deleteButtonTapped {
    [self.textDocumentProxy deleteBackward];
    self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(deleteRepeat) userInfo:nil repeats:YES];
}

-(void)deleteButtonRelease {
    [self.deleteTimer invalidate];
    self.deleteTimer = nil;
}

-(void)deleteRepeat {
    [self.textDocumentProxy deleteBackward];
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

-(void)loadedAllEmoji {
    // download all emoji in the bg
    NSMutableArray * allURL = [NSMutableArray array];
    
    for (NSDictionary * cat in self.categories) {
        NSArray * catEmoji = [self.allEmoji objectForKey:[cat objectForKey:@"name"]];
        for (NSDictionary * dict in catEmoji) {
            [allURL addObject:[dict objectForKey:@"image_url"]];
        }
    }
    
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:allURL];

}

-(void)loadTrendingEmoji {
    if (self.enableUpdates == YES) {
        MEKeyboardAPIManager * manager = [MEKeyboardAPIManager client];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSString * url = @"emoji/emojiWall/3pk";
        [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [self hideNoData];
            NSError * error;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
            [self saveToDisk:jsonData withFilename:@"emojiwall"];
            self.allEmoji = responseObject;
            [self loadedAllEmoji];
            [self.emojiCollectionView reloadData];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //NSLog(@"Error: %@", error);
            if (self.allEmoji.allKeys == 0) {
                [self showNoDataWithMessage:@"No data recieved. Please connect to the internet."];
            }
        }];
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

}

-(void)setupConstraint {
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0)
        return;
    
    [self.inputView removeConstraint:self.heightConstraint];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(self.view.frame.size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    self.isLandscape = isLandscape;
    if (isLandscape) {
        self.currentHeight = self.landscapeHeight;
        self.heightConstraint.constant = self.landscapeHeight;
        [self.inputView addConstraint:self.heightConstraint];
    } else {
        self.currentHeight = self.portraitHeight;
        self.heightConstraint.constant = self.portraitHeight;
        [self.inputView addConstraint:self.heightConstraint];
    }

}



-(void)setupLayoutWithSize:(CGSize)size {
    [self.shareButton sizeToFit];
    self.shareButton.frame = CGRectMake(size.width-15-self.shareButton.frame.size.width, 2, self.shareButton.frame.size.width, self.shareButton.frame.size.height);
    
    [self.nextKeyboardButton sizeToFit];
    [self.nextKeyboardButton setFrame:CGRectMake(12, self.currentHeight-35, self.nextKeyboardButton.frame.size.width, 30)];
    
    [self.navigationCollectionView setFrame:CGRectMake(self.nextKeyboardButton.frame.origin.x+self.nextKeyboardButton.frame.size.width+10, self.currentHeight-38, size.width-self.nextKeyboardButton.frame.size.width-12-10-42, 36)];
    
    self.backspaceButton.frame = CGRectMake(self.navigationCollectionView.frame.size.width+self.navigationCollectionView.frame.origin.x+5, self.currentHeight-29, 24, 18);
    
    [self.emojiCollectionView setFrame:CGRectMake(0, 0, size.width, self.currentHeight-36)];
    
    [self.searchCollectionView setFrame:CGRectMake(0, 8, size.width, 36)];
    
    
    self.alertContainerView.frame = CGRectMake(0, 0, 160, 40);
    self.alertContainerView.center = self.view.center;
    self.alertLabel.center = CGPointMake((self.alertContainerView.frame.size.width/2) + 20,self.alertContainerView.frame.size.height/2);
    self.alertImageView.frame = CGRectMake(self.alertLabel.frame.origin.x-38, self.alertLabel.frame.origin.y-6, 30, 30);
    self.addEmojiLabel.frame = CGRectMake(0, 0, size.width, size.height-self.navigationCollectionView.frame.size.height);
    [self hideNoData];
    
    if ([self connected] == NO && self.enableUpdates == YES) {
        [self showNoDataWithMessage:@"Internet access must be enabled to use this keyboard."];
    }
    
    if ([self isOpenAccessGranted] == NO) {
        NSMutableArray * arr = [NSMutableArray array];
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Keyboard",@"name", nil]];
        self.categories = arr;
        [self.navigationCollectionView reloadData];
        [self showNoDataWithMessage:@"Full Access must be enabled to use this keyboard."];
    }
    
    self.keyboardView.frame = CGRectMake(0, size.height-216, size.width, 216);
    
}

-(void)showNoDataWithMessage:(NSString *)message {
    self.fullAccessLabel.text = message;
    self.fullAccessLabel.frame = CGRectMake(0, 0, self.inputView.frame.size.width, self.inputView.frame.size.height-self.navigationCollectionView.frame.size.height);
    [self.view bringSubviewToFront:self.fullAccessLabel];
    self.fullAccessLabel.hidden = NO;
}

-(void)hideNoData {
    self.fullAccessLabel.hidden = YES;
    [self.view sendSubviewToBack:self.fullAccessLabel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupConstraint];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupLayoutWithSize:self.inputView.frame.size];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.navigationCollectionView || collectionView == self.searchCollectionView) {
        return 1;
    }
    return self.categories.count;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.emojiCollectionView) {
        if ([cell isKindOfClass:[MEKeyboardEmojiCollectionViewCell class]]) {
            MEKeyboardEmojiCollectionViewCell * newCell = (MEKeyboardEmojiCollectionViewCell* ) cell;
            newCell.imageView.image = nil;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.emojiCollectionView || collectionView == self.searchCollectionView) {
        if ([cell isKindOfClass:[MEKeyboardEmojiCollectionViewCell class]]) {
            MEKeyboardEmojiCollectionViewCell * emojiCell = (MEKeyboardEmojiCollectionViewCell* ) cell;
                
            NSDictionary * dict;
            if (collectionView == self.searchCollectionView) {
                dict = [self.searchEmoji objectAtIndex:indexPath.item];
            } else {
                dict = [[self selectedCategoryDataForSection:indexPath.section] objectAtIndex:indexPath.item];
            }
            
            NSString * imageUrl;
            NSURL * url;
            if (![[dict objectForKey:@"image_url"] hasPrefix:@"https://"]) {
                url = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[dict objectForKey:@"image_url"]]];
            } else {
                url = [NSURL URLWithString:[dict objectForKey:@"image_url"]];
            }
            
            
            if ([[dict objectForKey:@"gif"] boolValue] == YES && [dict objectForKey:@"40x40_url"]) {
                [emojiCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"40x40_url"]] placeholderImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/emojiplaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
                
            } else {
                NSString * imageUrl = [[dict objectForKey:@"image_url"] stringByReplacingOccurrencesOfString:@"-256" withString:@""];
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"@2x.png" withString:@"-large@2x.png"];
                [emojiCell.imageView sd_setImageWithURL:[self urlForPath:imageUrl] placeholderImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/emojiplaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] options:SDWebImageHighPriority completed:nil];
                
            }

        }
    
    }
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.navigationCollectionView) {
        return [self.categories count];
    }
    
    if (collectionView == self.searchCollectionView) {
        return [self.searchEmoji count];
    }
    
    return [[self selectedCategoryDataForSection:section] count];
}

-(BOOL)isCategoryLocked:(NSString *)categoryName {
    for (NSDictionary * cat in self.categories) {
        if ([cat objectForKey:@"locked"] && [[cat objectForKey:@"locked"] boolValue] == YES && [[cat objectForKey:@"name"] isEqualToString:categoryName]) {
            return YES;
        }
    }
    return NO;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView == self.navigationCollectionView) {
        MEKeyboardNavigationCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Category" forIndexPath:indexPath];
        NSDictionary * dict = [self.categories objectAtIndex:indexPath.row];
        NSString * imageName = [NSString stringWithFormat:@"MEKeyboard-%@", [[[dict objectForKey:@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        
        if ([imageName isEqualToString:@"MEKeyboard-keyboard"]) {
            imageName = self.keyboardImageName;
        }
        
        UIImage * catImage = [UIImage imageNamed:[NSString stringWithFormat:@"MakemojiSDK-KeyboardExtension.bundle/%@", imageName] inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        
        photoCell.imageView.image = nil;
        
        if (catImage != nil) {
            [photoCell.imageView setImage:catImage];
        } else {
            [photoCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:nil];
        }

        photoCell.backgroundColor = [UIColor clearColor];
        photoCell.layer.cornerRadius = 15;
        return photoCell;
    }

    NSDictionary * dict;
    if (collectionView == self.searchCollectionView) {
        dict = [self.searchEmoji objectAtIndex:indexPath.item];
    } else {
        dict = [[self selectedCategoryDataForSection:indexPath.section] objectAtIndex:indexPath.item];
    }
    
    NSDictionary * catDict = [self.categories objectAtIndex:indexPath.section];
    [[MEKeyboardAPIManager client] imageViewWithId:[dict objectForKey:@"id"]];

    if ([self isCategoryVideoCollection:indexPath.section]) {
        MEKeyboardVideoCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Video" forIndexPath:indexPath];
        emojiCell.previewImage.image = nil;
        emojiCell.emojiLabel.text = [dict objectForKey:@"name"];
        emojiCell.emojiLabel.textColor = [UIColor blackColor];
        [emojiCell.previewImage sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/emojiplaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        return emojiCell;
    }
    
    if ([[catDict objectForKey:@"gif"] boolValue] == YES) {
        MEKeyboardGifCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojiGif" forIndexPath:indexPath];
        emojiCell.imageView.image = nil;
        [emojiCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"MakemojiSDK-KeyboardExtension.bundle/emojiplaceholder" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        
        return emojiCell;
    }

    MEKeyboardEmojiCollectionViewCell * emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
//    NSString * imageUrl;
//    NSURL * url;
//    if (![[dict objectForKey:@"image_url"] hasPrefix:@"https://"]) {
//       url = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[dict objectForKey:@"image_url"]]];
//    } else {
//        url = [NSURL URLWithString:[dict objectForKey:@"image_url"]];
//    }
//
//    
//    if ([[dict objectForKey:@"gif"] boolValue] == YES && [dict objectForKey:@"40x40_url"]) {
//        [emojiCell.imageView sd_setImageWithURL:[self urlForPath:[dict objectForKey:@"40x40_url"]] placeholderImage:[UIImage imageNamed:@"emojiplaceholder"]];
//    } else {
//
//        
//        NSString * imageUrl = [[dict objectForKey:@"image_url"] stringByReplacingOccurrencesOfString:@"-256" withString:@""];
//        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"@2x.png" withString:@"-large@2x.png"];
//        [emojiCell.imageView sd_setImageWithURL:[self urlForPath:imageUrl] placeholderImage:[UIImage imageNamed:@"emojiplaceholder"] options:SDWebImageHighPriority completed:nil];
//
//    }
    return emojiCell;
    
}


-(void)shareEmojiWithDictionary:(NSDictionary *)emojiDict {
    emojiDict = self.lastSharedEmoji;
    NSString * path = [[SDImageCache sharedImageCache] defaultCachePathForKey:[[self urlForPath:[emojiDict objectForKey:@"image_url"]] absoluteString]];
    NSLog(@"got to share", path);
    if (![[emojiDict objectForKey:@"image_url"] hasPrefix:@"https://"]) {
        path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[emojiDict objectForKey:@"image_url"]];
    }
    
    if ([emojiDict objectForKey:@"video"] != nil && [[emojiDict objectForKey:@"video"] boolValue] == YES) {
        
        NSURL *URL = [NSURL URLWithString:[emojiDict objectForKey:@"video_url"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSString *fileName = [URL lastPathComponent];
        self.activityIndicator.center = self.view.center;
        [self.activityIndicator startAnimating];
        NSString *pathToFile = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:fileName];
        if (![[emojiDict objectForKey:@"image_url"] hasPrefix:@"https://"]) {
            pathToFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[emojiDict objectForKey:@"video_url"]];
        }
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:pathToFile];
        if (data != nil) {
            [self showCopiedAlertWithImageURL:[emojiDict objectForKey:@"image_url"]];
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setData:data forPasteboardType:@"public.mpeg-4"];
            [self.activityIndicator stopAnimating];
            return;
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:pathToFile];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:filePath];
            if (data != nil) {
                [self.view bringSubviewToFront:self.alertContainerView];
                self.alertContainerView.center = self.view.center;
                [self.alertImageView sd_setImageWithURL:[self urlForPath:[emojiDict objectForKey:@"image_url"]]];
                [UIView animateWithDuration:0.3 animations:^{
                    self.alertContainerView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.alertContainerView.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        //[self.view sendSubviewToBack:self.alertContainerView];
                    }];
                }];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setData:data forPasteboardType:@"public.mpeg-4"];
            }
            [self.activityIndicator stopAnimating];
        }];
        [downloadTask resume];
        
    } else if ([[emojiDict objectForKey:@"gif"] boolValue] == YES) {
        
        [self showCopiedAlertWithImageURL:[emojiDict objectForKey:@"40x40_url"]];
        
        if (![[emojiDict objectForKey:@"image_url"] hasPrefix:@"https://"]) {
            path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[emojiDict objectForKey:@"image_url"]];
        }
        
        NSData * data = [NSData dataWithContentsOfFile:path];
        if (data == nil) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];

            [manager loadImageWithURL:[self urlForPath:[emojiDict objectForKey:@"image_url"]] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                NSString * newpath = [[SDImageCache sharedImageCache] defaultCachePathForKey:[[self urlForPath:[emojiDict objectForKey:@"image_url"]]absoluteString]];
                NSData * newdata = [NSData dataWithContentsOfFile:newpath];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setData:newdata forPasteboardType:@"com.compuserve.gif"];
            }];
            
            
            
//            [manager downloadImageWithURL:[self urlForPath:[emojiDict objectForKey:@"image_url"]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                NSString * newpath = [[SDImageCache sharedImageCache] defaultCachePathForKey:[[self urlForPath:[emojiDict objectForKey:@"image_url"]]absoluteString]];
//                NSData * newdata = [NSData dataWithContentsOfFile:newpath];
//                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//                [pasteboard setData:newdata forPasteboardType:@"com.compuserve.gif"];
//            }];
            
            return;
        }
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:data forPasteboardType:@"com.compuserve.gif"];
        
    } else {
        
        [self showCopiedAlertWithImageURL:[emojiDict objectForKey:@"image_url"]];
        
        [self trackShareWithEmojiId:[emojiDict objectForKey:@"id"]];
        
        NSData * data = [NSData dataWithContentsOfFile:path];
        if (data == nil) { return; }
        
        CGImageSourceRef imageRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
        if (!imageRef)
            return;
        
        CFDictionaryRef imagePropertiesDict = CGImageSourceCopyPropertiesAtIndex(imageRef, 0, NULL);
        NSString *dpiWidth = CFDictionaryGetValue(imagePropertiesDict, @"DPIWidth");
        if (dpiWidth == nil) { dpiWidth = @"72"; }
        NSNumber * dpiNum = [NSNumber numberWithInteger:[dpiWidth integerValue]];
        
        CGFloat scaleFactor = 1.0;
        
        scaleFactor = dpiNum.floatValue / 72.0f;
        
        //scaleFactor = 1.0;
        
        UIImage * emojiImage = [UIImage imageWithData:data scale:scaleFactor];
        
        if (!emojiImage)
            return;
        
        data = nil;
        
        CGSize outputSize = CGSizeMake(((self.emojiInnerSize.width*scaleFactor) + (self.outputSize.width-self.emojiInnerSize.width))/scaleFactor, ((self.emojiInnerSize.height*scaleFactor) + (self.outputSize.height-self.emojiInnerSize.height))/scaleFactor);
        CGRect outputRect = (CGRect) {
            .origin = CGPointZero,
            .size = outputSize
        };
        
        CGRect imageRect = (CGRect) {
            .origin = CGPointZero,
            .size = self.emojiInnerSize
        };
        
        CGRect centeredRect = xCGRectCenteredInRect(imageRect, outputRect);
        
        UIGraphicsBeginImageContextWithOptions(outputSize, NO, scaleFactor);
        [emojiImage drawInRect:CGRectMake(centeredRect.origin.x, centeredRect.origin.y, self.emojiInnerSize.width, self.emojiInnerSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:UIImagePNGRepresentation(newImage) forPasteboardType:@"public.png"];
        
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.navigationCollectionView) {
        
        NSDictionary * dict = [self.categories objectAtIndex:indexPath.row];
        
        if ([[dict objectForKey:@"name"] isEqualToString:@"Keyboard"]) {
            [self showKeyboard:YES];
            return;
        }
        
        self.ignoreScrollSelection = YES;
        self.emojiCollectionView.hidden = NO;
        self.keyboardView.hidden = YES;
        self.backspaceButton.hidden = NO;
        [self.navigationCollectionView setFrame:CGRectMake(self.nextKeyboardButton.frame.origin.x+self.nextKeyboardButton.frame.size.width+10, self.portraitHeight-self.navigationCollectionView.frame.size.height, self.inputView.frame.size.width-self.nextKeyboardButton.frame.size.width-12-10-42, self.navigationCollectionView.frame.size.height)];
        
        self.addEmojiLabel.hidden = YES;

        
        if ([[self selectedCategoryDataForSection:indexPath.row] count] > 0 ) {
             [self.emojiCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }

        if (self.disableNavScrolling == NO) {
            [self.navigationCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
        
        self.ignoreScrollSelection = NO;
        [self didSelectCategory:dict atIndexPath:indexPath];
        return;
    }
    
     NSDictionary * emojiDict;
    __weak MEKeyboardViewController * weakSelf = self;
    
    if (collectionView == self.searchCollectionView) {
        emojiDict = [self.searchEmoji objectAtIndex:indexPath.item];
    } else {
        emojiDict = [[self selectedCategoryDataForSection:indexPath.section] objectAtIndex:indexPath.row];
    }
    self.lastSharedEmoji = emojiDict;
    
    //NSLog(@"share");
    
    if ([[SDImageCache sharedImageCache] imageFromCacheForKey:[[self urlForPath:[emojiDict objectForKey:@"image_url"]] absoluteString]]) {
        //NSLog(@"shared from cache");
        [self shareEmojiWithDictionary:emojiDict];
        return;
    }
    
    //NSLog(@"cache miss");
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[self urlForPath:[emojiDict objectForKey:@"image_url"]] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shareEmojiWithDictionary:emojiDict];
        });

    }];
    
}

-(void)showCopiedAlertWithImageURL:(NSString *)imageUrl {
    [self.alertImageView sd_setImageWithURL:[self urlForPath:imageUrl]];
    [self.view bringSubviewToFront:self.alertContainerView];
    self.alertContainerView.center = self.view.center;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alertContainerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alertContainerView.alpha = 0.0;
        } completion:^(BOOL finished) {

        }];
    }];
}




- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.emojiCollectionView) {
        NSString * catName =  [[self.categories objectAtIndex:section] objectForKey:@"name"];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]};
        CGSize textSize = [[catName uppercaseString] sizeWithAttributes:attributes];
        
        return UIEdgeInsetsMake(31, -(textSize.width+12), 0, 35);
    }
    return UIEdgeInsetsZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.navigationCollectionView) {
        return CGSizeMake(30,30);
    }
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    if (self.categories.count > 0) {
        
        if ([self isCategoryVideoCollection:indexPath.section]) {
            CGSize size = CGSizeMake(frame.size.width/2, (collectionView.frame.size.height)-31);
            return size;
        }
        
        NSDictionary * selectedCategory = [self.categories objectAtIndex:indexPath.section];
        if ([[selectedCategory objectForKey:@"gif"] boolValue] == YES) {
            CGSize size = CGSizeMake(frame.size.width/3, (collectionView.frame.size.height/2)-19);
            return size;
        }
    }
    
    CGFloat width = frame.size.width;
    if (width > frame.size.height) { width = frame.size.height; }
    
    return CGSizeMake(width/8,34);
}


-(NSURL*)urlForPath:(NSString *)path {
    NSString * imageUrl;
    NSURL * url;
    if (![path hasPrefix:@"https://"] && ![path hasPrefix:@"http://"]) {
        url = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:path]];
    } else {
        url = [NSURL URLWithString:path];
    }
    return url;
}


-(void)meKeyboardNativeView:(MEKeyboardNativeView *)inputView didTapEmojiButton:(UIButton *)button {
    [self showKeyboard:NO];
}

-(NSArray *)trendingEmoji {
    if ([self.allEmoji objectForKey:@"Trending"] && [[self.allEmoji objectForKey:@"Trending"] isKindOfClass:[NSArray class]]) {
        return [self.allEmoji objectForKey:@"Trending"];
    }
    return [NSArray array];
    
}

-(void)meKeyboardNativeView:(MEKeyboardNativeView *)inputView didTapGlobeButton:(UIButton *)button {
    [self advanceToNextInputMode];
}

-(void)showKeyboard:(BOOL)show {
    if (show) {
        [self hideNoData];
        self.searchCollectionView.hidden = NO;
        self.searchEmoji = [NSMutableArray arrayWithArray:[self trendingEmoji]];
        [self.searchCollectionView reloadData];
        [self.keyboardView updateLayout:self.keyboardView.frame];
        [self.inputView setBackgroundColor:self.keyboardView.backgroundColor];
        [self.view setBackgroundColor:self.keyboardView.backgroundColor];
        self.shareButton.frame = CGRectMake(self.shareButton.frame.origin.x, 13, self.shareButton.frame.size.width, self.shareButton.frame.size.height);
        self.keyboardView.hidden = NO;
        self.shareButton.hidden = YES;
        self.emojiCollectionView.hidden = YES;
    } else {
        self.shareButton.hidden = NO;
        self.searchCollectionView.hidden = YES;
        self.shareButton.frame = CGRectMake(self.inputView.frame.size.width-15-self.shareButton.frame.size.width, 2, self.shareButton.frame.size.width, self.shareButton.frame.size.height);
        [self.inputView setBackgroundColor:self.mainBackgroundColor];
        [self.view setBackgroundColor:self.mainBackgroundColor];

        self.keyboardView.hidden = YES;
        self.emojiCollectionView.hidden = NO;

        if ([self connected] == NO && self.enableUpdates == YES) {
            [self showNoDataWithMessage:@"Internet access must be enabled to use this keyboard."];
        }
        
        if ([self isOpenAccessGranted] == NO) {
            [self showNoDataWithMessage:@"Full Access must be enabled to use this keyboard."];
        }
    }
}

-(void)didSelectCategory:(NSDictionary *)category atIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSArray *)selectedCategoryDataForSection:(NSInteger *)section {
    if (self.categories.count > 0) {
        NSString * catName = [[self.categories objectAtIndex:section] objectForKey:@"name"];
        return [self.allEmoji objectForKey:catName];
    }
    return [NSArray array];
}

-(BOOL)isCategoryVideoCollection:(NSInteger)index {
    BOOL returnVal = NO;
    if ([[self selectedCategoryDataForSection:index] count] > 0) {
        NSDictionary * dict = [[self selectedCategoryDataForSection:index] objectAtIndex:0];
        if ([dict objectForKey:@"video"] != nil && [[dict objectForKey:@"video"] integerValue] == 1) {
            returnVal = YES;
        } else {
            returnVal = NO;
        }
    }
    return returnVal;
}

-(void)loadedCategoryData {
    NSMutableArray * arr = [NSMutableArray arrayWithArray:self.categories];
    int phrasesIndex = 0;
    for (NSDictionary * dict in arr) {
        if ([[dict objectForKey:@"name"] isEqualToString:@"Phrases"]) {
            phrasesIndex = (int)[arr indexOfObject:dict];
        }
    }
    
    if (phrasesIndex > 0) {
        [arr removeObjectAtIndex:phrasesIndex];
    }
    if (self.enableUsed == YES) {
        [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Used",@"name", nil] atIndex:0];
    }
    
    if (self.enableTrending == YES) {
        [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Trending",@"name", nil] atIndex:0];
    }
        
    [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"http://",@"image_url",@"Keyboard",@"name", nil] atIndex:arr.count];

    self.categories = arr;
    [self.navigationCollectionView reloadData];
    [self.navigationCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self loadTrendingEmoji];
}

-(void)saveToDisk:(NSData *)data withFilename:(NSString *)filename {
    NSString * filenameAddition = [NSString stringWithFormat:@"%@-%@", filename, [[NSBundle mainBundle] bundleIdentifier]];
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:filenameAddition];
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:data
                                          attributes:nil];
}

-(BOOL)loadFromDisk:(NSString *)filename {
    NSString *path;
    
    NSString *buildpath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSString * filenameAddition = [NSString stringWithFormat:@"%@-%@", filename, [[NSBundle mainBundle] bundleIdentifier]];
    NSString *cachePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:filenameAddition];

    if ([[NSFileManager defaultManager] fileExistsAtPath:buildpath]) {
        path = buildpath;
        [[SDImageCache sharedImageCache] addReadOnlyCachePath:[[NSBundle mainBundle] bundlePath]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] && self.enableUpdates == YES) {
        path = cachePath;
    }
    
    if (path == nil) { return NO; }
    
    NSError * error;

    NSURL *url = [NSURL fileURLWithPath:path];
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    if (data != nil) {
        id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonResponse != nil) {
    
            if ([filename isEqualToString:@"categories"]) {
                self.categories = jsonResponse;
                [self loadedCategoryData];
            } else if ([filename isEqualToString:@"emojiwall"]) {
                self.allEmoji = jsonResponse;
            }
        
            [self.emojiCollectionView reloadData];
            return YES;
        
        }
    
    }
    return NO;
}

-(BOOL)isOpenAccessGranted {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard) {
        return YES;
    } else {
        return NO;
    }
}



- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)trackShareWithEmojiId:(NSString *)emojiId {
    MEKeyboardAPIManager *manager = [MEKeyboardAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString * user_id = self.userId;
    if (user_id == nil) { user_id = @"0"; }
    NSString * url = [NSString stringWithFormat:@"emoji/share/%@/%@/%@", user_id, emojiId, @"emoji"];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"Error: %@", error);
    }];
}


-(void)dealloc {
    [[MEKeyboardAPIManager client] endImageViewSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {

}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

@end
