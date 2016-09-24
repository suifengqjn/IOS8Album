//
//  FMPhotoGridCollectionCell.m
//  Pinnacle
//
//  Created by DengLliujun on 16/6/14.
//  Copyright © 2016年 5milesapp.com. All rights reserved.
//

#import "FMPhotoGridCollectionCell.h"

@interface FMPhotoGridCollectionCell()
@end

@implementation FMPhotoGridCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        imageView.clipsToBounds = YES;
        
        _imageView = imageView;
        
        UIImage *checkImage = [UIImage imageNamed:@"sel_no_like"];
        _checkButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - checkImage.size.width - 5*2 , 0, checkImage.size.width + 5*2, checkImage.size.height + 5*2)];
        [self.contentView addSubview:_checkButton];
        [_checkButton setImage:checkImage forState:UIControlStateNormal];
        [_checkButton setImage:[UIImage imageNamed:@"sel_like"] forState:UIControlStateSelected];
        _checkButton.userInteractionEnabled = NO;
        
    }
    
    return self;
}

@end
