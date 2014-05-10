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
    return [_historys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MYWHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    MYWShopInfo *shopInfo = _historys[indexPath.row];
    
    cell.delegate = self;
    cell.shopNameLabel.text = shopInfo.title;
    cell.addressLabel.text = shopInfo.address;
    
    return cell;
}


#pragma mark - MYWHistoryCellDelegate

- (void)didTapMapBtn:(NSString *)address {
    // TODO: action sheetでアプリを選べるように
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", address];
    [self openUrl:url];
}

- (void)openUrl:(NSString *)url {
    NSLog(@"open url[%@]", url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


@end
