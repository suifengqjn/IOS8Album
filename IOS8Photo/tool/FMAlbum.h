//
//  FMAlbum.h
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMAlbum : NSObject
/**
 *  相册的名称
 */
@property (nonatomic, copy, readonly, nonnull) NSString *name;

/**
 *  头图
 */
@property (nonatomic, strong, readonly, nonnull, getter=displayHeaderImage) UIImage *thumbnail;

/**
 *  照片的数量
 */
@property (nonatomic, assign, readonly) NSUInteger assetCount;

/**
 *  PHFetchResult<PHAsset>/ALAssetsGroup<ALAsset>
 */
@property (nonatomic, strong, readonly, nonnull) id fetchResult;

/**
 *  初始化SYAlbum
 *
 *  @param fetchResult PHFetchResult<PHAsset>/ALAssetsGroup<ALAsset>
 *  @param name        相册的名称
 *  @param assetCount  照片的数量
 *
 *  @return SYAlbum
 */
- (id _Nonnull)initWithFetchResult:(id _Nonnull)fetchResult
                              name:(NSString *_Nonnull)name
                        assetCount:(NSUInteger)assetCount;
@end
