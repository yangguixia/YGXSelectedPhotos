//
//  HHSelectedPhotoManger.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/19.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HHSelectedPhotoItem;

@interface HHSelectedPhotoManger : NSObject

@property(nonatomic, strong) NSMutableArray* dataSource;

@property(nonatomic, copy) void(^photoLoadCompleteBlock)(HHSelectedPhotoItem* item,NSInteger index);

@property(nonatomic, copy) void(^thumbLoadCompleteBlock)(HHSelectedPhotoItem* item,NSInteger index);

- (void)addSelectedPhotoItem:(HHSelectedPhotoItem*)selectedPhotoItem;

- (void)addPhotoImage:(UIImage*)image;

- (NSInteger)countOfSelectedPhotos;

- (id)selectedPhotoItemAtIndex:(NSInteger)index;

- (BOOL)allSelectedPhotoLoaded;

@end
