//
//  ActivityDetailViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/7/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Activity.h"
#import "ActivityDetail.h"
#import "StativityViewController.h"

@interface ActivityDetailViewController : StativityViewController
	<MKMapViewDelegate, UITableViewDataSource, 
	UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate
>

@property (strong, nonatomic) IBOutlet UISegmentedControl *viewMode;
@property (nonatomic, weak) Activity * activity;
@property (nonatomic, strong) NSArray * activityDetail;
@property (nonatomic, strong) NSMutableArray * distances;
@property (nonatomic, strong) NSArray * miles;
@property (nonatomic, strong) NSArray * kms;
@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (strong, nonatomic) IBOutlet MKMapView *detailMap;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;
@property (strong, nonatomic) IBOutlet UILabel *lblPace;
@property (strong, nonatomic) IBOutlet UILabel *lblSpeed;
@property (strong, nonatomic) IBOutlet UILabel *lblUnits;
@property (strong, nonatomic) IBOutlet UILabel *lblWhen;
@property (strong, nonatomic) IBOutlet UITableView *detailTable;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalTime;
@property (strong, nonatomic) IBOutlet UILabel *lblCalories;
@property (strong, nonatomic) IBOutlet UIImageView *imgSource;
@property (strong, nonatomic) IBOutlet UIImageView *imgHeartRate;
@property (strong, nonatomic) IBOutlet UILabel *lblHeartRate;

-(void) displayDetail;
-(void) runsLoaded;


@end
