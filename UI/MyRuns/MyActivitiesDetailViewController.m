//
//  MyActivitiesDetailViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/6/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "MyActivitiesDetailViewController.h"
#import "Me.h"
#import "StativityData.h"
#import "Activity.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityDetailViewController.h"
#import "HeaderView.h"
#import "IIViewDeckController.h"
#import "ActivityWeek.h"
#import "ActivityMonth.h"
#import "Tracker.h"
#import "DistanceGoal.h"
#import "SetGoalViewController.h"
#import "ActivitiesGraphViewController.h"
#import "GraphPoint.h"

@interface MyActivitiesDetailViewController ()
	
@property (nonatomic, retain) ActivityFormatter * curTotal;
@property (nonatomic, retain) ActivityFormatter * prevTotal;
@property (nonatomic, retain) ActivityDetailViewController * detail;
@property (nonatomic, retain) SetGoalViewController * goalViewController;
@property (nonatomic, strong) ActivitiesGraphViewController * graphController;

@end

@implementation MyActivitiesDetailViewController

@synthesize detail;
@synthesize activities;
@synthesize prevActivities;
@synthesize activityType;
@synthesize fontFamily;
@synthesize viewType;
@synthesize curTotal;
@synthesize prevTotal;
@synthesize weeks;
@synthesize months;
@synthesize goalViewController;
@synthesize graphController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupUI];
	[self activityChanged];	
	self.fontFamily = [Utilities fontFamily];
}

-(void) loadNewActivities {
	self.view.userInteractionEnabled = NO;
	
	[Tracker getFitnessActivities: @""];
	
	NSDate * lastRefresh = [Utilities currentLocalTime];
	[[NSUserDefaults standardUserDefaults] setValue: lastRefresh forKey: @"lastRefresh"];
}

- (IBAction)actionButtonClick:(id)sender {
	//NSString * period = [Me getTimeframeName];
	
	NSString * goalText = @"";
	if (![self.activityType isEqualToString: @""] 
		&& ((viewType.selectedSegmentIndex == 1) || (viewType.selectedSegmentIndex == 2))) {
		if (viewType.selectedSegmentIndex == 1) goalText = @"Set Weekly Distance Goal";
		if (viewType.selectedSegmentIndex == 2) goalText = @"Set Monthly Distance Goal";
	}
	UIActionSheet * actionSheet;
	
	if (![goalText isEqualToString: @""]) {
		actionSheet = [[UIActionSheet alloc] 
			initWithTitle: @"Actions" 
			delegate:self 
			cancelButtonTitle: @"Close" 
			destructiveButtonTitle: nil 
			otherButtonTitles: 
				@"Load New Activities",
				goalText,
				//@"View Graphs",
				nil];
		actionSheet.tag = 1; // with goal
	}
	else {
		actionSheet = [[UIActionSheet alloc] 
			initWithTitle: @"Actions" 
			delegate:self 
			cancelButtonTitle: @"Close" 
			destructiveButtonTitle: nil 
			otherButtonTitles: 
				@"Load New Activities",
				//@"View Graphs",
				nil];
		actionSheet.tag = 2; // without goal
	}
			
			
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.alpha = 0.85;
	[actionSheet showFromTabBar: self.tabBarController.tabBar];
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self loadNewActivities];
	}
	/*
	
	if (buttonIndex == 1) {
		NSString * period = [Me getTimeframeName];
		NSString * message = [@"Are you sure to reload the data since beginning of " stringByAppendingFormat: @"%@ ?", period];
		UIAlertView * alertView = [[UIAlertView alloc]
			initWithTitle: @"Please Confirm" 
			message: message 
			delegate:self 
			cancelButtonTitle: @"No" otherButtonTitles: @"Yes", nil];
		alertView.tag = 1;
		[alertView show];
	}
	*/
	
	if (actionSheet.tag == 1) { // with goal
		if (buttonIndex == 1) { // set goal
			if (![self.activityType isEqualToString: @""] 
				&& ((viewType.selectedSegmentIndex == 1) || (viewType.selectedSegmentIndex == 2))) {
				[self setGoal];
			}
		}
		/*
		if (buttonIndex == 2) {
			[self viewGraph];
		}*/
	}
	
	/*
	if (actionSheet.tag == 2) { // without goal
		if (buttonIndex == 1) {
			[self viewGraph];
		}
	}*/
}

-(void) setGoal {
	self.goalViewController = nil;
	if (!self.goalViewController) {
		self.goalViewController = [self.storyboard instantiateViewControllerWithIdentifier: @"goalsetviewcontroller"];
	}
	
	self.goalViewController.activityType = self.activityType;
	if (viewType.selectedSegmentIndex == 1) self.goalViewController.goalTimeFrame = @"W";
	if (viewType.selectedSegmentIndex == 2) self.goalViewController.goalTimeFrame = @"M";
	[self.navigationController pushViewController: self.goalViewController animated: YES];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger) supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(NSArray *) getGraphData {
	NSArray * retval;
	switch(viewType.selectedSegmentIndex) {
		case 0 : {
			retval = [self getDailyGraphData];
			break;
		}
		case 1 : {
			retval = [self getWeeklyGraphData];
			break;
		}
		case 2 : {
			retval = [self getMonthlyGraphData];
			break;
		}
	}
	return retval;
}

-(NSNumber *) getActivityDistanceBetween : (NSDate *) startDate and : (NSDate *) endDate {
	float dist = 0;
	
	for(int i = 0; i < [self.activities count]; i++) {
		Activity * act = [self.activities objectAtIndex: i];
		if ([Utilities isDateInRange: act.start_time : startDate : endDate]) {
			dist += [[act getDistanceInUnits] floatValue];
		}
	}
	
	return [NSNumber numberWithFloat: dist];
}

