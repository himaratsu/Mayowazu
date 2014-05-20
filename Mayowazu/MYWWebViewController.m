//
//  MYWWebViewController.m
//  Mayowazu
//
//  Created by 平松　亮介 on 2014/05/20.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWWebViewController.h"

@interface MYWWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end



@implementation MYWWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *URL = [NSURL URLWithString:_urlStr];
    [_webView loadRequest:[NSURLRequest requestWithURL:URL]];
}


@end
