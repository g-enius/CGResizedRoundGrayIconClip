//
//  UILabel+LDPMLive.m
//  PreciousMetals
//
//  Created by wangchao on 1/15/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "UILabel+LDPMLive.h"

@implementation UILabel (LDPMLive)

- (void)insertIconToFront:(UIImage *)icon
{
    //1.创建一个可变属性字符串
    NSMutableAttributedString *strWithIcon = [NSMutableAttributedString new];
    //2.创建图片附件
    NSTextAttachment *attach = [[NSTextAttachment alloc]init];
    attach.image = icon;
    attach.bounds = CGRectMake(0, -4, icon.size.width, icon.size.height);
    //3.创建属性字符串 通过图片附件
    NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attach];
    //4.把NSAttributedString添加到NSMutableAttributedString里面
    [strWithIcon appendAttributedString:attachStr];
    //调整一下图片和文字之间的距离
    NSString *textWithSpace = [NSString stringWithFormat:@"  %@",self.text];
    NSAttributedString *text = [[NSAttributedString alloc]initWithString:textWithSpace];
    [strWithIcon appendAttributedString:text];
    //5.设置间距
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 5.;
    [strWithIcon addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strWithIcon.length)];
    self.attributedText = strWithIcon;
}

@end
