//
//  UIImage+LDPMLive.h
//  PreciousMetals
//
//  Created by wangchao on 1/17/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(LDPMLive)

- (UIImage *)resizedRoundImageWithDiameter:(CGFloat)diameter borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;
- (UIImage *)ld_GrayScaleImage;

@end
