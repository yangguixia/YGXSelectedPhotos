//
//  HHAlbumAssetsGroupController.m
//  HHPhotoBrower
//
//  Created by 秦山 on 16/1/14.
//  Copyright © 2016年 dfhe. All rights reserved.
//

#import "HHAlbumAssetsGroupController.h"
#import "HHAlbumAssetsGroupManger.h"
#import "HHAssetCollectionViewCell.h"
#import "HHAssetCollectionManger.h"
#import "MWPhotoBrowser.h"

@interface HHAlbumAssetsGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView* tableView;

@property(nonatomic,assign)CGSize assetCollectionThumbnailSize;

@property(nonatomic,strong)HHAssetCollectionManger* collectionManger;

@end

@implementation HHAlbumAssetsGroupController

- (id)init{
    self = [super init];
    if (self) {
        self.assetCollectionThumbnailSize = CGSizeMake(70., 70.);
        self.title = @"相册胶卷";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.rowHeight = 90;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupManger countOfAssertsCollection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *collection = [self.groupManger collectionAtIndex:indexPath.row];
    NSUInteger count;
    
    
    count = [self.groupManger phAssertCountOfCollection:collection];

    static NSString *cellIdentifier = @"CellIdentifier";
    
    HHAssetCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[HHAssetCollectionViewCell alloc] initWithThumbnailSize:self.assetCollectionThumbnailSize
                                                        reuseIdentifier:cellIdentifier];
    
    [cell bind:collection count:count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PHAssetCollection *collection = [self.groupManger collectionAtIndex:indexPath.row];

    
    self.collectionManger = [self.groupManger assetCollectionMangerOfCollection:collection];
    
    __weak __typeof(self)weakSelf = self;
    
    
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    displayActionButton = NO;
    displaySelectionButtons = YES;
    startOnGrid = YES;
    enableGrid = NO;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self.collectionManger];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.showSelectedCount = YES;
    
    NSInteger maxCount = 4;
    if ([self.delegate respondsToSelector:@selector(allowSelectedCountHHAlbumAssetsGroupController:)]) {
        maxCount = [self.delegate allowSelectedCountHHAlbumAssetsGroupController:self];
    }
    
    browser.maxSelectedCount = maxCount;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    self.collectionManger.SelectDoneBlock = ^(){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.navigationController popViewControllerAnimated:YES];
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(HHAlbumAssetsGroupController:selectedCollection:)]) {
            
            [browser dismissViewControllerAnimated:YES completion:^{
                [strongSelf.delegate HHAlbumAssetsGroupController:strongSelf selectedCollection:strongSelf.collectionManger];
            }];
        }
    };
    

    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}


@end
