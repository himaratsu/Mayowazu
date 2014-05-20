//
//  MYWPopAlertView.m
//  Mayowazu
//
//  Created by 平松　亮介 on 2014/05/20.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWPopAlertView.h"

@interface MYWPopAlertView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end



@implementation MYWPopAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit
{
    NSString *className = NSStringFromClass([self class]);
    [[NSBundle mainBundle] loadNibNamed:className owner:self options:0];
    
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

- (void)setUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    _urlLabel.text = urlStr;
}

- (IBAction)searchBtnTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(didTapOKBtn)]) {
        [_delegate didTapOKBtn];
    }
}

- (IBAction)closeBtnTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(didTapCancelBtn)]) {
        [_delegate didTapCancelBtn];
    }
}


@end
