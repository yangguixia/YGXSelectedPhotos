//
//  HHSelectedPhotoManger.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/19.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "HHSelectedPhotoManger.h"

#import "HHSelectedPhotoItem.h"
#import "HHPhotoItem.h"

@implementation HHSelectedPhotoManger

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                     name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                   object:nil];
        
    }
    return self;
}

- (NSArray*)selectedPhotos{
    
    NSMutableArray* array = [NSMutableArray array];
    
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[UIImage class]]){
            [array addObject:obj];
        }
        else if ([obj isKindOfClass:[HHSelectedPhotoItem class]]){
            HHSelectedPhotoItem* item = (HHSelectedPhotoItem*)obj;
            [array addObject:item.mwPhotoItem];
        }
        
    }];
    
    return array;
    
}

- (NSArray*)selectedThumbs{
    
    NSMutableArray* array = [NSMutableArray array];
    
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[UIImage class]]){
            [array addObject:obj];
        }
        else if ([obj isKindOfClass:[HHSelectedPhotoItem class]]){
            HHSelectedPhotoItem* item = (HHSelectedPhotoItem*)obj;
            [array addObject:item.mwPhotoItem];
        }
        
    }];
    
    return array;
}

- (HHPhotoItem*)photoItemAtIndex:(NSInteger)index{
    
    HHSelectedPhotoItem* item = [self.dataSource objectAtIndex:index];
    
    return item.photoItem;
    
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <MWPhoto> photo = [notification object];
    
    NSArray* photos = [self selectedPhotos];
    NSArray* thumbs = [self selectedThumbs];
    
    if ([photos containsObject:photo]) {
        
        NSInteger index = [photos indexOfObject:photo];
        
        HHPhotoItem* item = [self photoItemAtIndex:index];
        item.photohasLoaded = YES;
        item.photo = [photo underlyingImage];
        
        HHSelectedPhotoItem* photoitem = [self.dataSource objectAtIndex:index];
        
        if (self.photoLoadCompleteBlock) {
            self.photoLoadCompleteBlock(photoitem,index);
        }
        
    }else if ([thumbs containsObject:photo]) {
        
        NSInteger index = [thumbs indexOfObject:photo];
        
        HHPhotoItem* item = [self photoItemAtIndex:index];
        item.thumbhasLoaded = YES;
        item.thumb = [photo underlyingImage];
        
        HHSelectedPhotoItem* photoitem = [self.dataSource objectAtIndex:index];
        
        if (self.thumbLoadCompleteBlock) {
            self.thumbLoadCompleteBlock(photoitem,index);
        }
        
    }
    
}


- (void)addSelectedPhotoItem:(HHSelectedPhotoItem*)selectedPhotoItem{
    
    [self.dataSource addObject:selectedPhotoItem];
    
    if (selectedPhotoItem.photoItem.photohasLoaded != YES) {
        [selectedPhotoItem.mwPhotoItem loadUnderlyingImageAndNotify];
    }
    
    if (selectedPhotoItem.photoItem.thumbhasLoaded != YES) {
        [selectedPhotoItem.mwThumbItem loadUnderlyingImageAndNotify];
    }
}

- (void)addPhotoImage:(UIImage*)image{
    
    [self.dataSource addObject:image];
    
}

- (NSInteger)countOfSelectedPhotos{
    
    return [self.dataSource count];
}

- (id)selectedPhotoItemAtIndex:(NSInteger)index{

    if (index < 0 || index >= self.dataSource.count) {
        return nil;
    }
    
    return [self.dataSource objectAtIndex:index];
}

- (BOOL)allSelectedPhotoLoaded{
    
    __block BOOL flag = YES;
    
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[HHSelectedPhotoItem class]]) {
            HHSelectedPhotoItem* item = (HHSelectedPhotoItem*)obj;
            if (item.photoItem.photohasLoaded == NO) {
                [item.mwPhotoItem loadUnderlyingImageAndNotify];
                flag = NO;
                *stop = YES;
            }
        }
        
    }];
    return flag;
}

@end