-(NSArray *) getDailyGraphData {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	
	NSDate * from = [Utilities startOfDateFromDateTime : [Me getTimeframeStart]];
	NSDate * to = [Utilities endOfDateFromDateTime: [Me getTimeframeEnd]];
	
	NSDate * cur = from;
	NSDate * prev = from;
	while([cur compare: to] == NSOrderedAscending) {
		if (cur != prev) {
			GraphPoint * gp = [[GraphPoint alloc] init];
			[gp.data setValue: prev forKey: @"from" ];
			[gp.data setValue: cur  forKey: @"to"];
			float dist = [[self getActivityDistanceBetween: prev and: cur] floatValue];
			[gp.data setValue: [NSNumber numberWithFloat: dist] forKey: @"distance"];
			[gp.data setValue: [NSNumber numberWithFloat: dist] forKey : @"YValue"];
			[gp.data setValue: cur forKey: @"XValue"];
			[retval addObject: gp];
			
			//NSLog(@"from %@ to %@ = %@", prev, cur, [gp.data objectForKey: @"distance"]);
		}
		
		prev = [cur copy];
		cur =  [cur dateByAddingTimeInterval: 60 * 60 * 24]; // next day
	}
	return [retval copy];
}

-(NSArray *) getWeeklyGraphData {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	
	return [retval copy];
}

-(NSArray *) getMonthlyGraphData {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	
	return [retval copy];
}

-(void) viewGraph {
	if (self.graphController) {
		self.graphController = nil;
	}
	self.graphController = [self.storyboard
		instantiateViewControllerWithIdentifier: @"activitiesGraphController"];
	self.graphController.graphData = [self getGraphData];
	[self presentModalViewController: self.graphController animated: YES];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
		if (buttonIndex == 1) {
			self.tableView.editing = NO;
			self.view.userInteractionEnabled = NO;
			NSDate * date = [Me getTimeframeStart];
			[Tracker getFitnessActivitiesAfter: date ofType: @""];
		}
	}
	
	// delete activity which is not last
	if (alertView.tag = 333) {
		if (buttonIndex == 1) {	
			int section = [alertView.accessibilityLabel intValue];
			int rowIndex = [alertView.accessibilityValue intValue];
			[self deleteActivityAtSection: section andRow: rowIndex];
		}
	}
}

-(void) failedLoadingData {
	self.view.userInteractionEnabled = YES;
}

-(void) activityChanged {
	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(detailLoaded) 
        name:@"detailLoaded"
        object:nil];
	
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector : @selector(failedLoadingData)
		name : @"failedLoadingData"
		object: nil];	
		
	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(runsLoadedNotification:) 
        name:@"runsLoaded"
        object:nil];
		
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector : @selector(timeframeChanged)
		name : @"TimeframeChanged"
		object : nil];
	
	NSString * title = @"My Activities";
	if ([self.activityType isEqualToString: @"Running"])  title = @"My Running";
	if ([self.activityType isEqualToString: @"Walking"]) title = @"My Walking";
	if ([self.activityType isEqualToString: @"Cycling"]) title = @"My Biking";
	self.navigationItem.title =title;
	self.navigationItem.backBarButtonItem.title = @"Back";
		
	[self detailLoaded];
}

-(void) timeframeChanged {
	[self detailLoaded];
}

-(void) detailLoaded {
	[self loadRuns];
	[self updateArrays];
	[self.tableView reloadData];
}

-(void) setupUI {
	UIColor * uiColor = [Me getUIColor];
	//[self.navigationController.navigationBar setTintColor: uiColor];
	//[self.tabBarController.tabBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor], UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor,
			[UIFont fontWithName: [Utilities fontFamily] size: 14], UITextAttributeFont,
			 nil];
	[[UINavigationBar appearance] setTitleTextAttributes: attributes];*/
	[[UINavigationBar appearance] setTintColor: uiColor];
	//[self.navigationController.navigationBar setTitleTextAttributes: attributes];	
}

-(void) runsLoadedNotification : (NSNotification *) notification {
	[self runsLoaded];
}

-(void) runsLoaded {
	[self loadRuns];
	[self setupUI];
	[self.tableView reloadData];
	[self updateArrays];
	[self.tableView setEditing: NO];
	self.view.userInteractionEnabled = YES;
}

