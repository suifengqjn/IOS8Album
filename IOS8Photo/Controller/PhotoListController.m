//
//  PhotoListController.m
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "PhotoListController.h"
#import "FMAlbumHelper.h"
#import "FMAlbum.h"
#import "PhotoChooseController.h"
@interface PhotoListController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *albumArray;
@end

@implementation PhotoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.albumArray = [NSMutableArray array];
    [self loadData];
    self.title =  @"photos";
    
    
}

- (void)loadData
{
    __weak __typeof(self)weakSelf = self;
    [FMAlbumHelper fetchAlbums:^(NSArray<FMAlbum *> * _Nonnull albums, BOOL success) {
        [weakSelf.albumArray addObjectsFromArray:albums];
        [weakSelf buildTableView];
    }];
}

- (void)buildTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight -64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}


#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    FMAlbum *album = self.albumArray[indexPath.row];
    

    cell.textLabel.text = album.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", album.assetCount];
    
    cell.imageView.image = album.thumbnail;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    FMAlbum *album = self.albumArray[indexPath.row];
    PhotoChooseController *photochoose = [PhotoChooseController new];
    photochoose.album = album;
    [self.navigationController pushViewController:photochoose animated:YES];
}
@end
