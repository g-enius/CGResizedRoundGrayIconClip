//
//  LDPMLiveDetailNewsWithImageCell.m
//  PreciousMetals
//
//  Created by Ding Yi on 15/10/14.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "LDPMLiveDetailNewsWithImageCell.h"
#import "NIAttributedLabel.h"
#import "LDPMLiveDetailNews.h"
#import "LDPMLiveDetailNewsImage.h"
#import "NSString+NPMUtil.h"
#import "LDPMLiveDetailNewsWithImageBgView.h"
#import "LDCPCirclePhoto.h"
#import "LDRoutes.h"
#import "NSDate+NTBasicAdditions.h"
#import "UIImage+LDPMLive.h"
#import "SDImageCache+LDPMLive.h"
#import "UILabel+LDPMLive.h"

static CGFloat const analystIconHeight = 31.;
static NSString * const avatarPlaceholderImageKey = @"LDPMLiveRoomAvatarPlaceholder";

@interface LDPMLiveDetailNewsWithImageCell ()<NIAttributedLabelDelegate, LDCPCirclePhotoDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsLabelHeightConstraint;

@end

@implementation LDPMLiveDetailNewsWithImageCell

- (void)setContentWithNews:(LDPMLiveDetailNews *)news
{
    UIImage *image = [UIImage imageNamed:@"LiveRoom_NewsBackground"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(35, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    self.bgImageView.image = image;
    
    static NSDateFormatter *timeFormatter;
    if (!timeFormatter) {
        timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"HH:mm";
    }
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MM-dd";
    }
    
    if ([news.createTime isSameDayWithDate:[NSDate date]]) {
        self.dateLabel.text = nil;
    } else {
        self.dateLabel.text = [dateFormatter stringFromDate:news.createTime];
    }
    self.timeLabel.text = [timeFormatter stringFromDate:news.createTime];
    self.newsLabel.linkColor = [UIColor colorWithRGB:0x5e8bbb];
    self.newsLabel.delegate = self;
    self.newsLabel.lineHeight = 21.7;
    self.newsLabel.text = news.content;

    UIEdgeInsets niLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7.5);
    
    SDImageCache *cache = [SDImageCache sharedImageCache];
    
    UIImage *placeholder = [cache imageFromMemoryCacheForKey:avatarPlaceholderImageKey];
    if (!placeholder) {
        placeholder = [[UIImage imageNamed:@"avatar_placeholder"] resizedRoundImageWithDiameter:analystIconHeight borderColor:[NPMColor seplineColor] borderWidth:1];
        [cache storeImage:placeholder forKey:avatarPlaceholderImageKey toDisk:NO];
    }
    
    __block UIImage *avatar = [cache imageFromMemoryCacheForKey:[cache ld_RoundScaleImageKeyForImageURL:[NSURL URLWithString:news.analystIconUrl]]];
    if (avatar) {
        [self.newsLabel insertImage:avatar atIndex:0 margins:niLabelEdgeInsets];
    } else {
        
        [self.newsLabel insertImage:placeholder atIndex:0 margins:niLabelEdgeInsets];
        @weakify(self)
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:news.analystIconUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self)
            if (image) {
                avatar = [image resizedRoundImageWithDiameter:analystIconHeight borderColor:[NPMColor seplineColor] borderWidth:1];
                [cache storeImage:avatar forKey:[cache ld_RoundScaleImageKeyForImageURL:[NSURL URLWithString:news.analystIconUrl]] toDisk:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.newsLabel.text = news.content;
                    [self.newsLabel insertImage:avatar atIndex:0 margins:niLabelEdgeInsets];
                });
            }
        }];
    }
    
    self.newsLabelHeightConstraint.constant = [self calcNILabelHeightWithText:news.content Icon:placeholder];

    if (news.linkInfoArray.count > 0) {
        for (NSDictionary *dic in news.linkInfoArray) {
            NSValue *value = [dic objectForKey:LDPMLiveDetailNewsKeyAtRange];
            NSString *url = [dic objectForKey:LDPMLiveDetailNewsKeyLinkInfo];
            [self.newsLabel addLink:[NSURL URLWithString:url] range:value.rangeValue];
        }
    }

    if (news.imageList.count > 0) {
        self.newsImageView.hidden = NO;
        LDPMLiveDetailNewsImage *imageInfo = news.imageList.firstObject;
        self.newsImageViewWidthLayoutConstraint.constant = [LDPMLiveDetailNewsWithImageCell imageSize:imageInfo].width;
        self.newsImageViewHeightLayoutConstraint.constant = [LDPMLiveDetailNewsWithImageCell imageSize:imageInfo].height;
        self.newsLabelBottomToImageViewTopLayoutConstraint.constant = -10;

        self.newsImageView.photoContentMode = UIViewContentModeScaleAspectFit;
        self.newsImageView.placeholderContentMode = UIViewContentModeScaleAspectFit;
        self.newsImageView.clipsToBounds = YES;
        self.newsImageView.delegate = self;
        self.newsImageView.identifier = self;
        self.newsImageView.photoCount = 1;
        self.newsImageView.index = 0;
        LDCPCircleImageBO *imageBO = [[LDCPCircleImageBO alloc] initWithLDPMLiveDetailNewsImage:imageInfo];;
        self.newsImageView.imageBO = imageBO;
        [self.newsImageView setImageWithUrl:imageInfo.thumbnailUrl placeholderImage:[UIImage imageNamed:@"LiveRoom_PlaceholderImage"] showProgress:NO];
    } else {
        self.newsImageView.hidden = YES;
        self.newsLabelBottomToImageViewTopLayoutConstraint.constant = 0;
        self.newsImageViewHeightLayoutConstraint.constant = 0;
    }
}

