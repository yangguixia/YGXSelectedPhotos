//
//  HHAssetCollectionViewCell.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "HHAssetCollectionViewCell.h"

@interface HHAssetCollectionViewCell ()

@property (nonatomic, assign) CGSize thumbnailSize;

@property(nonatomic,strong)UIImageView* thumbImageView;
@property(nonatomic,strong)UILabel* topLabel;
@property(nonatomic,strong)UILabel* bottomLabel;

@property (nonatomic, strong) PHAssetCollection *collection;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end

@implementation HHAssetCollectionViewCell

- (instancetype)initWithThumbnailSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        _thumbnailSize = size;
        _imageManager = [PHCachingImageManager new];
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    
    self.thumbImageView = [UIImageView new];
    self.thumbImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.thumbImageView];
    
    self.topLabel = [UILabel new];
    self.topLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.topLabel];
    
    self.bottomLabel = [UILabel new];
    self.bottomLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.bottomLabel];
    
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@(self.thumbnailSize.height));
        make.width.equalTo(@(self.thumbnailSize.width));
    }];
    
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbImageView.mas_right).offset(10);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        
    }];
    
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbImageView.mas_right).offset(10);
        make.top.equalTo(self.topLabel.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bind:(PHAssetCollection *)collection count:(NSUInteger)count
{
    self.collection = collection;
    self.count      = count;
    
    [self setupPlaceholderImage];
    
    [self.topLabel setText:collection.localizedTitle];
    
    if (count != NSNotFound)
    {
        [self.bottomLabel setText:[NSString stringWithFormat:@"%d",count]];
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setupPlaceholderImage
{
    NSString *imageName = [self placeHolderImageNameOfCollectionSubtype:self.collection.assetCollectionSubtype];
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.thumbImageView.image = image;
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:self.collection options:options];
    
    PHAsset* asset = result.lastObject;
    
    PHImageRequestOptions *imageoptions = [[PHImageRequestOptions alloc] init];
    imageoptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    imageoptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:self.thumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:imageoptions
                              resultHandler:^(UIImage *image, NSDictionary *info){
                                  self.thumbImageView.image = image;
                              }];
}

- (NSString *)placeHolderImageNameOfCollectionSubtype:(PHAssetCollectionSubtype)subtype
{
    if (subtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
        return @"GridEmptyCameraRoll";
    
    else if (subtype == PHAssetCollectionSubtypeSmartAlbumAllHidden)
        return @"GridHiddenAlbum";
    
    else if (subtype == PHAssetCollectionSubtypeAlbumCloudShared)
        return @"GridEmptyAlbumShared";
    
    else
        return @"GridEmptyAlbum";
}


@end
