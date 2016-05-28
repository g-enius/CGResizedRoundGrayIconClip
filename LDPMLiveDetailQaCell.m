//
//  LDPMLiveDetailQaCell.m
//  PreciousMetals
//
//  Created by Ding Yi on 15/10/15.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "LDPMLiveDetailQaCell.h"
#import "LDPMLiveDetailQa.h"
#import "NIAttributedLabel.h"
#import "NSString+NPMUtil.h"
#import "LDPMLiveDetailNewsWithImageBgView.h"
#import "NSDate+NTBasicAdditions.h"
#import "UILabel+LDPMLive.h"
#import "UIImage+LDPMLive.h"
#import "SDImageCache+LDPMLive.h"

static CGFloat const analystIconHeight = 31.;
static NSString * const avatarPlaceholderImageKey = @"LDPMLiveRoomAvatarPlaceholder";

@interface LDPMLiveDetailQaCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerLabelHeightConstraint;

@end

@implementation LDPMLiveDetailQaCell

- (void)setContentWithQaInfo:(LDPMLiveDetailQa *)qaInfo
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
    
    if ([qaInfo.createTime isSameDayWithDate:[NSDate date]]) {
        self.dateLabel.text = nil;
    } else {
        self.dateLabel.text = [dateFormatter stringFromDate:qaInfo.createTime];
    }
    self.timeLabel.text = [timeFormatter stringFromDate:qaInfo.createTime];
    self.questionLabel.text = qaInfo.question;
    self.answerLabel.text = qaInfo.answer;
    
    SDImageCache *cache = [SDImageCache sharedImageCache];
    
    UIImage *placeholder = [cache imageFromMemoryCacheForKey:avatarPlaceholderImageKey];
    if (!placeholder) {
        placeholder = [[UIImage imageNamed:@"avatar_placeholder"] resizedRoundImageWithDiameter:analystIconHeight borderColor:[NPMColor seplineColor] borderWidth:1];
        [cache storeImage:placeholder forKey:avatarPlaceholderImageKey toDisk:NO];
    }
    
    __block UIImage *avatar = [cache imageFromMemoryCacheForKey:[cache ld_RoundScaleImageKeyForImageURL:[NSURL URLWithString:qaInfo.analystIconUrl]]];
    if (avatar) {
        [self.answerLabel insertIconToFront:avatar];
    } else {
        [self.answerLabel insertIconToFront:placeholder];
        @weakify(self)
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:qaInfo.analystIconUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self)
            if (image) {
                avatar = [image resizedRoundImageWithDiameter:analystIconHeight borderColor:[NPMColor seplineColor] borderWidth:1];
                [cache storeImage:avatar forKey:[cache ld_RoundScaleImageKeyForImageURL:[NSURL URLWithString:qaInfo.analystIconUrl]] toDisk:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.answerLabel.text = qaInfo.answer;
                    [self.answerLabel insertIconToFront:avatar];
                });
            }
        }];
    }
    self.answerLabelHeightConstraint.constant = [self.answerLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 105, DBL_MAX)].height;

    NSDateFormatter *questionDateFormatter = [NSDateFormatter new];
    questionDateFormatter.dateFormat = @"MM-dd HH:mm";
    NSString *questionTime = [questionDateFormatter stringFromDate:qaInfo.questionTime];;
    self.questionerInfoLabel.text = [NSString stringWithFormat:@"%@ %@", qaInfo.qUserName, questionTime];
}

@end
