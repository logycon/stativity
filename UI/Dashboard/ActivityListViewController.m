//
//  ActivityListViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 9/9/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "ActivityListViewController.h"
#import "StativityData.h"
#import "DashboardItemFormatter.h"
#import "ActivityDetailViewController.h"
#import "HeaderView.h"
#import "Me.h"

@interface ActivityListViewController ()

@property (nonatomic, strong) NSArray * segments;
@property (nonatomic, strong) ActivityDetailViewController * detailView;
@property (nonatomic, strong) UISegmentedControl * sortBy;

@end

@implementation ActivityListViewController

@synthesize activityType;
@synthesize itemCode;
@synthesize displayName;
@synthesize myTableView;
@synthesize segments;
@synthesize detailView;
@synthesize sortBy;

-(void) displayActivitiesOfType:(NSString *)_activityType andCode:(NSString *)_itemCode andDisplayName:(NSString *)_displayName  {
	self.activityType = _activityType;
	self.itemCode = _itemCode;
	self.displayName = _displayName;
	self.navigationItem.title = [NSString stringWithFormat: @"%@ - %@", activityType, displayName];
	[self loadItems];
}

-(void) loadItems {
	NSString * title = @"";
	NSString * units = @"";
	if ([self.itemCode isEqualToString: @"s_half"]) {
		title = @"half";
		units = @"half";
	}
	if ([self.itemCode isEqualToString: @"s_full"]) {
		title = @"full";
		units = @"full";
	}
	if ([self.itemCode isEqualToString: @"s_1k"]) {
		title = @"1";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_1m"]) {
		title = @"1";
		units = @"m";
	}
	if ([self.itemCode isEqualToString: @"s_3m"]) {
		title = @"3";
		units = @"m";
	}
	if ([self.itemCode isEqualToString: @"s_5k"]) {
		title = @"5";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_5m"]) {
		title = @"5";
		units = @"m";
	}
	if ([self.itemCode isEqualToString: @"s_10k"]) {
		title = @"10";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_15k"]) {
		title = @"15";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_10m"]) {
		title = @"10";
		units = @"m";
	}
	if ([self.itemCode isEqualToString: @"s_20k"]) {
		title = @"20";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_30k"]) {
		title = @"30";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_40k"]) {
		title = @"40";
		units = @"k";
	}
	if ([self.itemCode isEqualToString: @"s_50k"]) {
		title = @"50";
		units = @"k";
	}
	
	NSDate * startDate = [Me getTimeframeStart];
	NSDate * endDate = [Me getTimeframeEnd];
	
	StativityData * sd = [StativityData get];
	self.segments = [sd getSegmentsBetweenStartDate: startDate andEndDate: endDate 
		ofType: self.activityType withTitle: title andUnits: units];
		
	// assign rank
	for(int i = 0; i < [self.segments count]; i++) {
		ActivitySegment * seg = [self.segments objectAtIndex: i];
		seg.rank = [NSNumber numberWithInt: i+1];
	}
	
	
	// sort
	NSString * sort_By = @"seconds";
	// for 1M or 1K look at all segments
	if ([title isEqualToString: @"1"]) {
		sort_By = @"segmentSeconds";
	}
	else {
		sort_By = @"seconds";
	}
	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey: sort_By ascending:YES];
	NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey: @"activityTime" ascending: NO];
	NSMutableArray * temp = [self.segments mutableCopy];
	if (self.sortBy.selectedSegmentIndex == 1) { // by time
		[temp sortUsingDescriptors: [NSArray arrayWithObjects: sort, sort2, nil]];
	}
	else { // by date
		[temp sortUsingDescriptors: [NSArray arrayWithObjects: sort2, sort, nil]];
	}
	self.segments = [temp copy];

	
	myTableView.dataSource = self;
	myTableView.delegate = self;
	[myTableView reloadData];
	
	//NSLog(@"%@", self.segments);
	
}

