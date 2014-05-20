//
//  MYWShopInfo.m
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWShopInfo.h"

@implementation MYWShopInfo

- (id)initWithUrl:(NSString *)url title:(NSString *)title address:(NSString *)address {
    self = [super init];
    if (self) {
        self.url = url;
        self.title = title;
        self.address = address;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"SHOP_URL"];
        self.title = [aDecoder decodeObjectForKey:@"SHOP_TITLE"];
        self.address = [aDecoder decodeObjectForKey:@"SHOP_ADDRESS"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"SHOP_URL"];
    [aCoder encodeObject:_title forKey:@"SHOP_TITLE"];
    [aCoder encodeObject:_address forKey:@"SHOP_ADDRESS"];
}


- (BOOL)isEqual:(id)object {
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return [self isEqualToShopInfo:object];
}

- (BOOL)isEqualToShopInfo:(MYWShopInfo *)aShopInfo {
    if (self == aShopInfo)
        return YES;
    if (![[self url] isEqualToString:[aShopInfo url]])
        return NO;
    if (![[self title] isEqualToString:[aShopInfo title]])
        return NO;
    if (![[self address] isEqualToString:[aShopInfo address]])
        return NO;
    return YES;
}


@end
