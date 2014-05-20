//
//  MYWHistoryViewController.m
//  Mayowazu
//
//  Created by himara2 on 2014/05/10.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "MYWHistoryViewController.h"
#import "MYWHistoryManager.h"
#import "MYWHistoryCell.h"
#import "MYWShopInfo.h"
#import "MYWWebViewController.h"
#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>

@interface MYWHistoryViewController ()
<UITableViewDataSource, UITableViewDelegate,
MYWHistoryCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *historys;

@end



@implementation MYWHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self reload];
}

- (void)reload {
    MYWHistoryManager *manager = [[MYWHistoryManager alloc] init];
    self.historys  = [manager historys];
    
    [_tableView reloadData];
}

- (IBAction)closeBtnTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX([_historys count], 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    if ([_historys count] == 0) {
        cellIdentifier = @"NoCell";
    }
    else {
        cellIdentifier = @"Cell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_historys count] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoCell"];
        return cell;
    }
    
    MYWHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    MYWShopInfo *shopInfo = _historys[indexPath.row];
    
    cell.delegate = self;
    cell.shopInfo = shopInfo;
    cell.shopNameLabel.text = shopInfo.title;
    cell.addressLabel.text = shopInfo.address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MYWHistoryCellDelegate

- (NSString *)getEscapedString:(NSString *)originStr {
    NSString *query = originStr;
    NSString *escapedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                   kCFAllocatorDefault,
                                                                                                   (CFStringRef)query,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8));
    return escapedString;
}

- (void)didTapMapBtn:(NSString *)address {
    // TODO: action sheetでアプリを選べるように
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", [self getEscapedString:address]];
    [self openUrl:url];
}

- (void)openUrl:(NSString *)url {
    NSLog(@"open url[%@]", url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


- (IBAction)clearAllButtonTouched:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"履歴をすべて削除しますか？"
                                               cancelButtonItem:[RIButtonItem itemWithLabel:@"キャンセル"]
                                          destructiveButtonItem:nil
                                               otherButtonItems:
                            [RIButtonItem itemWithLabel:@"はい"
                                                 action:^{
                                                     // clear all
                                                     MYWHistoryManager *manager =  [[MYWHistoryManager alloc] init];
                                                     [manager clearAll];
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self reload];
                                                     });
                                                     
                                                 }], nil];
    [sheet showInView:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWeb"]) {
        MYWHistoryCell *cell = (MYWHistoryCell *)sender;
        MYWShopInfo *shopInfo = cell.shopInfo;
        
        MYWWebViewController *webVC = segue.destinationViewController;
        webVC.urlStr = shopInfo.url;
    }
}


@end
