//
//  HHAssetCollectionManger.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/15.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "HHAssetCollectionManger.h"
#import "MWPhoto.h"
#import "HHPhotoItem.h"
#import "HHSelectedPhotoItem.h"


@interface HHAssetCollectionManger ()

@end

@implementation HHAssetCollectionManger

- (id)init{
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray array];
        self.photos = [NSMutableArray array];
        self.thumbs = [NSMutableArray array];
        self.selections = [NSMutableArray array];
        
    }
    return self;
}

- (NSInteger)selectedIndexOfIndex:(NSInteger)index{
    
    __block NSInteger result = -1;
    [self.selections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSNumber* item = (NSNumber*)obj;
        
        if([item boolValue]){
            result++;
            if (idx == index) {
                *stop = YES;
            }
        }

        
    }];
    
    return result;
    
}


- (NSInteger)indexOfThums:(id<MWPhoto>)photo{
    
    __block NSInteger index = -1;
    
    [self.thumbs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id<MWPhoto> pppp = (id<MWPhoto>)obj;
        
        if (photo == pppp) {
            index = idx;
            *stop = YES;
        }
        
    }];
    
    return index;
}

- (NSInteger)indexOfPhoto:(id<MWPhoto>)photo{
    
    __block NSInteger index = -1;
    
    [self.photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id<MWPhoto> pppp = (id<MWPhoto>)obj;
        
        if (photo == pppp) {
            index = idx;
            *stop = YES;
        }
        
    }];
    
    return index;
}

- (void)loadCollectionData{
    
    [self.assets removeAllObjects];
    [self.photos removeAllObjects];
    [self.thumbs removeAllObjects];
    
    PHFetchResult *fetchResults = [PHAsset fetchAssetsInAssetCollection:self.collection options:self.assetsFetchOptions];
    [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_assets addObject:obj];
        
    }];
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
    for (PHAsset *asset in _assets) {
        [self.photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
        [self.thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
    }
    
    for (int i = 0; i < self.photos.count; i++) {
        [_selections addObject:[NSNumber numberWithBool:NO]];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (NSInteger)selectedCountPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    
    
    __block NSInteger count = 0;
    
    [self.selections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSNumber* item = (NSNumber*)obj;
        
        if ([item boolValue] == YES) {
            count++;
        }
        
    }];
    
    return count;
}

- (void)reachMaxSelectedCountPhotoBrowser:(MWPhotoBrowser *)photoBrowser maxSelectedCount:(NSInteger)maxSelectedCount{
    
    NSString *msg = [NSString stringWithFormat:@"最多选择%lu张照片",maxSelectedCount];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alert show];
    NSLog(@"数量限制了");
    
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser{
    
    if (self.SelectDoneBlock != nil) {
        self.SelectDoneBlock();
    }
    
}


- (id)selectedPhotoItemAtIndex:(NSInteger)index{
    
    HHPhotoItem* item = [[HHPhotoItem alloc] init];
    
//    [self.selectedItems replaceObjectAtIndex:index withObject:item];
    
    MWPhoto * photo = _photos[index];
    
    if ([photo underlyingImage]) {
        item.photo = [photo underlyingImage];
        item.photohasLoaded = YES;
    } else {
//        [photo loadUnderlyingImageAndNotify];
    }
    
    
    MWPhoto * thumb = _thumbs[index];
    
    if ([thumb underlyingImage]) {
        
        item.thumb = [thumb underlyingImage];
        item.thumbhasLoaded = YES;
        
    } else {
//        [thumb loadUnderlyingImageAndNotify];
    }

    HHSelectedPhotoItem* photoItem = [[HHSelectedPhotoItem alloc] init];
    
    photoItem.mwPhotoItem = photo;
    photoItem.mwThumbItem = thumb;
    photoItem.photoItem = item;
    
    return photoItem;
}

@end