- (IBAction)viewTypeChanged:(id)sender {
	[self.tableView reloadData];
	[self.tableView setEditing: NO];
	self.view.userInteractionEnabled = YES;
	[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(void) loadRuns {
	StativityData * appData = [StativityData get];
	
	NSDate * startDate = [Me getTimeframeStart];
	NSDate * endDate = [Me getTimeframeEnd];
	self.activities = [appData 
		fetchActivitiesBetweenStartDate: startDate andEndDate: endDate ofType : self.activityType];
	
	float totalDistance = 0;
	float totalDuration = 0;
	float totalCalories = 0;
	for (int i = 0; i < [self.activities count]; i++) {
		Activity * act = [self.activities objectAtIndex: i];
		totalDistance += [act.total_distance floatValue];
		totalDuration += [act.duration floatValue];
		totalCalories += [act.total_calories floatValue];
	}
	self.curTotal = [[ActivityFormatter alloc] init];
	curTotal.distance = [NSNumber numberWithFloat: totalDistance];
	curTotal.duration = [NSNumber numberWithFloat: totalDuration];
	curTotal.calories = [NSNumber numberWithFloat: totalCalories];
	
	NSDate * prevStart = [Me getPrevTimeframeStart];
	NSDate * prevEnd = [Me getPrevTimeframeEnd];
	self.prevActivities = [appData 
		fetchActivitiesBetweenStartDate: prevStart andEndDate: prevEnd ofType : self.activityType];
	
	totalDistance = 0;
	totalDuration = 0;
	totalCalories = 0;
	for (int i = 0; i < [self.prevActivities count]; i++) {
		Activity * act = [self.prevActivities objectAtIndex: i];
		totalDistance += [act.total_distance floatValue];
		totalDuration += [act.duration floatValue];
		totalCalories += [act.total_calories floatValue];
	}
	self.prevTotal = [[ActivityFormatter alloc] init];
	prevTotal.distance = [NSNumber numberWithFloat: totalDistance];
	prevTotal.duration = [NSNumber numberWithFloat: totalDuration];
	prevTotal.calories = [NSNumber numberWithFloat: totalCalories];
	
	[self loadWeeks];
	[self loadMonths];
	
	[self.tableView setEditing: NO];
}

-(void) loadMonths {
	self.months = nil;
	self.months = [[NSMutableArray alloc] init];
	
	NSArray * _months = [ActivityMonth getMonthlyStatsForActivityType: self.activityType];
	NSString * monthStr = @"";
	NSString * lastMonthStr = @"";
	NSMutableArray * data = [[NSMutableArray alloc] init];
	float totalDistance = 0;
	float totalTime = 0;
	float totalCalories = 0;
	for(int i = 0; i < [_months count]; i++) {
		ActivityMonth * month = [_months objectAtIndex: i];
		monthStr = [month yearMonthStartName];
		if (([lastMonthStr isEqualToString: monthStr] || [lastMonthStr isEqualToString: @""]) && ([month.order intValue] > 1)) {
			[data addObject: month];
			totalDistance += [month.totalDistance floatValue];
			totalTime += [month.totalTime floatValue];
			totalCalories += [month.totalCalories floatValue];
		}
		else { // add to self.weeks
			// check for first week before terminating
			if ([month.order intValue] == 1) {
				[data addObject: month];
				totalDistance += [month.totalDistance floatValue];
				totalTime += [month.totalTime floatValue];
				totalCalories += [month.totalCalories floatValue];
			}
		
			NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
			[dict setObject: lastMonthStr forKey: @"monthStr"];
			[dict setObject: data forKey: @"monthData"];
			
			if([data count] > 0) {
				ActivityMonth * firstMonth = [data lastObject];
				ActivityMonth * lastMonth = [data objectAtIndex: 0];
			    [dict setObject: firstMonth forKey: @"monthFirst"];
			    [dict setObject: lastMonth forKey: @"monthLast"];
			}
			else {
			   //[dict setObject: nil forKey: @"weekLast"];
			   //[dict setObject: nil forKey: @"weekFirst"];
			}
			
			ActivityFormatter * fmt = [[ActivityFormatter alloc] init];
			fmt.distance = [NSNumber numberWithFloat : totalDistance];
			fmt.duration = [NSNumber numberWithFloat : totalTime];
			fmt.calories = [NSNumber numberWithFloat : totalCalories];
			
			[dict setObject: fmt forKey: @"monthSummary"];
			
			[self.months addObject: dict];
			
			totalDistance = 0;
			totalTime = 0;
			totalCalories = 0;
			
			// create new array and put this week in there 
			data = nil;
			data = [[NSMutableArray alloc] init];
			
			[data addObject: month];
			totalDistance = [month.totalDistance floatValue];
			totalTime = [month.totalTime floatValue];
			totalCalories = [month.totalCalories floatValue];
		}
		lastMonthStr = monthStr;
	}
}

-(void) loadWeeks {
	self.weeks = nil;
	self.weeks = [[NSMutableArray alloc] init];
	
	NSArray * _weeks = [ActivityWeek getWeeklyStatsForActivityType: self.activityType];
	NSString * weekStr = @"";
	NSString * lastWeekStr = @"";
	NSMutableArray * data = [[NSMutableArray alloc] init];
	float totalDistance = 0;
	float totalTime = 0;
	float totalCalories = 0;
	for(int i = 0; i < [_weeks count]; i++) {
		ActivityWeek * week = [_weeks objectAtIndex: i];
		/*if ([week.order intValue] == 1) {
			NSLog(@"break");
		}*/
		weekStr = [week yearMonthStartName];
		if (([lastWeekStr isEqualToString: weekStr] || [lastWeekStr isEqualToString: @""]) && ([week.order intValue] > 1)) {
			[data addObject: week];
			totalDistance += [week.totalDistance floatValue];
			totalTime += [week.totalTime floatValue];
			totalCalories += [week.totalCalories floatValue];
		}
		else { // add to self.weeks
			// check for first week before terminating
			if ([week.order intValue] == 1) {
				[data addObject: week];
				totalDistance += [week.totalDistance floatValue];
				totalTime += [week.totalTime floatValue];
				totalCalories += [week.totalCalories floatValue];
			}
		
			NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
			[dict setObject: lastWeekStr forKey: @"weekStr"];
			[dict setObject: data forKey: @"weekData"];
			
			if([data count] > 0) {
				ActivityWeek * firstWeek = [data lastObject];
				ActivityWeek * lastWeek = [data objectAtIndex: 0];
			    [dict setObject: firstWeek forKey: @"weekFirst"];
			    [dict setObject: lastWeek forKey: @"weekLast"];
			}
			else {
			   //[dict setObject: nil forKey: @"weekLast"];
			   //[dict setObject: nil forKey: @"weekFirst"];
			}
			
			ActivityFormatter * fmt = [[ActivityFormatter alloc] init];
			fmt.distance = [NSNumber numberWithFloat : totalDistance];
			fmt.duration = [NSNumber numberWithFloat : totalTime];
			fmt.calories = [NSNumber numberWithFloat : totalCalories];
			
			[dict setObject: fmt forKey: @"weekSummary"];
			
			[self.weeks addObject: dict];
			
			totalDistance = 0;
			totalTime = 0;
			totalCalories = 0;
			
			// create new array and put this week in there 
			data = nil;
			data = [[NSMutableArray alloc] init];
			
			[data addObject: week];
			totalDistance = [week.totalDistance floatValue];
			totalTime = [week.totalTime floatValue];
			totalCalories = [week.totalCalories floatValue];
		}
		lastWeekStr = weekStr;
	}
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


- (void)viewDidUnload
{
	
	[self setViewType:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int retval = 0;
	switch(viewType.selectedSegmentIndex) {
		case 0 : { // daily
				NSString * timeFrame =  [Me getTimeframeName];
				if ([timeFrame isEqualToString: @"ALL-TIME"]) {
					retval = 1;
				}
				else {
					retval = 2;
				}
				break;
		}
		
		case 1: { // weekly 
			retval = [self.weeks count];
			break;
		}
		
		case 2: { // monthly 
			retval = [self.months count];
			break;
		}
	}
	return retval;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int retval = 0;
	switch(viewType.selectedSegmentIndex) {
	
		case 0 : {  // daily
			if (section == 0) {
				if ([self.activities count] == 0) {
					retval = 1;
				}
				else {
					retval = [self.activities count];
				}
			}
			else {
				if ([self.prevActivities count] == 0) {
					retval =  1;
				}
				else {
					retval = [self.prevActivities count];
				}
			}
			break;
		}
		
		case 1 : {
			NSMutableDictionary * week = [self.weeks objectAtIndex: section];
			NSArray * data = (NSArray *) [week objectForKey: @"weekData"];
			retval = [data count];
			break;
		}
		
		case 2: {
			NSMutableDictionary * month = [self.months objectAtIndex: section];
			NSArray * data = (NSArray *) [month objectForKey: @"monthData"];
			retval = [data count];
			break;
		}
	}
	return retval;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	NSString * retval = @"";
	switch(viewType.selectedSegmentIndex) {
		case 0 : {
			if (section == 0) {
				retval = [Me getTimeframeName];
			}
			else {
				retval = [Me getPrevTimeframeName];
			}
			break;
		}
		
		case 1: {
			NSMutableDictionary * week = [self.weeks objectAtIndex: section];
			retval = [week objectForKey: @"weekStr"];
			break;
		}
		
		case 2: {
			NSMutableDictionary * month = [self.months objectAtIndex: section];
			retval = [month objectForKey: @"monthStr"];
			break;
		}
	}
	return retval;
	
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString * text = @"";
	NSString * rightText = @"";
	
	switch(viewType.selectedSegmentIndex) {
		case 0 : {
			if (section == 0) {
				text = [Me getTimeframeName];
				
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];  
				[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
				[formatter setMaximumFractionDigits:0];
				NSString * calText = [formatter stringFromNumber: [NSNumber numberWithDouble : round([curTotal.calories floatValue])]];
				rightText = [curTotal getDistanceFormatted];
				rightText = [NSString stringWithFormat: @"%@   %@ cal", rightText, calText];
			}
			else {
				text = [Me getPrevTimeframeName];
				rightText = [prevTotal getDistanceFormatted];
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];  
				[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
				[formatter setMaximumFractionDigits:0];
				//NSString * calText = [formatter stringFromNumber: prevTotal.calories];
				NSString * calText = [formatter stringFromNumber: [NSNumber numberWithDouble : round([prevTotal.calories floatValue])]];
				rightText = [NSString stringWithFormat: @"%@   %@ cal", rightText, calText];
			}
			break;
		}
		
		case 1: {
			NSMutableDictionary * week = [self.weeks objectAtIndex: section];
			text = [week objectForKey: @"weekStr"];
			
			ActivityWeek * first = [week objectForKey: @"weekFirst"];
			ActivityWeek * last = [week objectForKey: @"weekLast"];
			
			if (first && last) {
				NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
				[fmt setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				[fmt setDateFormat: @"MMM d"];
				text = [NSString stringWithFormat: @"%@ - %@", 
					[fmt stringFromDate: first.weekStart], 
					[fmt stringFromDate: last.weekEnd]];
			}
			
			ActivityFormatter * fmt = [week objectForKey: @"weekSummary"];
			NSString * dist = [fmt getDistanceFormatted];
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];  
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
			[formatter setMaximumFractionDigits:0];
			//NSString * calText = [formatter stringFromNumber: fmt.calories];
			NSString * calText = [formatter stringFromNumber: [NSNumber numberWithDouble : round([fmt.calories floatValue])]];
			rightText = [NSString stringWithFormat: @"%@   %@ cal", dist, calText];
			
			break;
		}
		
		case 2: {
			NSMutableDictionary * month = [self.months objectAtIndex: section];
			text = [month objectForKey: @"monthStr"];
			
			ActivityFormatter * fmt = [month objectForKey: @"monthSummary"];
			NSString * dist = [fmt getDistanceFormatted];
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];  
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
			[formatter setMaximumFractionDigits:0];
			//NSString * calText = [formatter stringFromNumber: fmt.calories];
			NSString * calText = [formatter stringFromNumber: [NSNumber numberWithDouble : round([fmt.calories floatValue])]];
			rightText = [NSString stringWithFormat: @"%@   %@ cal", dist, calText];
			
			break;
		}
	}
	
		
	return [[HeaderView alloc] 
		initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 26)
		andText : text
		andRightText: [rightText uppercaseString]
	];

}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	//return 22;
	return 26;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int retval = 0;
	switch(viewType.selectedSegmentIndex) {
		case 0 : {
			retval = 98;
			break;
		}
		case 1: {
			retval = 98;
			break;
		}
		case 2: {
			retval = 98;
			break;
		}
	}
	return retval;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = nil;
	switch(viewType.selectedSegmentIndex) {
		case 0 : {
			cell = [self getRunCell: tableView atIndexPath:indexPath];
			break;
		}
		case 1: {
			cell = [self getWeekCell: tableView atIndexPath:indexPath];
			break;
		}
		case 2: {
			 cell = [self getMonthCell : tableView atIndexPath : indexPath];
			 break;
		}
		
	}

    return cell;
}

-(UITableViewCell *) getMonthCell : (UITableView *) tableView atIndexPath  :(NSIndexPath *) indexPath {

	static NSString *CellIdentifier = @"weekCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
	}
	
	NSMutableDictionary * dict = [self.months objectAtIndex: indexPath.section];
	NSMutableArray * data = [dict objectForKey: @"monthData"];
	
	ActivityMonth * month = [data objectAtIndex: indexPath.row];
	
	UILabel * when = (UILabel *) [cell viewWithTag: 1];
	UILabel * distance = (UILabel *) [cell viewWithTag: 2];
	UILabel * time = (UILabel *) [cell viewWithTag: 3];
	UILabel * calories = (UILabel *) [cell viewWithTag: 4];
	UILabel * units = (UILabel *) [cell viewWithTag: 5];
	UILabel * times = (UILabel *) [cell viewWithTag: 6];
	UILabel * rank = (UILabel *) [cell viewWithTag: 7];
	UILabel * order = (UILabel *) [cell viewWithTag: 8];
	
	UIColor * color = [Me getUIColor];
	distance.textColor = color;
	units.textColor = color;
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	when.text = [month getWhenFormatted];
	distance.text = [NSString stringWithFormat: @"%.1f", [[month getDistanceInUnits] floatValue]];
	time.text = [month getDurationFormatted];
	NSNumberFormatter * fmt = [[NSNumberFormatter alloc] init];
	fmt.numberStyle = NSNumberFormatterDecimalStyle;
	[fmt setMaximumFractionDigits:0];
	calories.text = [NSString stringWithFormat: @"%@ calories", [fmt stringFromNumber:  month.totalCalories]]; // [run.total_calories intValue]]; 

	NSString * myUnits = [Me getMyUnits];
	if ([myUnits isEqualToString: @"M"]) {
		units.text = @"mi";
	}
	else {
		units.text = @"km";
	}
	
	UIImageView * imageView = (UIImageView *) [cell viewWithTag: 9];
	imageView.image = nil;	
	if ([self.activityType isEqualToString: @""]) {
		NSString * imageName = [Tracker getTrackerIconName];
		if (![imageName isEqualToString: @""]) {
			imageView.hidden = NO;
			[imageView setImage : [UIImage imageNamed: imageName]];
		}
		else {
			imageView.hidden = YES;
		}
	}
	else {
		imageView.hidden = NO;
		if ([self.activityType isEqualToString: @"Running"]) {
			//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"ran"];
			[imageView setImage: [UIImage imageNamed: @"63-runner.png"]];
		}
		if ([self.activityType isEqualToString: @"Cycling"]) {
			//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"biked"];
			[imageView setImage: [UIImage imageNamed: @"13-bicycle.png"]];
		}
		if ([self.activityType isEqualToString: @"Walking"]) {
			//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"walked"];
			imageView.image = [UIImage imageNamed: @"102-walk.png"];
		}
	}
	
	times.text = [NSString stringWithFormat: @"%d times", [month.numberOfActivities intValue]];
	
	int rnk = [month.rank intValue];
	rank.text = [NSString stringWithFormat: @"%@ Farthest", [Utilities ordinalNumberFormat: rnk]];
	
	order.text = [NSString stringWithFormat: @"#%d", [month.order intValue]];
	
	UILabel * lblGauge = (UILabel *) [cell viewWithTag: 10];
	if ([self.activityType isEqualToString: @""]) {
		lblGauge.hidden = YES;
		rank.frame = CGRectMake( 155, 26, 46, 43);
	}
	else {
		NSString * units = [Me getMyUnits];
		StativityData * sd = [StativityData get];
		NSDate * date = month.monthEnd;
		DistanceGoal * goal = [sd findDistanceGoalForActivity: self.activityType 
			andFrequency: @"M" noLaterThan: date];
		if (goal && [goal.distance floatValue]> 0) {
		
			float miles = [[month getMiles] floatValue];
			int value = 0;
			int maxLimit = 0;
			if ([units isEqualToString: goal.units]) {
				maxLimit = [goal.distance intValue];
				if ([goal.units isEqualToString: @"K"]) {
					value = (int) miles * 1.60934;
				}
				else {
					value = (int)miles;
				}
			}
			else { // units are not the same
				if ([units isEqualToString: @"M"] && [goal.units isEqualToString: @"K"]) {
					// current units are M and goal units are K, display in miles
					maxLimit = (int) [goal.distance floatValue] * 0.621371;
					if ((int)miles > maxLimit) {
						value = maxLimit;
					}
					else {
						value = (int)miles;
					}
					
				}
				
				if ([units isEqualToString: @"K"] && [goal.units isEqualToString: @"M"]) {
					// current units are K and goal units are M
					maxLimit = (int) [goal.distance floatValue] * 1.60934;
					if ((int) miles * 1.60934 > maxLimit
					) {
						value = maxLimit;
					}
					else {
						value = (int) miles * 1.60934;
					}
				}
			}
		
			
			lblGauge.hidden = NO;
			rank.frame = CGRectMake( 155, 5, 46, 43);

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
			
			
			float toGo = maxLimit - value;
			NSString * labelText = @"";
			float pct = 100.0 * value / maxLimit;
			if (toGo > 0) {
				
				labelText = [NSString 
					stringWithFormat: @"%.0f%%      of Goal", pct];
			}
			else {
				
				labelText = [NSString stringWithFormat: @"%.0f%%      of Goal", pct];
			}
			
			if (pct >= 100.0) {
				lblGauge.textColor = [UIColor colorWithRed: 64/255. green: 128/255. blue: 0 alpha:1];
			}
			else {
				lblGauge.textColor = [Me getUIColor];
			}
			lblGauge.text = labelText;
		
		}
		else {
			lblGauge.hidden = YES;
			rank.frame = CGRectMake( 155, 26, 46, 43);
		}
	}
	
	
	return cell;
}



