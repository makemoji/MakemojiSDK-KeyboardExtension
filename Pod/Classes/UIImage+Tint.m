//
//  UIImage+Tint.m
//
//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.
//

#import "UIImage+Tint.h"


@implementation UIImage (MGTint)


- (UIImage *)imageTintedWithColor:(UIColor *)color
{
	// This method is designed for use with template images, i.e. solid-coloured mask-like images.
	return [self imageTintedWithColor:color fraction:0.0]; // default to a fully tinted mask of the image.
}


- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction
{
	if (color) {
		// Construct new image the same size as this one.
		UIImage *image;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
		if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
			UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f); // 0.f for scale means "scale for device's main screen".
		} else {
			UIGraphicsBeginImageContext([self size]);
		}
#else
		UIGraphicsBeginImageContext([self size]);
#endif
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		// Composite tint color at its own opacity.
		[color set];
		UIRectFill(rect);
		
		// Mask tint color-swatch to this image's opaque mask.
		// We want behaviour like NSCompositeDestinationIn on Mac OS X.
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		
		// Finally, composite this image over the tinted mask at desired opacity.
		if (fraction > 0.0) {
			// We want behaviour like NSCompositeSourceOver on Mac OS X.
			[self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
		}
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	
	return self;
}

/*
 * Calculates the insets of transparency around all sides of the image
 *
 * @param fullyOpaque
 *        Whether the algorithm should consider pixels with an alpha value of something other than 255 as being transparent. Otherwise a non-zero value would be considered opaque.
 */
- (UIEdgeInsets)transparencyInsetsRequiringFullOpacity:(BOOL)fullyOpaque
{
    // Draw our image on that context
    NSInteger width  = (NSInteger)CGImageGetWidth([self CGImage]);
    NSInteger height = (NSInteger)CGImageGetHeight([self CGImage]);
    NSInteger bytesPerRow = width * (NSInteger)sizeof(uint8_t);
    
    // Allocate array to hold alpha channel
    uint8_t * bitmapData = calloc((size_t)(width * height), sizeof(uint8_t));
    
    // Create alpha-only bitmap context
    CGContextRef contextRef = CGBitmapContextCreate(bitmapData, (NSUInteger)width, (NSUInteger)height, 8, (NSUInteger)bytesPerRow, NULL, kCGImageAlphaOnly);
    
    CGImageRef cgImage = self.CGImage;
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(contextRef, rect, cgImage);
    
    // Sum all non-transparent pixels in every row and every column
    uint16_t * rowSum = calloc((size_t)height, sizeof(uint16_t));
    uint16_t * colSum = calloc((size_t)width,  sizeof(uint16_t));
    
    // Enumerate through all pixels
    for (NSInteger row = 0; row < height; row++) {
        
        for (NSInteger col = 0; col < width; col++) {
            
            if (fullyOpaque) {
                
                // Found non-transparent pixel
                if (bitmapData[row*bytesPerRow + col] == UINT8_MAX) {
                    
                    rowSum[row]++;
                    colSum[col]++;
                    
                }
                
            } else {
                
                // Found non-transparent pixel
                if (bitmapData[row*bytesPerRow + col]) {
                    
                    rowSum[row]++;
                    colSum[col]++;
                    
                }
                
            }
            
        }
        
    }
    
    // Initialize crop insets and enumerate cols/rows arrays until we find non-empty columns or row
    UIEdgeInsets crop = UIEdgeInsetsZero;
    
    // Top
    for (NSInteger i = 0; i < height; i++) {
        
        if (rowSum[i] > 0) {
            
            crop.top = i;
            break;
            
        }
        
    }
    
    // Bottom
    for (NSInteger i = height - 1; i >= 0; i--) {
        
        if (rowSum[i] > 0) {
            crop.bottom = MAX(0, height - i - 1);
            break;
        }
        
    }
    
    // Left
    for (NSInteger i = 0; i < width; i++) {
        
        if (colSum[i] > 0) {
            crop.left = i;
            break;
        }
        
    }
    
    // Right
    for (NSInteger i = width - 1; i >= 0; i--) {
        
        if (colSum[i] > 0) {
            
            crop.right = MAX(0, width - i - 1);
            break;
            
        }
    }
    
    free(bitmapData);
    free(colSum);
    free(rowSum);
    
    CGContextRelease(contextRef);
    
    return crop;
}

/*
 * Original method signature; behavior should be identical.
 */
- (UIImage *)imageByTrimmingTransparentPixels
{
    return [self imageByTrimmingTransparentPixelsRequiringFullOpacity:NO];
}

/*
 * Alternative method signature allowing for the use of cropping based on semi-transparency.
 */
- (UIImage *)imageByTrimmingTransparentPixelsRequiringFullOpacity:(BOOL)fullyOpaque
{
    if (self.size.height < 2 || self.size.width < 2) {
        
        return self;
        
    }
    
    CGRect rect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    UIEdgeInsets crop = [self transparencyInsetsRequiringFullOpacity:fullyOpaque];
    
    UIImage *img = self;
    
    if (crop.top == 0 && crop.bottom == 0 && crop.left == 0 && crop.right == 0) {
        
        // No cropping needed
        
    } else {
        
        // Calculate new crop bounds
        rect.origin.x += crop.left;
        rect.origin.y += crop.top;
        rect.size.width -= crop.left + crop.right;
        rect.size.height -= crop.top + crop.bottom;
        
        // Crop it
        CGImageRef newImage = CGImageCreateWithImageInRect([self CGImage], rect);
        
        // Convert back to UIImage
        img = [UIImage imageWithCGImage:newImage scale:self.scale orientation:self.imageOrientation];
        
        CGImageRelease(newImage);
    }
    
    return img;
}


@end

CGRect xCGRectCenteredInRect(CGRect rectToCenter, CGRect rectToCenterIn) {
    rectToCenter.size.width = MIN(rectToCenter.size.width, rectToCenterIn.size.width);
    rectToCenter.size.height = MIN(rectToCenter.size.height, rectToCenterIn.size.height);
    
    CGSize rectToCenterSize = rectToCenter.size;
    return (CGRect){
        (CGPoint){
            ceilf(CGRectGetMidX(rectToCenterIn) - rectToCenterSize.width/2.0f),
            ceilf(CGRectGetMidY(rectToCenterIn) - rectToCenterSize.height/2.0f)
        },
        rectToCenterSize
    };
}

