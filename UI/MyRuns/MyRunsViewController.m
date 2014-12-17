//
//  MyRunsViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "MyRunsViewController.h"
#import "Tracker.h"
#import "StativityData.h"
#import "Activity.h"
#import "PullToRefreshView.h"
#import "IIViewDeckController.h"
#import "LeftMenuViewController.h"
#import "Me.h"
#import "ActivityFormatter.h"
#import "Utilities.h"
#import "MyActivitiesDetailViewController.h"
#import "AppDelegate.h"
#import "ActivityDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "SetGoalViewController.h"
#import "F3BarGauge.h"
#import "DistanceGoal.h"
#import "Reminder.h"

@interface MyRunsViewController ()

@property (nonatomic, strong) NSString * tweetText;
@property (nonatomic, strong) PullToRefreshView * pullView;
@property (nonatomic, strong) SetGoalViewController * goalSetViewController;

@end

@implementation MyRunsViewController

MyActivitiesDetailViewController * detailView;

@synthesize managedObjectContext;
@synthesize activities;
@synthesize prevActivities;
@synthesize summaryOrDetail;
@synthesize activityType;
@synthesize disclosureButton;
@synthesize tweetText;
@synthesize pullView;
@synthesize goalSetViewController;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

-(void) updateArrays {
	for(int i = 0; i < [self.activities count]; i++) {
		Activity * run = [self.activities objectAtIndex:i];
		[run updateTimeComponents];
	}
	
	for(int i = 0; i < [self.prevActivities count]; i++) {
		Activity * run = [self.prevActivities objectAtIndex: i];
		[run updateTimeComponents];
	}
}

-(void) runsLoadedNotification:(NSNotification *)notification {
	int newActivities = -1;
	if (notification.object) newActivities = [notification.object intValue];
	[self newActivitiesWereLoaded: newActivities];
	[Reminder updateReminder];
}


-(void) newActivitiesWereLoaded : (int) newActivities {
	//[self runsLoaded];
	if (newActivities >= 0) {
		if (newActivities == 1) {
			//[pullView performSelectorOnMainThread: @selector(closeIt) withObject:nil waitUntilDone:NO];			[self.view setNeedsDisplay];
			StativityData * rkd = [StativityData get];
			Activity * activity = [rkd getLastActivity];
			ActivityDetailViewController * detail = (ActivityDetailViewController *) [self.storyboard 
					instantiateViewControllerWithIdentifier: @"activityDetail"];

				[detail setActivity: activity];	
				detail.wantsFullScreenLayout = YES;
				detail.hidesBottomBarWhenPushed = YES;
				[self.navigationController pushViewController: detail animated: YES];
				[detail displayDetail];
				
		}
		else {
			//[pullView performSelectorOnMainThread: @selector(closeIt) withObject:nil waitUntilDone:NO];
			[self.view setNeedsDisplay];
			if (newActivities == 0) {
				[pullView finishedLoading];
				UIAlertView * alert = [[UIAlertView alloc]
					initWithTitle: @"No New Activities" 
					message: @"You don't have new activities since last refresh." 
					delegate:nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
				[alert show];
			}
			else {
				NSString * formatText = @"";
				NSString * title = @"";
				[Me refreshUIColor];
				if (newActivities == 1) {
					formatText = @"Added 1 new activity";
					title = @"New Activity Added";
				}
				else {
					formatText = @"Added %d new activities";
					title = @"New Activities Added";
				}
			
				NSString * text = [NSString stringWithFormat: formatText, newActivities ];
				UIAlertView * alert = [[UIAlertView alloc]
					initWithTitle: title
					message: text 
					delegate:nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
				[alert show];
			}
		}
	}
	[self runsLoaded];

}

-(void) runsLoaded {
	[self loadRuns];
	[self setupUI];
	[self.tableView reloadData];
	[self updateArrays];
	[self.tableView setEditing: NO];
	self.view.userInteractionEnabled = YES;
	[Me refreshUIColor];
	//[pullView performSelectorOnMainThread: @selector(closeIt) withObject:nil waitUntilDone:NO];	
	[pullView finishedLoading];		
	[self.view setNeedsDisplay];
	//[pullView finishedLoading];
}

-(void) viewWillAppear:(BOOL)animated {
	if (!pullView) {
		pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
		[pullView setDelegate:self];
		[pullView refreshLastUpdatedDate];
		[self.tableView addSubview:pullView];
	}
	[self.tableView reloadData];
}

-(void) loadRuns {
	StativityData * appData = [StativityData get];
	
	NSDate * startDate = [Me getTimeframeStart];
	NSDate * endDate = [Me getTimeframeEnd];
	self.activities = [appData fetchActivitiesBetweenStartDate: startDate andEndDate: endDate ofType : self.activityType];
	
	NSDate * prevStart = [Me getPrevTimeframeStart];
	NSDate * prevEnd = [Me getPrevTimeframeEnd];
	self.prevActivities = [appData fetchActivitiesBetweenStartDate: prevStart andEndDate: prevEnd ofType : self.activityType];
	[self.tableView setEditing: NO];
	
}	

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) setupUI {
	UIColor * uiColor = [Me getUIColor];
	[self.navigationController.navigationBar setTintColor: uiColor];
	//[self.tabBarController.tabBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor],UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor, nil];
	[self.navigationController.navigationBar setTitleTextAttributes: attributes];*/	
	
	// change title only in the top bar, not in the button of the tabbed controller
	
	//self.navigationItem.title = [NSString stringWithFormat: @"My Runs", [NikePlus getTotalRuns]];
	//self.navigationItem.title = @"My Runs";
	
	//self.summaryOrDetail.segmentedControlStyle.
	
	UIFont *font = [UIFont fontWithName: [Utilities fontFamily] size :12.0f];
	NSDictionary *fontAttr = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
	[self.summaryOrDetail setTitleTextAttributes:fontAttr forState:UIControlStateNormal];

}

-(void) timeframeChanged {
	[self runsLoaded];
}

-(void) updateActivityType {
	switch(summaryOrDetail.selectedSegmentIndex) {
		case 0 : {
			self.activityType = @"Running";
			break;
		}
		case 1 : {
			self.activityType = @"Cycling";
			break;
		}
		case 2 : {
			self.activityType = @"Walking";
			break;
		}
		case 3 : {
			self.activityType = @"";
			break;
		}
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSNumber * option = [[NSUserDefaults standardUserDefaults] objectForKey: @"activityType"];
	if (option) {
		summaryOrDetail.selectedSegmentIndex = [option intValue];
		[self updateActivityType];
	}	
	else {
		self.activityType = @"Running";
	}
	
	[self.tabBarController.tabBar setTintColor: [Me getTabBarColor]]; 
	self.navigationController.navigationBar.tintColor = [Me getUIColor];
	
	[self setupUI];
	[self loadRuns];
	[self updateArrays];
	
	// load left menu UX
	UIImage * img = [UIImage imageNamed: @"259-list.png"];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
		initWithImage: img
		style: UIBarButtonItemStyleBordered
		target:self.viewDeckController 
		action:@selector(toggleLeftView)];	
	
	// load pull to refresh
	if (!pullView) {
		pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
		[pullView setDelegate:self];
		[pullView refreshLastUpdatedDate];
		[self.tableView addSubview:pullView];
	}
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(runsLoadedNotification:) 
        name:@"runsLoaded"
        object:nil];
	
	// register for notification
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector : @selector(timeframeChanged)
		name : @"TimeframeChanged"
		object : nil];
	
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector : @selector(failedLoadingData)
		name : @"failedLoadingData"
		object: nil];
		
	[[NSNotificationCenter defaultCenter]
		addObserver: self 
		selector: @selector(homeScreenImageChanged) 
		name: @"HomeScreenImageChanged"
		object:nil];
	
	// table gesture recognizer for up swipe
	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] 
		initWithTarget:self 
        action:@selector(handleSwipeUp:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.tableView addGestureRecognizer:recognizer];
	
	// Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) failedLoadingData {
	[pullView finishedLoading];
	self.view.userInteractionEnabled = YES;
}

