//
//  MYWHistoryManager.h
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MYWShopInfo;

@interface MYWHistoryManager : NSObject

- (NSMutableArray *)historys;
- (void)saveToHistory:(MYWShopInfo *)shopInfo;

@end
