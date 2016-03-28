//
//  HHAssetCollectionViewCell.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HHAssetCollectionViewCell : UITableViewCell

- (instancetype)initWithThumbnailSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

- (void)bind:(PHAssetCollection *)collection count:(NSUInteger)count;

@end
