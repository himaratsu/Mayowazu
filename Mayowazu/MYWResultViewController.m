//
//  MYWResultViewController.m
//  Mayowazu
//
//  Created by 平松　亮介 on 2014/05/20.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWResultViewController.h"
#import "MYWShopInfo.h"
#import "MYWHistoryManager.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

@interface MYWResultViewController ()
<UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;

@property (weak, nonatomic) IBOutlet UITextView *shopNameField;
@property (weak, nonatomic) IBOutlet UITextView *addressTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;



@property (strong, nonatomic) IBOutletCollection(UITextView) NSArray *textViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;



@end


// Google MapsのAppStore URL
static NSString * const kGoogleMapStoreUrl = @"https://itunes.apple.com/jp/app/google-maps/id585027354?mt=8";


@implementation MYWResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _searchQuery;
    
    [self startSearching];
    
    [self loadWebPageWithUrl:_searchQuery];
    
    UIScreenEdgePanGestureRecognizer *edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(screenEdgeGesture:)];
    edgeGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgeGesture];
}

- (void)screenEdgeGesture:(id)tapGesture {
    NSLog(@"tap_gesture[%@]", tapGesture);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startSearching {
    [_textViews enumerateObjectsUsingBlock:^(UITextView *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = YES;
    }];
    [_labels enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = YES;
    }];
    [_buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.enabled = NO;
    }];
    [_indicator startAnimating];
}

- (void)endSearching {
    [_indicator stopAnimating];
    _indicator.hidden = YES;
    
    [_textViews enumerateObjectsUsingBlock:^(UITextView *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = NO;
        obj.text = @"";
    }];
    [_labels enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = NO;
    }];
    [_buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.enabled = YES;
    }];
}

- (void)loadWebPageWithUrl:(NSString *)url {
    // validate
    if (url == nil || [url isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"URLを入力してください"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    if (!_webView) {
        self.webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:req];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self endSearching];
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _shopNameField.text = title;
    
    NSString *host = webView.request.URL.host;
    
    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]) {
        // エラーハンドリング
        if ([webView.request.URL.absoluteString isEqualToString:@"http://s.tabelog.com/2800145/"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"食べログ エラー"
                                                            message:@"該当するお店を見つけられませんでした。URLが正しいかを確認してください"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            return;
        }
        
        // 食べログなら
        NSString *address = [self searchAddressForTabelog];
        _addressTextField.text = address;
        
        MYWShopInfo *shopInfo = [[MYWShopInfo alloc] initWithUrl:webView.request.URL.absoluteString
                                                           title:title
                                                         address:address];
        [[[MYWHistoryManager alloc] init] saveToHistory:shopInfo];
    }
    else if ([host isEqualToString:@"r.gnavi.co.jp"]
             || [host isEqualToString:@"mobile.gnavi.co.jp"]) {
        // エラーハンドリング
        if ([webView.request.URL.absoluteString isEqualToString:@"http://mobile.gnavi.co.jp/iphone/gnrl/gt-error/"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ぐるなび エラー"
                                                            message:@"該当するお店を見つけられませんでした。URLが正しいかを確認してください"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            return;
        }
        
        // ぐるなびなら
        NSString *address = [self searchAddressForGurunavi];
        _addressTextField.text = address;
        
        MYWShopInfo *shopInfo = [[MYWShopInfo alloc] initWithUrl:webView.request.URL.absoluteString
                                                           title:title
                                                         address:address];
        [[[MYWHistoryManager alloc] init] saveToHistory:shopInfo];
    }
    else {
        // どちらでもないなら
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"住所を検索できません。食べログかぐるなびのURLを入力してください"
                                               cancelButtonItem:nil
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"OK" action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }], nil];
        [alert show];
        
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"読み込みエラー[%@]", error);
    
    if (error.code == 101 || error.code == 102) {
        // 読み込めないURL
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"有効なURLを入力してください"
                                               cancelButtonItem:nil
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"OK"
                                                                                     action:^{
                                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                                     }], nil];
        [alert show];
    }
    else {
        // オフラインなど
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"ページにアクセスできません。ネットワーク状況の良い場所で再度お試しください"
                                               cancelButtonItem:nil
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"OK"
                                                                                     action:^{
                                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                                     }], nil];
        [alert show];
    }
    
    [self endSearching];
    
}


#pragma mark -

- (IBAction)backBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSString *)getEscapedString {
    NSString *query = _addressTextField.text;
    NSString *escapedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                   kCFAllocatorDefault,
                                                                                                   (CFStringRef)query,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8));
    return escapedString;
}

- (IBAction)openiOSMapBtnTouched:(id)sender {
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", [self getEscapedString]];
    [self openUrl:url];
}

- (IBAction)openGoogleMapBtnTouched:(id)sender {
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?q=%@", [self getEscapedString]];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
        [self openUrl:url];
    }
    else {
        // Google Mapをストアで開く
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ストアへ移動"
                                                        message:@"Google Mapsがインストールされていません。\nストアへ移動しますか？"
                                               cancelButtonItem:[RIButtonItem itemWithLabel:@"キャンセル"]
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"AppStoreを開く"
                                                                                     action:^{
                                                                                         // goto appstore
                                                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kGoogleMapStoreUrl]];
                                                                                     }], nil];
        [alert show];
    }
    
}

- (void)openUrl:(NSString *)url {
    NSLog(@"open url[%@]", url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


- (NSString *)searchAddressForTabelog {
    // PCサイト
    //    NSString *jsStr = @"document.getElementsByClassName('address')[0].getElementsByTagName('p')[0].innerText";
    
    // スマホサイト（食べログ）
    NSString *jsStr = @"document.getElementsByClassName('add data')[0].innerText";
    
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}


- (NSString *)searchAddressForGurunavi {
    // ぐるなび
    NSString *jsStr = @"document.getElementsByClassName('sh-t-data-tbl')[0].getElementsByTagName('td')[1].innerText";
    return [_webView stringByEvaluatingJavaScriptFromString:jsStr];
}



@end
