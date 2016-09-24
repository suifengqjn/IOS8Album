//
//  FMAsset.h
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;
@interface FMAsset : NSObject
/**
 *  PHAsset
 */
@property (nonatomic, strong,nonnull) PHAsset *asset;

/**
 *  原图 (默认尺寸kOriginTargetSize)
 */
@property (nonatomic, strong,nonnull) UIImage *originImage;

/**
 *  预览图（默认尺寸kPreviewTargetSize）
 */
@property (nonatomic, strong, readonly, nonnull) UIImage *previewImage;

/**
 *  缩略图（默认尺寸kThumbnailTargetSize)
 */
@property (nonatomic, strong,nonnull) UIImage *thumbnailImage;
/**
 *  是否选中
 */
@property (nonatomic) BOOL selected;
/**
 *  唯一标识符
 */
@property (nonatomic, strong, readonly, nonnull) NSString *identifier;

/**
 *  初始化相片model
 *
 *  @param asset PHAsset/ALAsset
 *
 *  @return SYAsset
 */
- (instancetype _Nonnull)initWithAsset:(PHAsset * _Nonnull)asset;

@end