-(void) loadNewActivities {
	self.view.userInteractionEnabled = NO;
	
	[Tracker getFitnessActivities: @""];
	
	NSDate * lastRefresh = [Utilities currentLocalTime];
	[[NSUserDefaults standardUserDefaults] setValue: lastRefresh forKey: @"lastRefresh"];
	
	//[self newActivitiesWereLoaded: newActivities];
	//[self setupUI]; <- called after the data is received
}


- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view 
{
	//[self performSelectorInBackground: @selector(loadNewActivities) withObject:nil];
	if ([Tracker connected]) {
		[self loadNewActivities];
	}
	else {
		[pullView finishedLoading];
		UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: @"Not connected" 
				message: @"You are not connected any Tracker. Tap Setup and make selection in Choose My Tracker section." 
				delegate:nil 
				cancelButtonTitle: @"OK" otherButtonTitles:nil];
			[alert show];
		
	}
}

-(NSDate *) pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
	return [[NSUserDefaults standardUserDefaults] valueForKey: @"lastRefresh"];
}

- (void)viewDidUnload
{
	[pullView stopObserving];
	[self setSummaryOrDetail:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [Me getTimeframeName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 370;
}

- (IBAction)summaryOrDetailChanged:(id)sender {
	[self updateActivityType];
	
	NSNumber * option = [NSNumber numberWithInt : summaryOrDetail.selectedSegmentIndex];
	[[NSUserDefaults standardUserDefaults] setObject: option forKey: @"activityType"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self loadRuns];
	[self setupUI];
	[self.tableView reloadData];
	[self updateArrays];

	[self.tableView setEditing: NO];
	self.view.userInteractionEnabled = YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self getSummaryCell : tableView];
}

-(float) getTotalDistance : (NSArray *) _runs {
	float retval = 0;
	for (int i = 0; i < [_runs count]; i++) {
		Activity * run = [_runs objectAtIndex: i];
		retval += [run.total_distance floatValue];
	}
	return retval;
}

-(float) getTotalDuration : (NSArray *) _runs {
	float retval = 0;
	for (int i = 0; i < [_runs count]; i++) {
		Activity * run = [_runs objectAtIndex: i];
		retval += [run.duration floatValue];
	}
	return retval;
}

-(void) homeScreenImageChanged {
	[self.tableView reloadData];
}

-(UITableViewCell *) getSummaryCell : (UITableView *) tableView {
	static NSString * CellIndentifier = @"summarycell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
	}
	
	//tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	NSString * imagePath = [Me getHomeScreenImageName];
	UIImage * image = [UIImage imageNamed : imagePath];
	if (!image) {
		// draw userHome.png from documents dir
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentsDirectory = [paths objectAtIndex:0];
		// display
		UIImage * userHome = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/userHome.png", documentsDirectory]];
		CGRect boundsRect = CGRectMake(5, 5, 325, 372);
		CGImageRef imageRef = CGImageCreateWithImageInRect([userHome CGImage], boundsRect);
		UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
		cell.backgroundView = [[UIImageView alloc] initWithFrame: boundsRect ]; //initWithImage: userHome];
		cell.backgroundView.alpha = [[Me getHomeImageOpacity] floatValue];
		cell.backgroundView.contentMode = UIViewContentModeCenter;
		[((UIImageView *) cell.backgroundView) setImage: croppedImage];
			}
	else {
		CGRect boundsRect = CGRectMake(5, 5, 325, 372);
		cell.backgroundView = [[UIImageView alloc] initWithFrame: boundsRect]; //initWithImage: image];
		cell.backgroundView.alpha = [[Me getHomeImageOpacity] floatValue];// 0.35; //0.35;
		cell.backgroundView.contentMode = UIViewContentModeCenter;
		CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], boundsRect);
		UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
		
		[((UIImageView *) cell.backgroundView) setImage: croppedImage];
	}

	disclosureButton = (UIButton  *) [cell viewWithTag: 91];
		
	UILabel * distanceLabel = (UILabel *) [cell viewWithTag:1];
	distanceLabel.font = [UIFont fontWithName: [Utilities fontFamily] size:95];
	
	int fontSize = 17;
	
	NSString * timeframeName = [[Me getTimeframeName] uppercaseString];
	NSString * prevTimeframeName = [[Me getPrevTimeframeName] uppercaseString];
	
	BOOL allTime = [timeframeName isEqualToString: @"ALL-TIME"];
	
	UILabel * numberOfRuns = (UILabel *) [cell viewWithTag: 2];
	numberOfRuns.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UILabel * prevNumberOfRuns = (UILabel *) [cell viewWithTag: 20];
	prevNumberOfRuns.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UIImageView * imgNumberOfRuns = (UIImageView *) [cell viewWithTag: 200];
	imgNumberOfRuns.hidden= allTime;
	prevNumberOfRuns.hidden = allTime;
	if (allTime) {
	  numberOfRuns.center = imgNumberOfRuns.center;
	}
	else numberOfRuns.center = CGPointMake(72, numberOfRuns.center.y); // width / 2
	
	UILabel * timeOnTheRoad = (UILabel *) [cell viewWithTag: 3];
	timeOnTheRoad.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UILabel * prevTimeOnTheRoad = (UILabel *) [cell viewWithTag: 30];
	prevTimeOnTheRoad.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UIImageView * imgTimeOnTheRoad = (UIImageView *) [cell viewWithTag: 300];
	imgTimeOnTheRoad.hidden = allTime;
	prevTimeOnTheRoad.hidden = allTime;
	if (allTime) {
		timeOnTheRoad.center = imgTimeOnTheRoad.center;
	}
	else timeOnTheRoad.center = CGPointMake(72, timeOnTheRoad.center.y);
	
	UILabel * averageSpeed = (UILabel *) [cell viewWithTag: 4];
	averageSpeed.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UILabel * prevAverageSpeed = (UILabel *) [cell viewWithTag: 40];
	prevAverageSpeed.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UIImageView * imgAverageSpeed = (UIImageView *) [cell viewWithTag: 400];
	imgAverageSpeed.hidden = allTime;
	prevAverageSpeed.hidden = allTime;
	if (allTime) {
		averageSpeed.center = imgAverageSpeed.center;
	}
	else averageSpeed.center = CGPointMake(72, averageSpeed.center.y);
	
	
	UILabel * distanceUnits = (UILabel *) [cell viewWithTag: 5];
	distanceUnits.font = [UIFont fontWithName: [Utilities fontFamily] size:17];
	UILabel * periodLabel = (UILabel *) [cell viewWithTag: 6];
	
	UILabel * paceLabel = (UILabel *) [cell viewWithTag: 7];
	paceLabel.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UILabel * prevPaceLabel = (UILabel *) [cell viewWithTag: 70];
	prevPaceLabel.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UIImageView * imgPace = (UIImageView *) [cell viewWithTag: 700];
	imgPace.hidden = allTime;
	prevPaceLabel.hidden = allTime;
	if (allTime) {
		paceLabel.center = imgPace.center;
	}
	else paceLabel.center = CGPointMake(72, paceLabel.center.y);
	
	UILabel * periodName = (UILabel *) [cell viewWithTag: 8];
	periodName.font = [UIFont fontWithName: [Utilities fontFamily] size:12];
	UILabel * prevPeriodName = (UILabel *) [cell viewWithTag: 80];
	prevPeriodName.font = [UIFont fontWithName: [Utilities fontFamily] size:12];
	prevPeriodName.hidden = allTime;
	periodName.hidden = allTime;

	
	UILabel * distance = (UILabel *) [cell viewWithTag: 9];
	distance.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UILabel * prevDistance = (UILabel *) [cell viewWithTag:90];
	prevDistance.font = [UIFont fontWithName: [Utilities fontFamily] size:fontSize];
	UIImageView * imgDistance = (UIImageView *) [cell viewWithTag: 900];
	imgDistance.hidden = allTime;
	prevDistance.hidden = allTime;
	if (allTime) {
		distance.center = imgDistance.center;
	}
	else distance.center = CGPointMake(72, distance.center.y);
	
	UILabel * asOfLabel = (UILabel *) [cell viewWithTag: 1000];
	asOfLabel.font = [UIFont fontWithName: [Utilities fontFamily] size:12];
	NSDate * lastRefresh = [[NSUserDefaults standardUserDefaults] valueForKey: @"lastRefresh"];
	if (lastRefresh) {
		NSDateFormatter * df = [[NSDateFormatter alloc] init];
		[df setDateStyle:NSDateFormatterMediumStyle];
		[df setTimeStyle:NSDateFormatterMediumStyle];
		[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		//df.dateFormat = @"EEE, MMM d yyyy hh:mma";
		//[df setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
		asOfLabel.text = [@"As of " stringByAppendingString: [df stringFromDate: lastRefresh]];
	}
	else {
		asOfLabel.text= @"";
	}

	int numRuns = [self.activities count];
	int prevNumRuns = [self.prevActivities count];
	
	if (numRuns < prevNumRuns) {
		[imgNumberOfRuns setImage: [UIImage imageNamed: @"arrow_reddown.png"]];
	}
	else {
		if (numRuns > prevNumRuns) {
			[imgNumberOfRuns setImage:[UIImage imageNamed: @"arrow_greenup.png"]];
		}
		else {
			[imgNumberOfRuns setImage: nil];
		}
	}
	
	NSNumber * _totalDistance = [NSNumber numberWithFloat: [self getTotalDistance: self.activities]];
	NSNumber * _totalDuration = [NSNumber numberWithFloat: [self getTotalDuration: self.activities]];
	ActivityFormatter * totalRun = [ActivityFormatter initWithDuration: _totalDuration andDistance: _totalDistance];
	
	//int numPrevRuns = [self.prevRuns count];
	NSNumber * _prevTotalDistance = [NSNumber numberWithFloat: [self getTotalDistance: self.prevActivities]];
	NSNumber * _prevTotalDuration = [NSNumber numberWithFloat: [self getTotalDuration: self.prevActivities]];
	ActivityFormatter * prevTotalRun = [ActivityFormatter initWithDuration: _prevTotalDuration andDistance: _prevTotalDistance];
	
	periodName.text = timeframeName;
	prevPeriodName.text = prevTimeframeName;

	float speed = [[totalRun getSpeed] floatValue];
	float prevSpeed = [[prevTotalRun getSpeed] floatValue];
	averageSpeed.text = [totalRun getSpeedFormatted];
	prevAverageSpeed.text = [prevTotalRun getSpeedFormatted];
	
	if (prevSpeed <= 0) {
		[imgAverageSpeed setImage: nil];
	}
	else {
		if (speed > prevSpeed) {
			[imgAverageSpeed setImage: [UIImage imageNamed: @"arrow_greenup.png"]];
		}
		else {
			if (speed < prevSpeed) {
				[imgAverageSpeed setImage: [UIImage imageNamed: @"arrow_reddown.png"]];
			}
			else {
				[imgAverageSpeed setImage: nil];
			}
		}
	}
	
	float pace = [[totalRun getPace] floatValue];
	float prevPace = [[prevTotalRun getPace] floatValue];
	paceLabel.text = [totalRun getPaceFormatted];
	prevPaceLabel.text = [prevTotalRun getPaceFormatted];
	
	if (prevPace <= 0) {
		[imgPace setImage: nil];
	}
	else {
		if (pace < prevPace) {
			[imgPace setImage: [UIImage imageNamed: @"arrow_greendown.png"]];
		}
		else {
			if (pace > prevPace) {
				[imgPace setImage: [UIImage imageNamed: @"arrow_redup.png"]];
			}
			else {
				[imgPace setImage: nil];
			}
		}
	}
	imgPace.hidden = allTime;
	
	// number of runs
	numberOfRuns.text = [NSString stringWithFormat: @"%d", numRuns];
	if (numRuns == 1) {
		numberOfRuns.text = [numberOfRuns.text stringByAppendingString: @" time"];
	}
	else {
		numberOfRuns.text = [numberOfRuns.text stringByAppendingString: @" times"];
	}
	prevNumberOfRuns.text = [NSString stringWithFormat : @"%d", prevNumRuns];
	if (prevNumRuns == 1) {
		prevNumberOfRuns.text = [prevNumberOfRuns.text stringByAppendingString: @" time"];
	}
	else {
		prevNumberOfRuns.text = [prevNumberOfRuns.text stringByAppendingString: @" times"];
	}
	
	if (numRuns < prevNumRuns) {
		[imgNumberOfRuns setImage: [UIImage imageNamed: @"arrow_reddown.png"]];
	}
	else {
		if (numRuns > prevNumRuns) {
			[imgNumberOfRuns setImage: [UIImage imageNamed: @"arrow_greenup.png"]];
		}
		else {
			[imgNumberOfRuns setImage: nil];
		}
	}
	imgNumberOfRuns.hidden = allTime;
	
	// time on the road
	float duration = [totalRun.duration floatValue];
	float prevDuration = [prevTotalRun.duration floatValue];
	timeOnTheRoad.text = [totalRun getDurationFormatted];
	prevTimeOnTheRoad.text = [prevTotalRun getDurationFormatted];
	if (duration < prevDuration) {
		[imgTimeOnTheRoad setImage: [UIImage imageNamed: @"arrow_reddown.png"]];
	}
	else {
		if (duration > prevDuration) {
			[imgTimeOnTheRoad setImage: [UIImage imageNamed: @"arrow_greenup.png"]];
		}
		else {
			[imgTimeOnTheRoad setImage: nil];
		}
	}
	imgTimeOnTheRoad.hidden = allTime;
	
	NSString * distanceText = @"";
	if ([[Me getMyUnits] isEqualToString: @"M"]) {
		distanceText = @"miles";
		distanceUnits.text = @"miles";
		
		float miles = [[totalRun getMiles] floatValue];
		if (miles > 999) {
			distanceLabel.text = [NSString stringWithFormat : @"%d", [[totalRun getMiles] intValue]];
		}
		else {
			distanceLabel.text = [NSString stringWithFormat: @"%.1f", miles]; //%.2f
		}
		
		distance.text = [distanceLabel.text stringByAppendingString : @" miles"];
		
		float prevMiles = [[prevTotalRun getMiles] floatValue];
		prevDistance.text = [[NSString stringWithFormat: @"%.1f", prevMiles] stringByAppendingString: @" miles"];
		
		if (miles >  prevMiles) {
			[imgDistance setImage: [UIImage imageNamed: @"arrow_greenup.png"]]; 
		}
		else {
			if (miles < prevMiles) {
				[imgDistance setImage : [UIImage imageNamed : @"arrow_reddown.png"]];
			}
			else {
				[imgDistance setImage: nil];
			}
		}
	}
	else {
		distanceText = @"km";
		distanceUnits.text = @"km";
		
		double km = [[totalRun distance] floatValue] / 1000;
		if (km > 1000) {
			distanceLabel.text = [NSString stringWithFormat: @"%d", [[NSNumber numberWithFloat: km] intValue]];
		}
		else {
			distanceLabel.text = [NSString stringWithFormat: @"%.1f", km];
		}
		
		distance.text = [distanceLabel.text stringByAppendingString: @" km"];
		
		double prevKm = [[prevTotalRun distance] floatValue] / 1000 ;
		prevDistance.text = [[NSString stringWithFormat: @"%.1f", prevKm] stringByAppendingString: @" km"];
		
		if (km >  prevKm) {
			[imgDistance setImage: [UIImage imageNamed: @"arrow_greenup.png"]]; 
		}
		else {
			if (km < prevKm) {
				[imgDistance setImage : [UIImage imageNamed : @"arrow_reddown.png"]];
			}
			else {
				[imgDistance setImage: nil];
			}
		}
	}
	
	imgDistance.hidden = allTime;
	distanceLabel.textColor = [Me getUIColor];
	distance.hidden = allTime;

	NSString * action = @"";
		//NSLog(@"%@ " , self.activityType);
	if ([self.activityType isEqualToString: @"Running"]) {
		action = @"ran";
		distanceUnits.text = [distanceUnits.text stringByAppendingFormat: @" %@", @"ran"];
	}
	if ([self.activityType isEqualToString: @"Cycling"]) {
		action = @"biked";
		distanceUnits.text = [distanceUnits.text stringByAppendingFormat: @" %@", @"biked"];
	}
	if ([self.activityType isEqualToString: @"Walking"]) {
		action = @"walked";
		distanceUnits.text = [distanceUnits.text stringByAppendingFormat: @" %@", @"walked"];
	}
	//NSLog(@"%@", distanceUnits.text);
	
	periodLabel.text = [[Me getTimeframeName] uppercaseString];
	periodLabel.font = [UIFont fontWithName: [Utilities fontFamily] size:17];
	
	// hide comparison images for this week, this month and this year
	if ([Me isTimeframeThis]) {
		if (duration == 0) {
			[imgPace setImage: nil];
			[imgAverageSpeed setImage: nil];
		}
		[imgDistance setImage: nil];
		[imgNumberOfRuns setImage: nil];
		[imgTimeOnTheRoad setImage: nil];
	}


	// tweet
	self.tweetText = @"";
	self.tweetText = [self.tweetText stringByAppendingFormat: @"%@ ", [Me getTimeFrameProperCased]];
	self.tweetText = [self.tweetText stringByAppendingFormat: @"%@ ", action];
	self.tweetText = [self.tweetText stringByAppendingFormat: @"%@ ", distance.text];
	self.tweetText = [self.tweetText stringByAppendingFormat: @"with avg pace of %@", paceLabel.text];
	
	// gauge
	UILabel *lblGauge = (UILabel *) [cell viewWithTag: 121];
	F3BarGauge * gauge = (F3BarGauge *) [cell viewWithTag: 120];
	StativityData * sd = [StativityData get];
	NSString * frequency = [Me getMyTimeframe];
	Timeframe tf = [Me getTimeframe];
	DistanceGoal * goal = [sd findDistanceGoalForActivity: self.activityType andFrequency: frequency];
	NSString * units = [Me getMyUnits];
	BOOL gaugeVisible = ((tf == ThisWeek) || (tf == ThisMonth) || (tf == ThisYear));
	
	if (gaugeVisible) {
	
		gauge.normalBarColor = [Me getUIColor]; 
		gauge.warningBarColor = [Me getUIColor];
		gauge.dangerBarColor = [Me getUIColor];
		gauge.outerBorderColor = [UIColor clearColor];
		gauge.innerBorderColor = [UIColor clearColor];

		//float miles = [[totalRun getMiles] floatValue];
		//float kms = [[totalRun getKms] floatValue];
		
		int gaugeValue = 0;
		int gaugeLimit = 0;
		
		
		
		if (goal && [goal.distance floatValue] > 0) {
			if ([units isEqualToString: @"M"]) { // showing in miles
				gaugeValue = [[totalRun getMiles] intValue];
				if ([goal.units isEqualToString: @"K"]) {
					// convert KM into Miles
					gaugeLimit = (int)([goal.distance floatValue] / 1.60934);
				}
				else {
					gaugeLimit = [goal.distance intValue];
				}
				
			}
			else { // showing in KM
				gaugeValue = [[totalRun getKms] intValue];
				if ([goal.units isEqualToString: @"K"]) {
					gaugeLimit = [goal.distance intValue];
				}
				else { // convert goal Miles into KM
					gaugeLimit = (int)([goal.distance floatValue] * 1.60934);
				}
			}
			
			// assign gauge values
			gauge.minLimit = 0;
			gauge.value = gaugeValue;
			gauge.maxLimit = gaugeLimit;
			
		
			gauge.hidden = NO;
			lblGauge.hidden = NO;
			if ([frequency isEqualToString: @"Y"]) {
				gauge.numBars = 12;
			}
			else {
				if ([frequency isEqualToString: @"W"]) {
					gauge.numBars = 7;
				}
				else {
					gauge.numBars = 30;
				}
			}
			
			NSString * unitsStr = @"";
			if ([units isEqualToString: @"M"]) unitsStr = @" miles";
			if ([units isEqualToString: @"K"]) unitsStr = @" km";
			
			float goalDist = [goal.distance floatValue];
			if (![goal.units isEqualToString: units]) {
				if ([units isEqualToString: @"M"]) {
					// goal is in K, display is in M
					goalDist = goalDist * 0.621371;
				}
				else {
					// goal is in M, display is in K
					goalDist = goalDist * 1.60934;
				}
			}
			
			
			float toGo = gauge.maxLimit - gauge.value;
			NSString * labelText = @"";
			if (toGo > 0) {
				labelText = [NSString 
					stringWithFormat: @"%.0f%% of %.0f%@ done. %.0f%@ to do.", 
					100.0 * gauge.value / gauge.maxLimit, 
					goalDist, 
					unitsStr, 
					toGo, 
					unitsStr];
			}
			else {
				labelText = [NSString stringWithFormat: @"%.0f%% of %.0f%@ done.", 
					100.0 * gauge.value / gauge.maxLimit, 
					goalDist, 
					units];
			}
			lblGauge.text = labelText;
		}
		else {
			gauge.hidden = YES;
			lblGauge.hidden = YES;
			[self promptToSetGoal];
		}
	}
	else {
		gauge.hidden = YES;
		lblGauge.hidden = YES;
	}
	return cell;
}

