//
//  ViewController.m
//  IOS8Photo
//
//  Created by qianjn on 16/9/19.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "ViewController.h"
#import "PhotoChooseController.h"
#import "FMAsset.h"
@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIView *Conview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createImageView:) name:@"getImages" object:nil];
}

- (UIView *)Conview
{
    if (!_Conview) {
        _Conview = [[UIView alloc] init];
        [self.view addSubview:_Conview];
    }
    return _Conview;
}


#pragma mark - btn action
- (IBAction)custom:(UIButton *)sender {
    PhotoChooseController *vc = [[PhotoChooseController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)time:(UIButton *)sender {
    UIImagePickerController * controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    controller.delegate = self;
    
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}
- (IBAction)system:(UIButton *)sender {

    UIImagePickerController * controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    controller.allowsEditing = YES;
    
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}




- (void)createImageView:(NSNotification *)info
{
    NSArray *array = info.object;
    if (!array || array.count == 0) {
        return;
    }
    [self buildImageView:array];
}

- (void)buildImageView:(NSArray *)arr
{
    [self.Conview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat imaWidth = kScreenWidth / 4;
    
    for (int i = 0; i < arr.count; i++) {
        FMAsset *asset = [arr objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = asset.thumbnailImage;
        imageView.frame = CGRectMake((i % 4) * imaWidth, (i / 4) * imaWidth, imaWidth, imaWidth);
        [self.Conview addSubview:imageView];
    }
    self.Conview.frame = CGRectMake(0, 60, kScreenWidth, (arr.count/5 + 1) * imaWidth);
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    FMAsset *asset = [[FMAsset alloc] init];
    asset.thumbnailImage = image;
    [self buildImageView:@[asset]];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}
@end