- (CGFloat)calcNILabelHeightWithText:(NSString *)text Icon:(UIImage *)icon
{
    static UILabel *calcSizeLabel;
    if (!calcSizeLabel) {
        calcSizeLabel = [UILabel new];
        calcSizeLabel.frame = CGRectMake(20, 15, SCREEN_WIDTH - 105, 0.);
        calcSizeLabel.layer.borderColor = [UIColor greenColor].CGColor;
        calcSizeLabel.layer.borderWidth = 1;
        calcSizeLabel.font = [UIFont systemFontOfSize:14.];
        calcSizeLabel.numberOfLines = 0;
        calcSizeLabel.textColor = [UIColor blueColor];
        //[self.newsLabel.superview addSubview:calcSizeLabel];
    }
    calcSizeLabel.text = text;
    [calcSizeLabel insertIconToFront:icon];
    
    CGFloat labelHeight = [calcSizeLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 105, DBL_MAX)].height + 2;
    calcSizeLabel.height = labelHeight;
    return labelHeight;
}

#pragma mark - 图片点击委托

- (void)tappedWithObject:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(transferTapEvent:)]) {
        [self.delegate transferTapEvent:sender];
    }
}

+ (CGSize)imageSize:(LDPMLiveDetailNewsImage *)imageInfo
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat labelWidth = screenWidth - 105.0;
    CGFloat maxImageHeight = labelWidth * 2.0 / 3.0;
    CGFloat imageWidth = imageInfo.thumbnailSize.width/scale;
    CGFloat imageHeight = imageInfo.thumbnailSize.height/scale;
    if (imageWidth > labelWidth) {
        imageHeight = imageHeight * (labelWidth / imageWidth);
        imageWidth = labelWidth;
    }
    
    if (imageHeight > maxImageHeight) {
        imageWidth = imageWidth * (maxImageHeight / imageHeight);
        imageHeight = maxImageHeight;
    }
    
    CGSize size = CGSizeMake(imageWidth, imageHeight);
    
    return size;
}


#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    [JLRoutes routeURL:result.URL withParameters:@{kLDRouteViewControllerKey:self.parentViewController}];
}


@end
