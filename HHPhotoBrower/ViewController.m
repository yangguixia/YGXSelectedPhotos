//
//  ViewController.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "ViewController.h"

#import "MWPhotoBrowser.h"
#import "HHAlbumAssetsGroupManger.h"
#import "HHAlbumAssetsGroupController.h"
#import "HHAssetCollectionManger.h"
#import "HHPhotoItem.h"

#import "HHSelectedPhotoManger.h"
#import "HHSelectedPhotoItem.h"

#define kMAXSELECTEDCOUNT 4

@interface ViewController ()<HHAlbumAssetsGroupDelegate>

@property(nonatomic,strong)UIImageView* imageView1;
@property(nonatomic,strong)UIImageView* imageView2;
@property(nonatomic,strong)UIImageView* imageView3;
@property(nonatomic,strong)UIImageView* imageView4;

//@property(nonatomic,strong)HHAssetCollectionManger* collectionManger;

@property(nonatomic,strong)HHAssetCollectionManger* collectionManger;
@property(nonatomic,strong)HHSelectedPhotoManger* selectedPhotoManger;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView1 = [[UIImageView alloc] init];
    self.imageView1.backgroundColor = [UIColor clearColor];
    self.imageView1.frame = CGRectMake(20, 100, 80, 80);
    [self.view addSubview:self.imageView1];
    
    self.imageView2 = [[UIImageView alloc] init];
    self.imageView2.backgroundColor = [UIColor clearColor];
    self.imageView2.frame = CGRectMake(120, 100, 80, 80);
    [self.view addSubview:self.imageView2];
    
    self.imageView3 = [[UIImageView alloc] init];
    self.imageView3.backgroundColor = [UIColor clearColor];
    self.imageView3.frame = CGRectMake(20, 210, 80, 80);
    [self.view addSubview:self.imageView3];
    
    self.imageView4 = [[UIImageView alloc] init];
    self.imageView4.backgroundColor = [UIColor clearColor];
    self.imageView4.frame = CGRectMake(120, 210, 80, 80);
    [self.view addSubview:self.imageView4];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor blueColor];
    [button setTitle:@"上传照片" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, 340, 200, 40);
    [button addTarget:self action:@selector(btttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor blueColor];
    [button2 setTitle:@"选取照片" forState:UIControlStateNormal];
    button2.frame = CGRectMake(50, 400, 200, 40);
    [button2 addTarget:self action:@selector(btttonClicked2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    self.selectedPhotoManger = [[HHSelectedPhotoManger alloc] init];
    
}

//上传
- (void)btttonClicked:(id)sender{
    
    NSLog(@"开始上传。。。。。。。。");
    
    NSInteger count = [self.selectedPhotoManger countOfSelectedPhotos];
    
    NSMutableArray* array = [NSMutableArray array];
    __weak __typeof(self)weakSelf = self;
    self.selectedPhotoManger.photoLoadCompleteBlock = ^(HHSelectedPhotoItem* item,NSInteger index){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if ([strongSelf.selectedPhotoManger allSelectedPhotoLoaded]) {
            
            for (NSInteger index = 0; index < count; index++) {
                
                HHSelectedPhotoItem* item = [strongSelf.selectedPhotoManger selectedPhotoItemAtIndex:index];
                if (item.photoItem.photo != nil) {
                    [array addObject:item.photoItem.photo];
                }
                
            }
            NSLog(@"上传图片：%@",array);
             NSLog(@"上传");
        }
    };
    
    if ([self.selectedPhotoManger allSelectedPhotoLoaded]) {
        
        for (NSInteger index = 0; index < count; index++) {
            
            id obj = [self.selectedPhotoManger selectedPhotoItemAtIndex:index];
            if ([obj isKindOfClass:[HHSelectedPhotoItem class]]) {
                HHSelectedPhotoItem* item = (HHSelectedPhotoItem*)obj;
                if (item.photoItem.photo != nil) {
                    [array addObject:item.photoItem.photo];
                }
            }
            
            else if ([obj isKindOfClass:[UIImage class]]){
                [array addObject:(UIImage *)obj];
            }
            
        }
        NSLog(@"上传图片：%@",array);
         NSLog(@"上传");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//选取多张图片
- (void)btttonClicked2:(id)sender{
    HHAlbumAssetsGroupManger* groupManger = [[HHAlbumAssetsGroupManger alloc] init];
    
    groupManger.AssetsGroupReadyBlock = ^(HHAlbumAssetsGroupManger* groupManger){
        
        NSLog(@"aaa");
        HHAlbumAssetsGroupController* controller = [[HHAlbumAssetsGroupController alloc] init];
        controller.groupManger = groupManger;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    };
    
    [groupManger loadAssetsGroup];
}

- (void)refreshViews{
    
    NSInteger count = [self.selectedPhotoManger countOfSelectedPhotos];
    
    for (NSInteger index = 0; index < count; index++) {
        switch (index) {
            case 0:
            {
                HHSelectedPhotoItem* item = [self.selectedPhotoManger selectedPhotoItemAtIndex:0];
                self.imageView1.image = item.photoItem.thumb;
            }
                break;
            case 1:
            {
                HHSelectedPhotoItem* item = [self.selectedPhotoManger selectedPhotoItemAtIndex:1];
                self.imageView2.image = item.photoItem.thumb;
            }
                break;
            case 2:
            {
                HHSelectedPhotoItem* item = [self.selectedPhotoManger selectedPhotoItemAtIndex:2];
                self.imageView3.image = item.photoItem.thumb;
            }
                break;
            case 3:
            {
                HHSelectedPhotoItem* item = [self.selectedPhotoManger selectedPhotoItemAtIndex:3];
                self.imageView4.image = item.photoItem.thumb;
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)HHAlbumAssetsGroupController:(HHAlbumAssetsGroupController*)groupController selectedCollection:(HHAssetCollectionManger*)collectionManger{
    
//    self.collectionManger = collectionManger;
    
    __weak __typeof(self)weakSelf = self;
    
    self.selectedPhotoManger.thumbLoadCompleteBlock = ^(HHSelectedPhotoItem* item,NSInteger index){
        
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf refreshViews];
        
    };
    
    [collectionManger.selections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSNumber *num = (NSNumber *)obj;
        if ([num boolValue]){
            
            HHSelectedPhotoItem* item = [collectionManger selectedPhotoItemAtIndex:idx];
            
            [self.selectedPhotoManger addSelectedPhotoItem:item];
        }
        
    }];
    
    [self refreshViews];
}

- (NSInteger)allowSelectedCountHHAlbumAssetsGroupController:(HHAlbumAssetsGroupController*)groupController{
    
    return  kMAXSELECTEDCOUNT - [self.selectedPhotoManger countOfSelectedPhotos];
}

@end