-(void) promptToSetGoal {
	if (![Tracker connected]) return;
	
	if ([self.activityType isEqualToString: @""]) return;
	NSString * timeFrame = [Me getMyTimeframe];
	
	if ([timeFrame isEqualToString: @"W"] || [timeFrame isEqualToString: @"M"] || [timeFrame isEqualToString: @"Y"]) {
		NSString * promptKey = [NSString 
			stringWithFormat : @"dontPromptForGoal_%@_%@", self.activityType, [Me getTimeFrameFrequency]];
		NSString * saidNo = [[NSUserDefaults standardUserDefaults] valueForKey: promptKey];
		if ((!saidNo) || (![saidNo isEqualToString: @"yes"])) {
			NSString * timeFrameName = [Me getTimeFrameFrequency];
			UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: @"Set Goal" 
				message: [NSString stringWithFormat : @"You don't have a %@ goal set for this activity. Would you like to set it now?" , timeFrameName]
				delegate:self 
				cancelButtonTitle: @"No" otherButtonTitles: @"Yes", nil];
			alert.tag = 300;
			[alert show];
		}
	}
}

#pragma mark - Table view delegate

- (IBAction)btnRefreshClick:(id)sender {
	//NSString * period = [Me getTimeframeName];
	[self updateActivityType];
	UIActionSheet * actionSheet = nil;
	NSString * timeFrame = [Me getMyTimeframe];
	if (![self.activityType isEqualToString: @""] && ([timeFrame isEqualToString: @"W"] || [timeFrame isEqualToString: @"M"] || [timeFrame isEqualToString: @"Y"])) {
		NSString * goalText = @"";
		if ([timeFrame isEqualToString: @"W"]) goalText = @"Set Weekly Distance Goal";
		if ([timeFrame isEqualToString: @"M"]) goalText = @"Set Monthly Distance Goal";
		if ([timeFrame isEqualToString: @"Y"]) goalText = @"Set Annual Distance Goal";
		
		if ([Utilities isSocialAvailable]) {
			actionSheet = [[UIActionSheet alloc] 
				initWithTitle: @"Actions" 
				delegate:self 
				cancelButtonTitle: @"Close" 
				destructiveButtonTitle: nil
				otherButtonTitles: 			
					@"Take Screen Shot", 
					@"Tweet",
					@"Facebook",
					@"Copy",
					goalText,
					nil];
		}
		else {
			actionSheet = [[UIActionSheet alloc] 
				initWithTitle: @"Actions" 
				delegate:self 
				cancelButtonTitle: @"Close" 
				destructiveButtonTitle: nil
				otherButtonTitles: 			
					@"Take Screen Shot", 
					@"Tweet",
					@"Copy",
					goalText,
					nil];
		}
	}
	else {
		if ([Utilities isSocialAvailable]) {
			actionSheet = [[UIActionSheet alloc] 
				initWithTitle: @"Actions" 
				delegate:self 
				cancelButtonTitle: @"Close" 
				destructiveButtonTitle: nil
				otherButtonTitles: 			
					@"Take Screen Shot", 
					@"Tweet",
					@"Facebook",
					@"Copy",
					nil];
		}
		else {
			actionSheet = [[UIActionSheet alloc] 
				initWithTitle: @"Actions" 
				delegate:self 
				cancelButtonTitle: @"Close" 
				destructiveButtonTitle: nil
				otherButtonTitles: 			
					@"Take Screen Shot", 
					@"Tweet",
					@"Copy",
					nil];
		}
	}
	
	  
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.alpha = 0.85;
	[actionSheet showFromTabBar: self.tabBarController.tabBar];
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (self.disclosureButton) {
			self.disclosureButton.hidden = YES;
		}
		
		NSIndexPath * path = [NSIndexPath indexPathForRow: 0 inSection: 0];
		UITableViewCell * cell = [self.tableView cellForRowAtIndexPath: path];
		UILabel * madeWithLabel = (UILabel *) [cell viewWithTag: 77];
		if (madeWithLabel) {
			madeWithLabel.hidden = NO;
		}
		
		UIGraphicsBeginImageContext(self.view.frame.size);
		[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
		if (self.disclosureButton) {
			self.disclosureButton.hidden = NO;
		}
		if (madeWithLabel) {
			 madeWithLabel.hidden = YES;
		}
		
		[[[UIAlertView alloc] 
			initWithTitle: @"Done" 
			message: @"Screen Shot was added to your Photo Library." 
			delegate: nil 
			cancelButtonTitle: @"OK" 
			otherButtonTitles: nil] 
		show];
	}
	
	if (buttonIndex == 1) {
		[self tweet];
	}
	
	
	if ([Utilities isSocialAvailable]) {
		if (buttonIndex == 2) {
			[self facebook];
		}
		
		if (buttonIndex == 3) {
			[self copyToPasteBoard];
		}
		
		// button 4 could be a cancel button
		NSString * timeFrame = [Me getMyTimeframe];
		if (![self.activityType isEqualToString: @""] && ([timeFrame isEqualToString: @"W"] || [timeFrame isEqualToString: @"M"] || [timeFrame isEqualToString: @"Y"])) {
			if (buttonIndex == 4) {
				[self setGoal];
			}
		}
	}
	else {
		if (buttonIndex == 2) {
			[self copyToPasteBoard];
		}
		
		// button 4 could be a cancel button
		NSString * timeFrame = [Me getMyTimeframe];
		if (![self.activityType isEqualToString: @""] && ([timeFrame isEqualToString: @"W"] || [timeFrame isEqualToString: @"M"] || [timeFrame isEqualToString: @"Y"])) {
			if (buttonIndex == 3) {
				[self setGoal];
			}
		}
	}
}

