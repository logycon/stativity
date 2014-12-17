//
//  ActivityListViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 9/9/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"

@interface ActivityListViewController : StativityViewController
	<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString * activityType;
@property (nonatomic, strong) NSString * itemCode;
@property (nonatomic, strong) NSString * displayName;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

-(void) displayActivitiesOfType : (NSString *) _activityType andCode : (NSString *) _itemCode andDisplayName : (NSString *) _displayName;

@end
