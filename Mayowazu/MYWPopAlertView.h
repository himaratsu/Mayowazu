//
//  MYWPopAlertView.h
//  Mayowazu
//
//  Created by 平松　亮介 on 2014/05/20.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYWPopAlertViewDelegate <NSObject>

- (void)didTapOKBtn;
- (void)didTapCancelBtn;

@end



@interface MYWPopAlertView : UIView

@property (nonatomic, assign) id<MYWPopAlertViewDelegate> delegate;
@property (nonatomic) NSString *urlStr;

@end
