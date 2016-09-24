//
//  FMAsset.m
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMAsset.h"
#import "FMAlbumHelper.h"

@implementation FMAsset
@synthesize asset = _asset;
@synthesize originImage = _originImage;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize previewImage = _previewImage;

- (instancetype)initWithAsset:(PHAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
    }
    
    return self;
}

- (UIImage *)originImage {
    if (_originImage) {
        return _originImage;
    }
    __block UIImage *resultImage = nil;
    
    [[FMAlbumHelper shareManager] fetchImageWithAsset:self targetSize:kOriginTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        resultImage = image;
    }];
    _originImage = resultImage;
    
    return _originImage;
}

- (UIImage *)thumbnailImage {
    if (_thumbnailImage) {
        return _thumbnailImage;
    }
    __block UIImage *resultImage;
    
    [[FMAlbumHelper shareManager] fetchImageWithAsset:self targetSize:kThumbnailTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        resultImage = image;
    }];
    _thumbnailImage = resultImage;
    
    return _thumbnailImage;
}

- (UIImage *)previewImage {
    if (_previewImage) {
        return _previewImage;
    }
    __block UIImage *resultImage;
    
    [[FMAlbumHelper shareManager] fetchImageWithAsset:self targetSize:kPreviewTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        resultImage = image;
    }];
    _previewImage = resultImage;
    
    return _previewImage;
}

- (NSString *)identifier {
    return self.asset.localIdentifier;
}
@end
