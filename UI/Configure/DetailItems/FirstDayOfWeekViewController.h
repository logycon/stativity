//
//  FirstDayOfWeekViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/9/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityTableViewController.h"

@interface FirstDayOfWeekViewController : StativityTableViewController

@property (strong, nonatomic) IBOutlet UITableView *firstDayTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;

@property (weak, nonatomic) id sender;

@end
