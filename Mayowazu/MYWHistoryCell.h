//
//  MYWHistoryCell.h
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYWShopInfo.h"

@protocol MYWHistoryCellDelegate <NSObject>

- (void)didTapMapBtn:(NSString *)address;

@end


@interface MYWHistoryCell : UITableViewCell

@property (nonatomic) MYWShopInfo *shopInfo;

@property (nonatomic, assign) id<MYWHistoryCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end