-(int) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int retval= 0;
	if (section == 0) {
		retval = [self.segments count];
	}
	return retval;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	//return 22;
	return 26;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString * text = [NSString stringWithFormat: @"%@ : %@", activityType, displayName];
	NSString * rightText = [Me getTimeframeName];
		
	return [[HeaderView alloc] 
		initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 26)
		andText : text
		andRightText: [rightText capitalizedString]
	];

}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * ident = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: ident];
    if (!cell) {
		cell = [[UITableViewCell alloc]
			initWithStyle: UITableViewCellStyleDefault 
			reuseIdentifier: ident];
	}
	
	ActivitySegment * segment = [self.segments objectAtIndex: indexPath.row];
	ActivityFormatter * af = [ActivityFormatter initWithSegment: segment];
	DashboardItemFormatter * fmt = [[DashboardItemFormatter alloc] init];
	fmt.itemCode = self.itemCode;
	fmt.activityType = self.activityType;
	fmt.periodActivity = af;
	
	//StativityData * data = [StativityData get];
	//Activity * activity = [data fetchActivity: segment.activityId];
	
	/*
	NSString * periodName = [[Me getTimeframeName] capitalizedString];
	UILabel * lblDisplayName = (UILabel *) [cell viewWithTag: 2];
	lblDisplayName.text = [[fmt displayName] stringByAppendingFormat: @" %@", periodName];
	lblDisplayName.textColor = [UIColor grayColor];
	*/
	
	UILabel * lblWhen = (UILabel *) [cell viewWithTag: 1];
	lblWhen.textColor = [UIColor grayColor];
	lblWhen.text = [fmt getPeriodWhen];
	
	UILabel * lblResult = (UILabel *) [cell viewWithTag: 2];
	lblResult.textColor = [Me getUIColor];
	lblResult.text = [fmt getPeriodResult];
	
	UILabel * lblPace = (UILabel *) [cell viewWithTag: 3];
	lblPace.textColor = [UIColor grayColor];
	NSString * pace = [fmt getPeriodPace];
	lblPace.Text = pace;
	
	UILabel * lblAgo = (UILabel *) [cell viewWithTag: 4];
	lblAgo.textColor = [UIColor grayColor];
	NSString * ago = [fmt getPeriodAgo];
	lblAgo.text = ago;
	
	UILabel * lblSpeed = (UILabel *) [cell viewWithTag: 5];
	lblSpeed.textColor = [UIColor grayColor];
	NSString * speed = [fmt getPeriodSpeed];
	lblSpeed.text = speed;
	
	UILabel * lblRank = (UILabel *) [cell viewWithTag: 6];
	lblRank.textColor = [UIColor grayColor];
	lblRank.text = [NSString stringWithFormat: @"#%d", [segment.rank intValue]];
	
	return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	ActivitySegment * segment = [self.segments objectAtIndex: indexPath.row];
	StativityData * sd = [StativityData get];
	Activity * activity = [sd fetchActivity: segment.activityId];
	self.detailView = nil;
	if (!self.detailView) {
		self.detailView = [self.storyboard instantiateViewControllerWithIdentifier: @"activityDetail"];
	}
	
	[self.detailView setActivity: activity];
	[self.navigationController pushViewController: self.detailView animated: YES];
	[self.detailView displayDetail];
	[self.myTableView deselectRowAtIndexPath: indexPath animated: NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.sortBy = [[UISegmentedControl alloc] initWithFrame: CGRectZero];
	self.sortBy.segmentedControlStyle = UISegmentedControlStyleBar;

	[self.sortBy insertSegmentWithTitle: @"By Pace" atIndex: 0 animated: NO];
	[self.sortBy insertSegmentWithTitle: @"By Date" atIndex: 0 animated: NO];
	
	[self.sortBy sizeToFit];
	self.sortBy.selectedSegmentIndex = 0;
	
	[self.sortBy addTarget:self
			action:@selector(sortByChanged:)
           forControlEvents:UIControlEventValueChanged];
	// Any of the following produces the expected result:
	self.navigationItem.titleView = self.sortBy;
}

-(void) sortByChanged : (id) sender  {
	[self loadItems];
}

- (void)viewDidUnload
{
	[self setMyTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
