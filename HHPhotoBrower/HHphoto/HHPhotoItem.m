//
//  HHPhotoItem.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/19.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "HHPhotoItem.h"

@implementation HHPhotoItem


- (NSString*)description{
    
    return [NSString stringWithFormat:@"photo:%@,thumb:%@",self.photo,self.thumb];
}

@end
