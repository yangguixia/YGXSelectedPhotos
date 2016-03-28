//
//  HHAssetCollectionManger.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/15.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MWPhotoBrowser.h"

@class HHSelectedPhotoItem;

@interface HHAssetCollectionManger : NSObject <MWPhotoBrowserDelegate>

@property (nonatomic, strong) PHFetchOptions *assetsFetchOptions;

@property (nonatomic, strong) PHAssetCollection* collection;

@property (nonatomic, strong) NSMutableArray* photos;
@property (nonatomic, strong) NSMutableArray* thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableArray* selections;

@property (nonatomic, strong) void(^SelectDoneBlock)();

@property (nonatomic, copy) void(^photoLoadComplete)(id<MWPhoto> photo,NSInteger index);
@property (nonatomic, copy) void(^thumbLoadComplete)(id<MWPhoto> photo,NSInteger index);

- (void)loadCollectionData;

- (id)selectedPhotoItemAtIndex:(NSInteger)index;

@end
