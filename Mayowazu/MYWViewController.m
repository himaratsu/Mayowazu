//
//  MYWViewController.m
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//


// --------------------------------------------------------------------------------
// ぐるなび
//    NSString *url = @"http://r.gnavi.co.jp/bfevk1410000";

// 食べログ
//    NSString *pcUrl = @"http://tabelog.com/hyogo/A2805/A280501/28001454/";
//    NSString *smUrl = @"http://s.tabelog.com/yamaguchi/A3502/A350201/35007869";
//
// --------------------------------------------------------------------------------


// --------------------------------------------------------------------------------
// 作りたい機能
//  - アプリ起動時にペーストボードをチェックする（食べログ / ぐるなび ならAlertで訪ねる）
//  - 履歴（オフラインキャッシュ）
//  - お店の情報を色々ととる（WebViewで詳細に飛べる）
//  - デザイン入れる
//  - 
// --------------------------------------------------------------------------------



#import "MYWViewController.h"
#import "MYWHistoryManager.h"
#import "MYWShopInfo.h"

@interface MYWViewController ()
<UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic) UIWebView *webView;

@property (weak, nonatomic) IBOutlet UITextField *siteUrlTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *shopNameField;


@end


@implementation MYWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // TODO: あとでけす
    _siteUrlTextField.text = @"http://r.gnavi.co.jp/bfevk1410000";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkPasteBoard];
}

// Pasteboardをチェックして
- (void)checkPasteBoard {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *string = [board valueForPasteboardType:@"public.text"];

    // パターンにマッチすれば提案を出す
    NSString *host = [[NSURL URLWithString:string] host];
    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]
        || [host isEqualToString:@"r.gnavi.co.jp"]) {
        
        // TODO: bottomからviewが出てくるタイプにする
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"コピーしているURLから検索しますか？"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

- (void)loadWebPageWithUrl:(NSString *)url {
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
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _shopNameField.text = title;
    
    NSString *host = webView.request.URL.host;

    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]) {
        // 食べログなら
        NSString *address = [self searchAddressForTabelog];
        _addressTextField.text = address;
        
        MYWShopInfo *shopInfo = [[MYWShopInfo alloc] initWithUrl:webView.request.URL.absoluteString
                                                           title:title
                                                         address:address];
        [[[MYWHistoryManager alloc] init] saveToHistory:shopInfo];
    }
    else if ([host isEqualToString:@"r.gnavi.co.jp"]) {
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"すみません"
                                                        message:@"住所を検索できません。食べログかぐるなびのURLを入力してください"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"読み込みエラー[%@]", error);
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        NSString *string = [board valueForPasteboardType:@"public.text"];
        
        _siteUrlTextField.text = string;
        [self loadWebPageWithUrl:_siteUrlTextField.text];
    }
}


#pragma mark - IBAction

- (IBAction)searchBtnTouched:(id)sender {
    [self loadWebPageWithUrl:_siteUrlTextField.text];
}

- (IBAction)openiOSMapBtnTouched:(id)sender {
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", _addressTextField.text];
    [self openUrl:url];
}

- (IBAction)openGoogleMapBtnTouched:(id)sender {
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?q=%@", _addressTextField.text];
    [self openUrl:url];
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
