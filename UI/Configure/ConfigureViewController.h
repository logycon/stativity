//
//  ConfigureViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityTableViewController.h"

@interface ConfigureViewController : UITableViewController
	<UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *configureTable;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentUnits;

@property (strong, nonatomic) IBOutlet UILabel *lblRunkeeperStatus;
@property (strong, nonatomic) IBOutlet UIImageView *imgCircle;

@property (strong, nonatomic) IBOutlet UILabel *lblFirstDayOfWeek;

@property (strong, nonatomic) IBOutlet UILabel *lblEndomondoStatus;
@property (strong, nonatomic) IBOutlet UIImageView *lblEndomondoGreen;

@property (strong, nonatomic) IBOutlet UILabel *lblGarminStatus;
@property (strong, nonatomic) IBOutlet UIImageView *lblGarminGreen;

@property (strong, nonatomic) IBOutlet UILabel *lblNextReminder;

-(void) runsLoaded;
-(void) doLoadView;

@end
