//
//  MyUnitsController.h
//  Stativity
//
//  Created by Igor Nakshin on 6/4/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityTableViewController.h"

@interface MyUnitsController : StativityTableViewController

@property (strong, nonatomic) IBOutlet UITableView *unitsTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;

@property (weak, nonatomic) id sender;

@end
