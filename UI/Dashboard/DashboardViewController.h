//
//  DashboardViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PullToRefreshView.h"
#import "StativityViewController.h"

@interface DashboardViewController : StativityViewController
	<UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, PullToRefreshViewDelegate>

@property (nonatomic, strong) NSString * activityType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedActivityType;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UILabel *lblPeriod;


@end
