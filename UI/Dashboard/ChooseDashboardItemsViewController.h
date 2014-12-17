//
//  ChooseDashboardItemsViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"

@interface ChooseDashboardItemsViewController : StativityViewController
	<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString * activityType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedActivityType;

-(void) loadItems;

@end
