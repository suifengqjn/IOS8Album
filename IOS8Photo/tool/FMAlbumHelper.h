//
//  FMAlbumHelper.h
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#define kScreenScale ([UIScreen mainScreen].scale)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define kCellWidth ((kScreenWidth/4) *kScreenScale)   //每行四个image

#define kIOS8OrLater ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

#define kIOS9OrLater ([[[UIDevice currentDevice] systemVersion] compare:@"9" options:NSNumericSearch] != NSOrderedAscending)

#define kOriginTargetSize (kIOS8OrLater ? PHImageManagerMaximumSize : CGSizeMake(kScreenWidth * kScreenScale, kScreenHeight * kScreenScale))//原图尺寸

#define kPreviewTargetSize ([UIScreen mainScreen].bounds.size)//预览图尺寸

#define kThumbnailTargetSize (CGSizeMake(kCellWidth, kCellWidth))//缩略图尺寸，如果感觉模糊可以再*kScreenScale

@class FMAlbum;
@class FMAsset;
@interface FMAlbumHelper : NSObject

+(instancetype _Nonnull)shareManager;

//是否可以访问照片
+ (BOOL)canAccessAlbums;
//是否可以拍照
+ (BOOL)canTakePhoto;


//读取相册列表albums
+ (void)fetchAlbums:(void(^_Nonnull)(NSArray <FMAlbum *>*_Nonnull albums, BOOL success))completion;

//读取相册内assets
+ (void)fetchAssetsWithAlbum:(id _Nonnull)album
                  completion:(void(^_Nonnull)(NSArray <FMAsset *>*_Nonnull assets, BOOL success))completion;
//读取asset内image
- (void)fetchImageWithAsset:(id _Nonnull)asset
                 targetSize:(CGSize)targetSize
                 completion:(void(^_Nullable)(UIImage *_Nullable image, NSDictionary *_Nullable info))completion;
@end