-(UITableViewCell *) getWeekCell : (UITableView *) tableView atIndexPath  :(NSIndexPath *) indexPath {

	static NSString *CellIdentifier = @"weekCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
	}
	
	NSMutableDictionary * dict = [self.weeks objectAtIndex: indexPath.section];
	NSMutableArray * data = [dict objectForKey: @"weekData"];
	ActivityWeek * week = [data objectAtIndex: indexPath.row];
	
	UILabel * when = (UILabel *) [cell viewWithTag: 1];
	UILabel * distance = (UILabel *) [cell viewWithTag: 2];
	UILabel * time = (UILabel *) [cell viewWithTag: 3];
	UILabel * calories = (UILabel *) [cell viewWithTag: 4];
	UILabel * units = (UILabel *) [cell viewWithTag: 5];
	UILabel * times = (UILabel *) [cell viewWithTag: 6];
	UILabel * rank = (UILabel *) [cell viewWithTag: 7];
	UILabel * order = (UILabel *) [cell viewWithTag: 8];
	
	UIColor * color = [Me getUIColor];
	distance.textColor = color;
	units.textColor = color;
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	when.text = [week getWhenFormatted];
	distance.text = [NSString stringWithFormat: @"%.1f", [[week getDistanceInUnits] floatValue]];
	time.text = [week getDurationFormatted];
	NSNumberFormatter * fmt = [[NSNumberFormatter alloc] init];
	fmt.numberStyle = NSNumberFormatterDecimalStyle;
	[fmt setMaximumFractionDigits:0];
	calories.text = [NSString stringWithFormat: @"%@ calories", [fmt stringFromNumber: week.totalCalories]]; // [run.total_calories intValue]]; 
	NSString * myUnits = [Me getMyUnits];
	if ([myUnits isEqualToString: @"M"]) {
		units.text = @"mi";
	}
	else {
		units.text = @"km";
	}
	
	UIImageView * imageView = (UIImageView *) [cell viewWithTag: 9];
	imageView.image = nil;

	if ([self.activityType isEqualToString: @""]) {
		NSString * imageName = [Tracker getTrackerIconName];
		if (![imageName isEqualToString: @""]) {
			imageView.hidden = NO;
			[imageView setImage : [UIImage imageNamed: imageName]];
		}
		else {
			imageView.hidden = YES;
		}
	}
	else {
		imageView.hidden = NO;
		if ([self.activityType isEqualToString: @"Running"]) {
			//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"ran"];
			[imageView setImage: [UIImage imageNamed: @"63-runner.png"]];
		}
		if ([self.activityType isEqualToString: @"Cycling"]) {
			//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"biked"];
			[imageView setImage: [UIImage imageNamed: @"13-bicycle.png"]];
		}
		if ([self.activityType isEqualToString: @"Walking"]) {
			//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"walked"];
			imageView.image = [UIImage imageNamed: @"102-walk.png"];
		}
	}
	
	
	times.text = [NSString stringWithFormat: @"%d times", [week.numberOfActivities intValue]];
	
	int rnk = [week.rank intValue];
	rank.text = [NSString stringWithFormat: @"%@ Farthest", [Utilities ordinalNumberFormat: rnk]];

	
	order.text = [NSString stringWithFormat: @"#%d", [week.order intValue]];
	
	
	UILabel * lblGauge = (UILabel *) [cell viewWithTag: 10];
	if ([self.activityType isEqualToString: @""]) {
		lblGauge.hidden = YES;
		rank.frame = CGRectMake( 155, 26, 46, 43);
	}
	else {
		NSString * units = [Me getMyUnits];
		StativityData * sd = [StativityData get];
		NSDate * date = week.weekEnd;
		DistanceGoal * goal = [sd findDistanceGoalForActivity: self.activityType 
			andFrequency: @"W" noLaterThan: date];
		if (goal && ([goal.distance floatValue] > 0)) {
			rank.frame = CGRectMake( 155, 5, 46, 43);
		
			float miles = [[week getMiles] floatValue];
			int value = 0;
			int maxLimit = 0;
			if ([units isEqualToString: goal.units]) {
				maxLimit = [goal.distance intValue];
				if ([goal.units isEqualToString: @"K"]) {
					value = (int) miles * 1.60934;
				}
				else {
					value = (int)miles;
				}
			}
			else { // units are not the same
				if ([units isEqualToString: @"M"] && [goal.units isEqualToString: @"K"]) {
					// current units are M and goal units are K, display in miles
					maxLimit = (int) [goal.distance floatValue] * 0.621371;
					if ((int)miles > maxLimit) {
						value = maxLimit;
					}
					else {
						value = (int)miles;
					}
					
				}
				
				if ([units isEqualToString: @"K"] && [goal.units isEqualToString: @"M"]) {
					// current units are K and goal units are M
					maxLimit = (int) [goal.distance floatValue] * 1.60934;
					if ((int) miles * 1.60934 > maxLimit
					) {
						value = maxLimit;
					}
					else {
						value = (int) miles * 1.60934;
					}
				}
			}
		
			
			lblGauge.hidden = NO;
			rank.frame = CGRectMake( 155, 5, 46, 43);
			
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
			
			
			float toGo = maxLimit - value;
			NSString * labelText = @"";
			float pct = 100.0 * value / maxLimit;
			if (toGo > 0) {
				
				labelText = [NSString 
					stringWithFormat: @"%.0f%%      of Goal", pct];
			}
			else {
				
				labelText = [NSString stringWithFormat: @"%.0f%%      of Goal", pct];
			}
			
			if (pct >= 100.0) {
				lblGauge.textColor = lblGauge.textColor = [UIColor colorWithRed: 64/255. green: 128/255. blue: 0 alpha:1];
			}
			else {
				lblGauge.textColor = [Me getUIColor];
			}
			lblGauge.text = labelText;
		
		}
		else {
			lblGauge.hidden = YES;
			rank.frame = CGRectMake( 155, 26, 46, 43);
		}
	}
	
	return cell;
}

