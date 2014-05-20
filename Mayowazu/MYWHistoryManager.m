//
//  MYWHistoryManager.m
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWHistoryManager.h"
#import "MYWShopInfo.h"

@interface MYWHistoryManager ()

@property (nonatomic) NSMutableArray *historys;

@end


@implementation MYWHistoryManager

- (NSMutableArray *)historys {
    if (!_historys) {
        // savedからcall
        _historys = [[self loadHistorys] mutableCopy];
        
        // 保存してなければ初期化
        if (_historys == nil) {
            _historys = [NSMutableArray array];
        }
    }
    return _historys;
}

- (NSArray *)loadHistorys {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"HISTORY"];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array;
    }
    return nil;
}

- (void)saveHistorys {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_historys];
    [defaults setObject:data forKey:@"HISTORY"];
}

- (void)saveToHistory:(MYWShopInfo *)shopInfo {
    if (shopInfo
        && (shopInfo.url && ![shopInfo.url isEqualToString:@""])
        && (shopInfo.title && ![shopInfo.title isEqualToString:@""])
        && (shopInfo.address && ![shopInfo.address isEqualToString:@""])
        ) {
        NSLog(@"値が不正のため保存できませんでした");
        return;
    }
    // 重複を許さない
    if ([self.historys containsObject:shopInfo]) {
        [_historys removeObject:shopInfo];
    }
    
    [self.historys addObject:shopInfo];
    [self saveHistorys];
}

- (void)clearAll {
    self.historys = [NSMutableArray array];
    [self saveHistorys];
}

@end
