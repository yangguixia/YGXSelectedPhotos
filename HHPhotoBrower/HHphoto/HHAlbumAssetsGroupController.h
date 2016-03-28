//
//  HHAlbumAssetsGroupController.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//
#import <UIKit/UIKit.h>

@class HHAlbumAssetsGroupManger;

@class HHAlbumAssetsGroupController;
@class HHAssetCollectionManger;

@protocol HHAlbumAssetsGroupDelegate <NSObject>

- (void)HHAlbumAssetsGroupController:(HHAlbumAssetsGroupController*)groupController selectedCollection:(HHAssetCollectionManger*)collectionManger;

@optional

- (NSInteger)allowSelectedCountHHAlbumAssetsGroupController:(HHAlbumAssetsGroupController*)groupController;

@end

@interface HHAlbumAssetsGroupController : UIViewController

@property(nonatomic,assign)id<HHAlbumAssetsGroupDelegate> delegate;

@property(nonatomic,strong)HHAlbumAssetsGroupManger* groupManger;


@end
