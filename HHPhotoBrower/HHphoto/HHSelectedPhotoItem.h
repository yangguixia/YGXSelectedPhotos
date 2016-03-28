//
//  HHSelectedPhotoItem.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/19.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoBrowser.h"

@class HHPhotoItem;

@interface HHSelectedPhotoItem : NSObject

@property(nonatomic,strong)HHPhotoItem* photoItem;
@property(nonatomic,strong)id<MWPhoto> mwPhotoItem;
@property(nonatomic,strong)id<MWPhoto> mwThumbItem;

@end
