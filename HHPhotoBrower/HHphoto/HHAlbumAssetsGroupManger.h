//
//  HHAlbumAssetsGroupManger.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class HHAssetCollectionManger;

@interface HHAlbumAssetsGroupManger : NSObject

//@property (nonatomic, strong) NSMutableArray *selectedAssetsGroup;

- (void)loadAssetsGroup;

@property(nonatomic,copy)void (^AccessDeniedBlock)();

@property(nonatomic,copy)void (^NoAssetsBlock)();

@property(nonatomic,copy)void (^AssetsGroupReadyBlock)(HHAlbumAssetsGroupManger* groupManger);

- (NSInteger)countOfAssertsCollection;

- (PHAssetCollection*)collectionAtIndex:(NSInteger)index;

- (NSInteger)phAssertCountOfCollection:(PHAssetCollection*)collection;

- (HHAssetCollectionManger*)assetCollectionMangerOfCollection:(PHAssetCollection*)collection;


@end
