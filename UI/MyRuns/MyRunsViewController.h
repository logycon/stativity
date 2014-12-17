//
//  MyRunsViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityTableViewController.h"
#import "PullToRefreshView.h"


@interface MyRunsViewController : StativityTableViewController
	<PullToRefreshViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSArray * activities;
@property (nonatomic, retain) NSArray * prevActivities;
@property (nonatomic, strong) IBOutlet UISegmentedControl *summaryOrDetail;
@property (nonatomic, weak) UIButton * disclosureButton;

-(void) runsLoaded;
-(void) runsLoadedNotification : (NSNotification *) notification;

@end
