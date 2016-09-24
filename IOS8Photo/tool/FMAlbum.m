//
//  FMAlbum.m
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMAlbum.h"
#import "FMAlbumHelper.h"

@interface FMAlbum ()
@property (nonatomic, strong, readwrite, nonnull) UIImage *thumbnail;
@end

@implementation FMAlbum
- (id _Nonnull)initWithFetchResult:(id _Nonnull)fetchResult name:(NSString * _Nonnull)name assetCount:(NSUInteger)assetCount {
    if (self = [super init]) {
        _fetchResult = fetchResult;
        _assetCount = assetCount;
        _name = name;
    }
    
    return self;
}

- (UIImage *_Nonnull)displayHeaderImage {
    __block UIImage *img;
    
    if ([_fetchResult isKindOfClass:[PHFetchResult class]]) {
        [[FMAlbumHelper shareManager] fetchImageWithAsset:[_fetchResult lastObject] targetSize:kThumbnailTargetSize completion:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
            img = image;
        }];
    }
    
    return img;
}

@end