-(UITableViewCell *) getRunCell : (UITableView *) tableView atIndexPath  :(NSIndexPath *) indexPath {
    Activity * run = nil;
	if (indexPath.section == 0) {
		if ([activities count] > 0) {
			run = [activities objectAtIndex: indexPath.row];
		}
	}
	else {
		if ([prevActivities count] > 0) {
			run = [prevActivities objectAtIndex: indexPath.row];
		}
	}
	
	static NSString *CellIdentifier = @"dailycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"runcell"];
	}
	
	if (!run) {
		NSString * text = @"";
		NSString * timeFrame = @"";
		NSString * aType = @"activities";
				
		if ([self.activityType isEqualToString: @"Running"]) {
			aType = @"running";
		}
		if ([self.activityType isEqualToString: @"Cycling"]) {
			aType = @"biking";
		}
		if ([self.activityType isEqualToString: @"Walking"]) {
			aType = @"walking";
		}
		if (indexPath.section ==0 ) {
			timeFrame = [[Me getTimeframeName] lowercaseString];
		}
		
		if (indexPath.section == 1 ) {
			timeFrame = [[Me getPrevTimeframeName] lowercaseString];
		}
		if ([timeFrame isEqualToString: @"all-time"]) {
			timeFrame = @"yet";
		}
		text = [@"You didn't log any " stringByAppendingFormat: @"%@ %@.", aType, timeFrame];
		
		cell.textLabel.font = [UIFont fontWithName: self.fontFamily size:15];
		cell.textLabel.textColor = [UIColor colorWithRed: 255/255. green:0 blue:0 alpha:0.75];

		cell.textLabel.text = text;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel * labelCommonDistance = (UILabel *) [cell viewWithTag: 7];
		if (labelCommonDistance) {
			labelCommonDistance.text = @"";
			labelCommonDistance.backgroundColor = [UIColor whiteColor];
			labelCommonDistance.layer.cornerRadius = 0;
		}
	}
	else {
		cell.textLabel.text = @"";
		UILabel * labelWhen = (UILabel *) [cell viewWithTag: 1];
		//labelWhen.font = [UIFont fontWithName: self.fontFamily size:11];
		labelWhen.text = [run getWhenFormatted];
		
		UILabel * labelDistance = (UILabel *) [cell viewWithTag: 2];
		labelDistance.text = [NSString stringWithFormat: @"%.2f", [[run getDistanceInUnits] floatValue]];
		UIColor * color = [Me getUIColor];
		labelDistance.textColor = color;
		//labelDistance.font = [UIFont fontWithName: self.fontFamily size:48];
		
		UILabel * labelUnits = (UILabel *) [cell viewWithTag : 5];
		NSString * myUnits = [Me getMyUnits];
		if ([myUnits isEqualToString: @"M"]) {
			labelUnits.text = @"mi";
		}
		else {
			labelUnits.text = @"km";
		}
		
		UIImageView * imageView = (UIImageView *) [cell viewWithTag: 6];
		imageView.image = nil;

		if ([run.type isEqualToString: @""]) {
			NSString * imageName = [Tracker getTrackerIconName];
			if (![imageName isEqualToString: @""]) {
				imageView.hidden = NO;
				[imageView setImage : [UIImage imageNamed: imageName]];
			}
			else {
				imageView.hidden = YES;
			}
		}
		else {
			imageView.hidden = NO;
			if ([run.type isEqualToString: @"Running"]) {
				//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"ran"];
				[imageView setImage: [UIImage imageNamed: @"63-runner.png"]];
			}
			if ([run.type isEqualToString: @"Cycling"]) {
				//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"biked"];
				[imageView setImage: [UIImage imageNamed: @"13-bicycle.png"]];
			}
			if ([run.type isEqualToString: @"Walking"]) {
				//labelUnits.text = [labelUnits.text stringByAppendingFormat: @" %@", @"walked"];
				imageView.image = [UIImage imageNamed: @"102-walk.png"];
			}
		}
		
		labelUnits.textColor = color;
		//labelUnits.font = [UIFont fontWithName: self.fontFamily size:16];

		UILabel * labelTime = (UILabel *) [cell viewWithTag: 3];
		labelTime.text = [run getDurationFormatted];
		//labelTime.font = [UIFont fontWithName: self.fontFamily size:14];
			
		UILabel * labelPace = (UILabel *) [cell viewWithTag: 4];
		labelPace.text = [run getPaceFormatted];
		//labelPace.font = [UIFont fontWithName: self.fontFamily size:14];
		
		UILabel * labelCommonDistance = (UILabel *) [cell viewWithTag: 7];
		labelCommonDistance.text = @"";
		NSString * commonDistance = [run getCommonDistance];
		if (![commonDistance isEqualToString: @""]) {
			labelCommonDistance.text = commonDistance;
			labelCommonDistance.font = [UIFont fontWithName: self.fontFamily size:12];
		
			labelCommonDistance.backgroundColor = [UIColor lightGrayColor];
			labelCommonDistance.textColor = [UIColor whiteColor];
			labelCommonDistance.layer.cornerRadius = 10.0;
		}
		
		UILabel * labelCalories = (UILabel *) [cell viewWithTag: 9];
		NSNumberFormatter * fmt = [[NSNumberFormatter alloc] init];
		fmt.numberStyle = NSNumberFormatterDecimalStyle;
		[fmt setMaximumFractionDigits:0];
	
		labelCalories.text = [NSString stringWithFormat: @"%@ calories", [fmt stringFromNumber: run.total_calories]]; // [run.total_calories intValue]]; 
		//labelCalories.font = [UIFont fontWithName: [Utilities fontFamily] size: 14];
		 
		UIImageView * imageTracker = (UIImageView *) [cell viewWithTag: 10];
		
		if ((run.source == nil) || [run.source isEqualToString: @"RunKeeper"] || [run.source isEqualToString: @""])  {
			imageTracker.image = [UIImage imageNamed: @"icon_runkeeper.png"];
		}
		else if ([run.source isEqualToString: @"Endomondo"]) {
			imageTracker.image = [UIImage imageNamed: @"icon_endomondo.png"];
		}
		else {
			imageTracker.hidden = YES;
		}
		[imageTracker setFrame: CGRectMake(300, 0, 20, 20)];
		imageTracker.alpha = 0.50;
		
		UILabel * lblHeartRate = (UILabel *) [cell viewWithTag: 11];
		UIImageView * imgHeartRate = (UIImageView *) [cell viewWithTag: 12];
		int heartRate = [run.heartRate intValue];
		if (heartRate > 0) {
			lblHeartRate.hidden = NO;
			imgHeartRate.hidden = NO;
			lblHeartRate.textColor = [UIColor whiteColor];
			lblHeartRate.backgroundColor = [UIColor clearColor];
			lblHeartRate.text = [NSString stringWithFormat: @"%i", heartRate];
		}
		else {
			lblHeartRate.hidden = YES;
			imgHeartRate.hidden = YES;
		}
		
		 
		 /*
		UILabel * gradeLabel = (UILabel *) [cell viewWithTag: 11];
		NSNumberFormatter * fmt = [[NSNumberFormatter alloc] init];
		fmt.numberStyle = NSNumberFormatterPercentStyle;
		//NSString * grade = [fmt stringFromNumber: run.averageGrade]; 
		NSString * grade = [NSString stringWithFormat:@"%.1f%%", [run.averageGrade floatValue] * 100];
		gradeLabel.text = [NSString stringWithFormat: @"%@ grade", grade];
		//gradeLabel.font = [UIFont fontWithName: [Utilities fontFamily] size: 14];
		*/
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
		
    return cell;
}

