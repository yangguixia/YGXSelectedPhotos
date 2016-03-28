//
//  HHAlbumAssetsGroupManger.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "HHAlbumAssetsGroupManger.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HHAssetCollectionManger.h"

@interface HHAlbumAssetsGroupManger ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableArray *assetsGroups;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;

@property (nonatomic, strong) NSArray *assetCollectionSubtypes;

@property (nonatomic, strong) PHFetchOptions *assetsFetchOptions;

@property (nonatomic, strong) PHFetchOptions *assetCollectionFetchOptions;

@property (nonatomic, assign) BOOL showsEmptyAlbums;


@property (nonatomic, copy) NSArray *fetchResults;
@property (nonatomic, copy) NSArray *assetCollections;


@end

@implementation HHAlbumAssetsGroupManger

- (void)dealloc
{
    [self unregisterChangeObserver];
}

- (id)init{
    self = [super init];
    if (self) {
        
//        _selectedAssetsGroup = [NSMutableArray new];
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        
        self.assetsFetchOptions = fetchOptions;
        
        self.assetCollectionFetchOptions = nil;
        self.showsEmptyAlbums = NO;
        
        [self initAssetCollectionSubtypes];
        [self registerChangeObserver];
        
    }
    return self;
}

- (void)initAssetCollectionSubtypes
{
    _assetCollectionSubtypes =
    @[[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumUserLibrary],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumMyPhotoStream],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumFavorites],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumPanoramas],
//      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumVideos],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumSlomoVideos],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumTimelapses],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumBursts],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumAllHidden],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumGeneric],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumRegular],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedAlbum],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedEvent],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumSyncedFaces],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumImported],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumCloudShared]];
    
    // Add iOS 9's new albums
    if ([[PHAsset new] respondsToSelector:@selector(sourceType)])
    {
        NSMutableArray *subtypes = [NSMutableArray arrayWithArray:self.assetCollectionSubtypes];
        [subtypes insertObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumSelfPortraits] atIndex:4];
        [subtypes insertObject:[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumScreenshots] atIndex:10];
        
        self.assetCollectionSubtypes = [NSArray arrayWithArray:subtypes];
    }
}


- (void)loadAssetsGroup{
    
    if (NSClassFromString(@"PHAsset")) {
        
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performLoadAssetsGroup];
                    });
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAccessDenied];
                    });
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performLoadAssetsGroup];
            });
        }
        
    } else {
        
        // Assets library
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performLoadAssetsGroup];
        });
        
    }
}

- (void)showAccessDenied
{
    if (self.AccessDeniedBlock != nil) {
        self.AccessDeniedBlock();
    }
    
}

- (void)performLoadAssetsGroup {
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:self.assetsFetchOptions];
    
    if (fetchResult.count > 0) {
        [self assetsGroupReady];
    } else {
        [self showNoAssets];
    }

}

- (PHAssetCollectionType)ctassetPickerAssetCollectionTypeOfSubtype:(PHAssetCollectionSubtype)subtype
{
    return (subtype >= PHAssetCollectionSubtypeSmartAlbumGeneric) ? PHAssetCollectionTypeSmartAlbum : PHAssetCollectionTypeAlbum;
}

- (NSUInteger)ctassetPikcerCountOfAssetsFetched:(PHAssetCollection*)assetCollection WithOptions:(PHFetchOptions *)fetchOptions
{
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
    return result.count;
}

- (void)setupFetchResults
{
    NSMutableArray *fetchResults = [NSMutableArray new];
    
    for (NSNumber *subtypeNumber in self.assetCollectionSubtypes)
    {
        PHAssetCollectionType type       = [self ctassetPickerAssetCollectionTypeOfSubtype:subtypeNumber.integerValue];
        PHAssetCollectionSubtype subtype = subtypeNumber.integerValue;
        
        PHFetchResult *fetchResult =
        [PHAssetCollection fetchAssetCollectionsWithType:type
                                                 subtype:subtype
                                                 options:self.assetCollectionFetchOptions];
        
        [fetchResults addObject:fetchResult];
    }
    
    self.fetchResults = [NSMutableArray arrayWithArray:fetchResults];
    
    [self updateAssetCollections];
}

- (void)updateAssetCollections
{
    NSMutableArray *assetCollections = [NSMutableArray new];
    
    for (PHFetchResult *fetchResult in self.fetchResults)
    {
        for (PHAssetCollection *assetCollection in fetchResult)
        {
            BOOL showsAssetCollection = YES;
            
            if (!self.showsEmptyAlbums)
            {
                PHFetchOptions *options = [PHFetchOptions new];
                options.predicate = self.assetsFetchOptions.predicate;
                
                if ([options respondsToSelector:@selector(setFetchLimit:)])
                    options.fetchLimit = 1;
                
                NSInteger count = [self ctassetPikcerCountOfAssetsFetched:assetCollection WithOptions:options];
                
                showsAssetCollection = (count > 0);
            }
            
            if (showsAssetCollection)
                [assetCollections addObject:assetCollection];
        }
    }
    
    self.assetCollections = [NSMutableArray arrayWithArray:assetCollections];
}

- (void)assetsGroupReady{
    
    [self setupFetchResults];
    
    if (self.AssetsGroupReadyBlock != nil) {
        self.AssetsGroupReadyBlock(self);
    }
    
}

- (void)showNoAssets{
    if (self.NoAssetsBlock != nil) {
        self.NoAssetsBlock();
    }
}

#pragma mark - Photo library change observer

- (void)registerChangeObserver
{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)unregisterChangeObserver
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Photo library changed

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
//    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        NSMutableArray *deselectAssets = [NSMutableArray new];
//        
//        for (PHAsset *asset in self.selectedAssetsGroup)
//        {
//            PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:asset];
//            
//            if ([changeDetails objectWasDeleted])
//                [deselectAssets addObject:asset];
//        }
//        
//        // Deselect asset if it was deleted from library
//        for (PHAsset *asset in deselectAssets)
//            [self deselectAsset:asset];
//    });
}

- (NSInteger)countOfAssertsCollection{
    return self.assetCollections.count;
}

- (PHAssetCollection*)collectionAtIndex:(NSInteger)index{
    
    if (index < 0 || index > self.assetCollections.count) {
        return nil;
    }
    
    return [self.assetCollections objectAtIndex:index];
    
}

- (NSInteger)phAssertCountOfCollection:(PHAssetCollection*)collection{
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:self.assetsFetchOptions];
    return result.count;
}

- (HHAssetCollectionManger*)assetCollectionMangerOfCollection:(PHAssetCollection*)collection{
    
    HHAssetCollectionManger* collectionManger = [[HHAssetCollectionManger alloc] init];
    collectionManger.assetsFetchOptions = self.assetsFetchOptions;
    collectionManger.collection = collection;
    
    [collectionManger loadCollectionData];
    
    return collectionManger;
}

@end
