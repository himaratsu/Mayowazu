//
//  MYWHistoryCell.m
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWHistoryCell.h"

@implementation MYWHistoryCell

- (IBAction)mapBtnTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(didTapMapBtn:)]) {
        [_delegate didTapMapBtn:_addressLabel.text];
    }
}

@end
