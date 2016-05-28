//
//  UIImage+LDPMLive.m
//  PreciousMetals
//
//  Created by wangchao on 1/17/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "UIImage+LDPMLive.h"

@implementation UIImage(LDPMLive)

//与下面方法等效, 只不过CGContextAddEllipseInRect自动负责创建, 加到画布上和回收path
- (UIImage *)resizedRoundImageWithDiameter:(CGFloat)diameter borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth
{
    CGFloat newWidthWithBorder = diameter + borderWidth * 2;
    //创建图片上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidthWithBorder, newWidthWithBorder), NO, 0);
    //UIGraphicsBeginImageContext(CGSizeMake(resizedImage.size.width, resizedImage.size.height));//这种默认scale不为0, 会导致图像失真
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //每次创建一个圆, 由于border的宽度是向外伸展的, 所以stroke的时候传的内部小圆的半径; 如果是填充圆,则半径应该传外部圆半径.
    CGContextAddEllipseInRect(context, CGRectMake(borderWidth, borderWidth, diameter, diameter));
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);//fill的画不用写这句
    //与CGContextFillPath(context) 和 CGContextClip(context) 一样, 执行一次, 就把该path花在画布上, 此path就不能再用了.
    CGContextStrokePath(context);
    
    //再画一个圆,并剪切画布,之后只能在剪切区域内画图.
    CGContextAddEllipseInRect(context, CGRectMake(borderWidth, borderWidth, diameter, diameter));
    CGContextClip(context);
    
    //绘制头像
    [self drawInRect:CGRectMake(borderWidth, borderWidth, diameter, diameter)];
    //取出整个图片上下文的图片
    UIImage *roundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundImage;
}
//
//- (UIImage *)resizedRoundImageWithDiameter:(CGFloat)diameter borderWidth:(CGFloat)borderWidth
//{
//    CGFloat newWidthWithBorder = diameter + borderWidth * 2;
//    CGFloat newRadiusWithBorder = newWidthWithBorder / 2.;
//    //创建图片上下文
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidthWithBorder, newWidthWithBorder), NO, 0);
//    //UIGraphicsBeginImageContext(CGSizeMake(resizedImage.size.width, resizedImage.size.height));//这种默认scale不为0, 会导致图像失真
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    //每次创建一个圆, 由于border的宽度是向外伸展的, 所以stroke的时候传的内部小圆的半径; 如果是填充圆,则半径应该传外部圆半径.
//    CGMutablePathRef borderPath = CGPathCreateMutable();
//    CGPathAddArc(borderPath, NULL, newRadiusWithBorder, newRadiusWithBorder, newRadiusWithBorder, 0, 2. * M_PI, YES);
//    CGContextAddPath(context, borderPath);
//    CGContextSetFillColorWithColor(context, [NPMColor seplineColor].CGColor);
//    //与CGContextStrokePath(context) 和 CGContextClip(context) 一样, 执行一次, 就把该path花在画布上, 此path就不能再用了.
//    CGContextFillPath(context);
//    CGPathRelease(borderPath);
//    
//    //再画一个圆,并剪切画布,之后只能在剪切区域内画图.
//    CGMutablePathRef borderPath1 = CGPathCreateMutable();
//    CGPathAddArc(borderPath1, NULL, newRadiusWithBorder, newRadiusWithBorder, diameter, 0, 2. * M_PI, YES);
//    CGContextAddPath(context, borderPath1);
//    CGContextClip(context);
//    CGPathRelease(borderPath1);
//    
//    //绘制头像
//    [self drawInRect:CGRectMake(borderWidth, borderWidth, diameter, diameter)];
//    //取出整个图片上下文的图片
//    UIImage *roundImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return roundImage;
//}

- (UIImage *)ld_GrayScaleImage
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, 0);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [self CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}


@end
