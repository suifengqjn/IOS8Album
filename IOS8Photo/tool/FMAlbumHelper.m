//
//  FMAlbumHelper.m
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "FMAlbumHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FMAlbum.h"
#import "FMAsset.h"

@interface FMAlbumHelper ()
@property (nonatomic, strong) PHImageRequestOptions *imageRequestOption;
@end
@implementation FMAlbumHelper

+(instancetype)shareManager
{
    static FMAlbumHelper *_insatance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _insatance = [[FMAlbumHelper alloc] init];
    });
    return _insatance;
}

- (PHImageRequestOptions *)imageRequestOption {
    if (!_imageRequestOption) {
        _imageRequestOption = [[PHImageRequestOptions alloc] init];
        _imageRequestOption.synchronous = YES;
    }
    
    return _imageRequestOption;
}

+ (BOOL)canAccessAlbums {
    BOOL _isAuth = YES;
    if (kIOS8OrLater) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            _isAuth = NO;
        }
    }
//    else {
//        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
//        
//        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusNotDetermined) {
//            //无权限
//            _isAuth = NO;
//        }
//    }
    
    return _isAuth;
}

/*
 ALAuthorizationStatusNotDetermined = 0, 用户尚未做出了选择这个应用程序的问候
 ALAuthorizationStatusRestricted,        此应用程序没有被授权访问的照片数据。可能是家长控制权限。
 ALAuthorizationStatusDenied,            用户已经明确否认了这一照片数据的应用程序访问.
 ALAuthorizationStatusAuthorized         用户已授权应用访问照片数据.
 */
+ (BOOL)canTakePhoto
{
    //判断相机是否能够使用
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        return YES;
    } else if(status == AVAuthorizationStatusDenied){
        // denied
        return NO;
    } else if(status == AVAuthorizationStatusRestricted){
        return NO;
    } else if(status == AVAuthorizationStatusNotDetermined){
        return NO;
    }
    return NO;
    
}


//读取列表
+ (void)fetchAlbums:(void(^)(NSArray <FMAlbum *>*albums, BOOL success))completion {
    __block NSMutableArray *_arrAlbums = [[NSMutableArray alloc] init];
    
    if (kIOS8OrLater) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(_arrAlbums, NO);
                }
            });
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    /**
                     *  系统自带智能分组相册，我们只取用户相册、收藏、最近添加，注意：自拍（PHAssetCollectionSubtypeSmartAlbumSelfPortraits）和截屏（PHAssetCollectionSubtypeSmartAlbumScreenshots）需要9.0及以上系统支持
                     */
                    [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                      subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                      options:nil
                                    resultArr:_arrAlbums];
                    
                    //收藏
                    [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                      subtype:PHAssetCollectionSubtypeSmartAlbumFavorites
                                      options:nil
                                    resultArr:_arrAlbums];
                    
                    //最近添加
                    [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                      subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded
                                      options:nil
                                    resultArr:_arrAlbums];
                    
                    if (kIOS9OrLater) {
                        //自拍
                        [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                          subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits
                                          options:nil
                                        resultArr:_arrAlbums];
                        
                        //屏幕截图
                        [self fetchAlbumsWithType:PHAssetCollectionTypeSmartAlbum
                                          subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots
                                          options:nil
                                        resultArr:_arrAlbums];
                    }
                    
                    /**
                     *  其他相册（包括手动和第三方应用创建的），我们只取常规的、手动导入的
                     */
                    [self fetchAlbumsWithType:PHAssetCollectionTypeAlbum
                                      subtype:PHAssetCollectionSubtypeAlbumRegular
                                      options:nil
                                    resultArr:_arrAlbums];
                    
                    //导入的
                    [self fetchAlbumsWithType:PHAssetCollectionTypeAlbum
                                      subtype:PHAssetCollectionSubtypeAlbumImported
                                      options:nil
                                    resultArr:_arrAlbums];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(_arrAlbums, YES);
                        }
                    });
                }
                else {
                    if (status != PHAuthorizationStatusNotDetermined) {
                        //无权限
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(_arrAlbums, NO);
                            }
                        });
                    }
                }
            }];
        }
    }

}



+ (NSArray <FMAlbum *> *)fetchAlbumsWithType:(PHAssetCollectionType)type
                                     subtype:(PHAssetCollectionSubtype)subtype
                                     options:(nullable PHFetchOptions *)options
                                   resultArr:(NSMutableArray *_Nonnull)resultArr {
    PHFetchResult *albumsdd = [PHAssetCollection fetchAssetCollectionsWithType:type
                                                                       subtype:subtype
                                                                       options:options];
    for (PHAssetCollection *collection in albumsdd) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                                   options:nil];
        
        if (fetchResult.count == 0)
            continue;
        
        FMAlbum *mAlbum = [[FMAlbum alloc] initWithFetchResult:fetchResult
                                                          name:collection.localizedTitle
                                                    assetCount:[fetchResult count]];
        
        if ([mAlbum.name isEqualToString:@"Camera Roll"] || [mAlbum.name isEqualToString:@"相机胶卷"] || [mAlbum.name isEqualToString:@"所有照片"]) {
            [resultArr insertObject:mAlbum atIndex:0];
        }
        else {
            [resultArr addObject:mAlbum];
        }
    }
    
    return resultArr;
}



#pragma mark -  getAsset
+ (void)fetchAssetsWithAlbum:(id _Nonnull)album
                  completion:(void (^)(NSArray<FMAsset *> * _Nonnull, BOOL))completion {
    __block NSMutableArray *photoArr = [NSMutableArray array];
    
    id albumTemp = [album isKindOfClass:[FMAlbum class]] ? [album fetchResult] : album;
    
    if ([albumTemp isKindOfClass:[PHFetchResult class]]) {
        [albumTemp enumerateObjectsUsingBlock:^(PHAsset *_Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            FMAsset *mAsset = [[FMAsset alloc] initWithAsset:asset];
            [photoArr addObject:mAsset];
        }];
    }

    if (completion) {
        completion(photoArr, photoArr.count);
    }
}


#pragma mark - get image
- (void)fetchImageWithAsset:(id _Nonnull)asset
                 targetSize:(CGSize)targetSize
                 completion:(void(^_Nullable)(UIImage *_Nullable image, NSDictionary *_Nullable info))completion {
    __block UIImage *resultImage = nil;
    __block NSDictionary *resultInfo = nil;
    
    id assetTemp = [asset isKindOfClass:[FMAsset class]] ? [asset asset] : asset;
    
    if ([assetTemp isKindOfClass:[PHAsset class]]) {
        [[PHImageManager defaultManager] requestImageForAsset:assetTemp targetSize:targetSize contentMode:PHImageContentModeDefault options:self.imageRequestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            resultImage = result;
            resultInfo = info;
        }];
    }

    if (completion) {
        completion(resultImage, resultInfo);
    }
}

@end
