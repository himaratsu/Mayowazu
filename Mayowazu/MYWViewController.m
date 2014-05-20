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
//  - お店の情報を色々ととる（WebViewで詳細に飛べるとか）
//  - デザイン入れる
//  - 住所欄はUITextViewにして複数行対応
//  - エラー処理は、タイトルをみて判断
//
// --------------------------------------------------------------------------------



#import "MYWViewController.h"
#import "MYWResultViewController.h"
#import "MYWPopAlertView.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

@interface MYWViewController ()
<UITextFieldDelegate, MYWPopAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *siteUrlTextField;
@end


@implementation MYWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // TODO: あとでけす
    _siteUrlTextField.text = @"http://tabelog.com/hyogo/A2805/A280501/28001454/";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkPasteBoard];
}

// Pasteboardをチェックして
- (void)checkPasteBoard {
    NSString *lastPasteStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_PASTE_BOARD"];
    
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *string = [board valueForPasteboardType:@"public.text"];
    
    if (lastPasteStr && [lastPasteStr isEqualToString:string]) {
        // すでに表示したものは表示しない
        return;
    }
    
    // パターンにマッチすれば提案を出す
    NSString *host = [[NSURL URLWithString:string] host];
    if ([host isEqualToString:@"tabelog.com"]
        || [host isEqualToString:@"s.tabelog.com"]
        || [host isEqualToString:@"r.gnavi.co.jp"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"コピーしているURLがあります"
                                                        message:string
                                               cancelButtonItem:[RIButtonItem itemWithLabel:@"キャンセル"]
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"このURLを検索"
                                                                                     action:^{
                                                                                         _siteUrlTextField.text = string;
                                                                                         [self searchWithQuery];
                                                                                     }], nil];
        [alert show];
        
        // saveしておく
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:@"LAST_PASTE_BOARD"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


#pragma mark - IBAction

- (IBAction)searchBtnTouched:(id)sender {
    [self searchWithQuery];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == _siteUrlTextField) {
        [self searchWithQuery];
    }
    return YES;
}


- (void)searchWithQuery {
    // validate
    NSString *siteUrl = _siteUrlTextField.text;
    if (siteUrl == nil || [siteUrl isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"URLを入力してください"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    [self performSegueWithIdentifier:@"showResult" sender:siteUrl];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResult"]) {
        MYWResultViewController *vc = (MYWResultViewController *)segue.destinationViewController;
        vc.searchQuery = (NSString *)sender;
    }
}



@end
