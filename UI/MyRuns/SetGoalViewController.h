//
//  SetGoalViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 8/21/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"

@interface SetGoalViewController : StativityViewController

@property (strong, nonatomic) IBOutlet UITextField *tbGoal;
@property (strong, nonatomic) IBOutlet UILabel *lblUnits;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) NSString * activityType;
@property (strong, nonatomic) NSString * goalTimeFrame; // M or W or Y

@end
