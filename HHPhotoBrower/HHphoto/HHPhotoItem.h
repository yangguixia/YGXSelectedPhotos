//
//  HHPhotoItem.h
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/19.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHPhotoItem : NSObject

@property(nonatomic,strong)UIImage* photo;
@property(nonatomic,assign)BOOL photohasLoaded;

@property(nonatomic,strong)UIImage* thumb;
@property(nonatomic,assign)BOOL thumbhasLoaded;

@end
