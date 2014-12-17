//
//  RemindersViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 8/23/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityTableViewController.h"

@interface RemindersViewController : UITableViewController
	<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *switchEnabled;
@property (strong, nonatomic) IBOutlet UITextField *tbHours;
@property (strong, nonatomic) IBOutlet UIButton *btnShowSample;
@property (strong, nonatomic) IBOutlet UILabel *lblNextReminder;
@property id delegate;

@end
