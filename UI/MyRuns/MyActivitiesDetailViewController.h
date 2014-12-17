//
//  MyActivitiesDetailViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/6/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"
#import "StativityTableViewController.h"


@interface MyActivitiesDetailViewController : StativityTableViewController
	<UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSArray * activities;
@property (nonatomic, retain) NSMutableArray * weeks;
@property (nonatomic, retain) NSMutableArray * months;
@property (nonatomic, retain) NSArray * prevActivities;
@property (nonatomic, retain) NSString * fontFamily;
@property (strong, nonatomic) IBOutlet UISegmentedControl *viewType;


-(void) activityChanged;
-(void) runsLoadedNotification : (NSNotification *) notification;

@end
