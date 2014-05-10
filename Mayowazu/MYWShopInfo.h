//
//  MYWShopInfo.h
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYWShopInfo : NSObject
<NSCoding>

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *address;

- (id)initWithUrl:(NSString *)url title:(NSString *)title address:(NSString *)address;

@end
