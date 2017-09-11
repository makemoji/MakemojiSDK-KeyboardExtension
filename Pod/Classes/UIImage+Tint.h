//
//  UIImage+Tint.h
//
//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.
//

#import <UIKit/UIKit.h>

CGRect xCGRectCenteredInRect(CGRect rectToCenter, CGRect rectToCenterIn);

@interface UIImage (MGTint)

- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;

- (UIEdgeInsets)transparencyInsetsRequiringFullOpacity:(BOOL)fullyOpaque;
- (UIImage *)imageByTrimmingTransparentPixels;
- (UIImage *)imageByTrimmingTransparentPixelsRequiringFullOpacity:(BOOL)fullyOpaque;


@end