-(void) setGoal {
	self.goalSetViewController = nil;
	if (!self.goalSetViewController) {
		self.goalSetViewController = [self.storyboard instantiateViewControllerWithIdentifier: @"goalsetviewcontroller"];
	}
	
	self.goalSetViewController.activityType = self.activityType;
	NSString * timeFrame = [Me getMyTimeframe];
	self.goalSetViewController.goalTimeFrame = timeFrame;
	[self.navigationController pushViewController: self.goalSetViewController animated: YES];
}

-(void) copyToPasteBoard {
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	NSString * pasteString = [tweetText stringByAppendingFormat: @" with %@ via @Stativity", [Tracker getTrackerHashTag]];
    [pb setString: pasteString];
	
	[[[UIAlertView alloc] 
		initWithTitle: @"Done" message: 
		[NSString stringWithFormat: @"\"%@\" has been copied to PasteBoard", pasteString]
		delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
}

-(void) facebook {
	if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		[mySLComposerSheet setInitialText: [self.tweetText stringByAppendingFormat : @" with %@ via @Stativity", [Tracker getTrackerHashTag]]];
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    
		[mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
			NSString *output = @"";
			switch (result) {
				case SLComposeViewControllerResultCancelled:
					//output = @"Action Cancelled";
					break;
				case SLComposeViewControllerResultDone:
					output = @"Post Successfull";
					break;
				default:
					break;
			}
			if (![output isEqualToString: @""]) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			}
		}];
	}
	else {
		[[[UIAlertView alloc]
			initWithTitle: @"Unavailable"
			message: @"Facebook requires iOS6 and must be configured on the device."
			delegate: nil
			cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
	}
}

-(void) tweet {
	if ([TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController * twitter = 
			[[TWTweetComposeViewController alloc] init];
			
			[twitter setInitialText: [self.tweetText stringByAppendingFormat : @" with %@ via @Stativity", [Tracker getTrackerHashTag]]];
	
			twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
				if (res == TWTweetComposeViewControllerResultDone) {
					[[[UIAlertView alloc]
						initWithTitle: @"Tweet Posted" 
						message: @"Your message has been posted." 
						delegate:nil
						cancelButtonTitle: @"OK" 
						otherButtonTitles: nil] show];
				}
				else {
				/*
					[[[UIAlertView alloc]
						initWithTitle: @"Tweet Failed" 
						message: @"Post to Twitter failed." 
						delegate:nil 
						cancelButtonTitle: @"OK" 
						otherButtonTitles: nil] show];*/
				}
				
				[self dismissModalViewControllerAnimated: YES];
			};
							
			[self presentModalViewController: twitter animated: YES];
	}
	else {
		[[[UIAlertView alloc] 
			initWithTitle: @"Twitter not available"
			message:@"Please make sure Twitter is configured on your device."
			delegate: nil cancelButtonTitle: @"OK" 
			otherButtonTitles: nil] show];
	}
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
		if (buttonIndex == 1) {
			self.tableView.editing = NO;
			self.view.userInteractionEnabled = NO;
			NSDate * date = [Me getTimeframeStart];
			[Tracker getFitnessActivitiesAfter : date ofType : @""];
		}
	}
	
	if (alertView.tag == 300) { // set a goal
		if (buttonIndex == 0) { // said no
			NSString * promptKey = [NSString 
				stringWithFormat : @"dontPromptForGoal_%@_%@", self.activityType, [Me getTimeFrameFrequency]];
			
			[[NSUserDefaults standardUserDefaults] setValue: @"yes" forKey: promptKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			NSString * timeFrameName = [Me getTimeFrameFrequency];
			UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: @"Set Goal" 
				message: [NSString stringWithFormat : @"No problem. You can always set %@ goal by using the Action button and then Set %@ Distance Goal option from the menu.", timeFrameName, timeFrameName]
				delegate: nil 
				cancelButtonTitle: @"OK" otherButtonTitles: nil];
				[alert show];
		}
		if (buttonIndex == 1) {
			NSString * timeFrame = [Me getMyTimeframe];
			if (![self.activityType isEqualToString: @""] && ([timeFrame isEqualToString: @"W"] || [timeFrame isEqualToString: @"M"] || [timeFrame isEqualToString: @"Y"])) {
				[self setGoal];
			}
			
		}
	}
}

- (IBAction)btnDetailClicked:(id)sender {
	[self performSegueWithIdentifier: @"displayActivityDetail" sender: self];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	IIViewDeckController * deckController = appDelegate.deckController;
	if (deckController.leftControllerIsOpen) {
		[deckController toggleLeftView];
	}	
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	IIViewDeckController * deckController = appDelegate.deckController;
	if (deckController.leftControllerIsOpen) {
		[deckController toggleLeftView];
	}
	if ([segue.identifier isEqualToString: @"displayActivityDetail"]) {
		MyActivitiesDetailViewController * detail = (MyActivitiesDetailViewController *) segue.destinationViewController;
		detail.activityType = self.activityType;
	}
}


/* prevent table from scrolling up */
float a;

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	a = scrollView.contentOffset.y;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y > a) {
		[scrollView setScrollEnabled:  NO];
		[scrollView setContentOffset: CGPointMake(0, a)];
	}
	[scrollView setScrollEnabled: YES];
}
/* end prevent table from scrolling up*/




















@end