-(void) rowSelected : (NSIndexPath *) indexPath {
	switch(viewType.selectedSegmentIndex) {
		case 0 : {
			Activity * activity = nil;
	
			if (indexPath.section == 0) {
				if ([activities count] > 0) {
					activity = [activities objectAtIndex: indexPath.row];
				}
			}
			else {
				if ([prevActivities count] > 0) {
					activity = [prevActivities objectAtIndex: indexPath.row];
				}
			}
			
			if (activity) {
				//if ([activity.detailCount intValue] > 0) {
					// display detail
					self.detail = nil;
					self.detail = (ActivityDetailViewController *) [self.storyboard 
						instantiateViewControllerWithIdentifier: @"activityDetail"];

					[self.detail setActivity: activity];	
					[self.navigationController pushViewController: detail animated: YES];
					[self.detail displayDetail];
					self.navigationController.navigationItem.leftBarButtonItem.title = @"Back";
				//}
			}

		
			break;
		}
	}

	
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self rowSelected: indexPath];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[self rowSelected: indexPath];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		return [self.activities count] > 0;
	}
	else {
		return NO;
		//return [self.prevActivities count] > 0;
	}
	
}

//http://iphoneproghelp.blogspot.com/2008/12/uitableview-part-ii.html
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// delete from data
		StativityData * rkd = [StativityData get];
		Activity * activity = nil; 
		NSString * timeFrame = @"";
		if (indexPath.section == 0) {
			activity = [self.activities objectAtIndex: indexPath.row];
			timeFrame = [Me getTimeframeName];
			
		}
		else {
			activity = [self.prevActivities objectAtIndex: indexPath.row];
			timeFrame = [Me getPrevTimeframeName];
		}
		
		Activity * lastActivity = [rkd getLastActivity];
		BOOL notLast = NO;
		if (lastActivity != activity) {
			notLast = YES;
		}
		if (notLast) {
			NSString * msg = @"This activty is not the most recent activity. To restore this activity you'll need to reload all data or delete all activities after this activity. Proceeed?";
			UIAlertView * prompt = [[UIAlertView alloc]
				initWithTitle: @"Confirm" 
				message:[NSString stringWithFormat: msg, timeFrame] 
				delegate:nil 
				cancelButtonTitle: @"Cancel" 
				otherButtonTitles: @"Yes, Delete", nil];
				prompt.tag = 333;
				prompt.accessibilityLabel = [NSString stringWithFormat: @"%d", indexPath.section];
				prompt.accessibilityValue = [NSString stringWithFormat:@"%d", indexPath.row];
				prompt.delegate = self;
				[prompt show];
			 
		}
		else {
			[self deleteActivityAtSection: indexPath.section andRow: indexPath.row];
		}
	}
}

-(void) deleteActivityAtSection : (int) section andRow : (int) rowIndex {
	
	
	Activity * activity = nil; 
	if (section == 0) {
		activity = [self.activities objectAtIndex: rowIndex];
	}
	else {
		activity = [self.prevActivities objectAtIndex: rowIndex];
	}
	
	StativityData * rkd = [StativityData get];
	[rkd removeActivity: activity.id withContext: nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"runsLoaded" object:nil];
}




@end
