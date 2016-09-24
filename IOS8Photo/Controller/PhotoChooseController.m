//
//  PhotoChooseController.m
//  IOS8Photo
//
//  Created by qianjn on 16/9/23.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "PhotoChooseController.h"
#import "FMPhotoGridCollectionCell.h"
#import "PhotoListController.h"
#import <Photos/Photos.h>
#import "FMAsset.h"
#import "FMAlbum.h"
#import "FMAlbumHelper.h"
#import "UIView+Toast.h"
@interface PhotoChooseController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,assign) NSInteger maxSelectedNumber;  //最大选中图片数量
@property (nonatomic,retain) UICollectionView *collectionView;
@property (nonatomic,retain) NSMutableArray *selectedAssets; //所有选中的图片
@property (nonatomic,retain) NSMutableArray *currentAssets; //当前相册中的所有图片

@end

@implementation PhotoChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedAssets = [NSMutableArray new];
    self.currentAssets = [NSMutableArray new];
    _maxSelectedNumber = 6;
    
    [self initCollectionView];
    self.navigationItem.title = NSLocalizedString(@"Camera Roll", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(go_back)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doCommit)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.album) {
        [self loadPhotoWithAlbum:self.album];
    }
}
#pragma mark View
- (void)initCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 4.0;
    layout.minimumInteritemSpacing = 4.0;
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[FMPhotoGridCollectionCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    [self.view addSubview:_collectionView];
    
    [self loadAllPhoto:^(NSMutableArray *arr) {
        [_collectionView reloadData];
    }];
    
}

#pragma mark Action
- (void)go_back {
    PhotoListController *list = [PhotoListController new];
    NSMutableArray *arr  = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [arr insertObject:list atIndex:arr.count - 1];
    [self.navigationController setViewControllers:arr];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)doCommit {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getImages" object:self.selectedAssets];
}

- (void)loadAllPhoto:(void(^)(NSMutableArray *arr))result
{
    __weak __typeof(self)weakSelf = self;
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]; //按照时间倒叙排列
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        
        FMAsset *mAsset = [[FMAsset alloc] initWithAsset:asset];
        [weakSelf.currentAssets addObject:mAsset];
        if (allPhotosResult.count == weakSelf.currentAssets.count) {
            result(weakSelf.currentAssets);
        }
    }];
    
}

- (void)loadPhotoWithAlbum:(FMAlbum *)album
{
    __weak __typeof(self)weakSelf = self;
    [FMAlbumHelper fetchAssetsWithAlbum:album completion:^(NSArray<FMAsset *> * _Nonnull assets, BOOL success) {
        [weakSelf.currentAssets removeAllObjects];
        [weakSelf.currentAssets addObjectsFromArray:assets];
        [weakSelf.collectionView reloadData];
    }];
}



#pragma mark - CollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _currentAssets.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMPhotoGridCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    FMAsset *asset = nil;
    if (indexPath.row < _currentAssets.count) {
        asset = [_currentAssets objectAtIndex:indexPath.row];
    }
    
    cell.imageView.image = asset.thumbnailImage;

    
    if ([self isAssetSelected:asset]) {
        [cell.checkButton setSelected:YES];
    } else {
        [cell.checkButton setSelected:NO];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (kScreenWidth - 4.0 *3)/4.0;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    [self previewAssets:_currentAssets currentPage:indexPath.row-1];
    
    FMPhotoGridCollectionCell *checkCell = (FMPhotoGridCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL isSelected = checkCell.checkButton.isSelected;
    
    NSIndexPath *checkIndexPath = [self.collectionView indexPathForCell:checkCell];
    if (checkIndexPath.row < self.currentAssets.count) {
        FMAsset *asset = [self.currentAssets objectAtIndex:checkIndexPath.row];
        if (!isSelected) {
            if (![self isAssetSelected:asset]) {
                if (self.selectedAssets.count < _maxSelectedNumber) {
                    [self.selectedAssets addObject:asset];
                    [checkCell.checkButton setSelected:YES];
                } else {
                    NSString *message = [NSString stringWithFormat:@"You can post %ld photos at most.", _maxSelectedNumber];
                    [self.view makeToast:message];
                    [checkCell.checkButton setSelected:NO];
                }
            }
        } else {
            [self removeAsset:asset fromArray:self.selectedAssets];
            [checkCell.checkButton setSelected:NO];
        }
    }

}


- (BOOL)isAssetSelected:(FMAsset *)asset {
    bool isSelected = NO;
    NSString *assetIden = asset.identifier;
    
    for (FMAsset *selectAsset in self.selectedAssets) {
        NSString *selectAssetIden = selectAsset.identifier;
        if ([selectAssetIden isEqualToString:assetIden]) {
            isSelected = YES;
            break;
        }
    }
    
    return isSelected;
}

- (void)removeAsset:(FMAsset *)asset fromArray:(NSMutableArray *)assetsArray {
    NSString *assetIden = asset.identifier;
    
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (FMAsset *selectAsset in assetsArray) {
        NSString *selectAssetIden = selectAsset.identifier;
        if ([selectAssetIden isEqualToString:assetIden]) {
            [deleteArray addObject:selectAsset];
        }
    }
    
    for (FMAsset *deleteAsset in deleteArray) {
        [assetsArray removeObject:deleteAsset];
    }
}
@end
