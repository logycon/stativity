//
//  ChooseDashboardItemsViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "ChooseDashboardItemsViewController.h"
#import "Me.h"
#import "StativityData.h"
#import "DashboardItem.h"
#import "DashboardItemFormatter.h"

@interface ChooseDashboardItemsViewController ()

@property (nonatomic, strong) NSArray * items;

@property (nonatomic, strong) NSMutableArray * selectedRunningItems;
@property (nonatomic, strong) NSMutableArray * selectedCyclingItems;
@property (nonatomic, strong) NSMutableArray * selectedWalkingItems;

@end

@implementation ChooseDashboardItemsViewController

@synthesize myTableView;
@synthesize btnDone;
@synthesize btnCancel;
@synthesize myNavigationBar;
@synthesize delegate;
@synthesize activityType;
@synthesize segmentedActivityType;

@synthesize items;

@synthesize selectedCyclingItems;
@synthesize selectedRunningItems;
@synthesize selectedWalkingItems;


- (IBAction)btnCancelClick:(id)sender {
	[self dismissModalViewControllerAnimated: YES];
}

- (IBAction)btnDoneClick:(id)sender {
	// save selections
	[self dismissModalViewControllerAnimated:YES];
	StativityData * rkd = [StativityData get];
	if ([self.selectedRunningItems count] > 0) {
		[rkd selectDashboardItems: [self.selectedRunningItems copy] forActivity: @"Running"];
	}
	if ([self.selectedCyclingItems count] > 0) {
		[rkd selectDashboardItems: [self.selectedCyclingItems copy] forActivity: @"Cycling"];
	}
	if ([self.selectedWalkingItems count] > 0) {
		[rkd selectDashboardItems: [self.selectedWalkingItems copy] forActivity: @"Walking"];
	}
	
	if(delegate) {
		if ([delegate respondsToSelector: @selector(loadDashboard)]) {
			[delegate performSelector: @selector(loadDashboard)];
		}
	}
}
- (IBAction)selectedActivityChanged:(id)sender {
	NSString * newActivity = @"";
	switch(self.segmentedActivityType.selectedSegmentIndex) {
		case 0 : {
			newActivity = @"Running";
			break;
		}
		case 1: {
			newActivity = @"Cycling";
			break;
		}
		case 2 : {
			newActivity = @"Walking";
			break;
		}
	}
	self.activityType = newActivity;
	[self loadItems];
}

-(void) loadItems {
	StativityData * rkd = [StativityData get];
	self.items = [rkd fetchUnselectedDashboardItemsForActivity: self.activityType];
	if (!self.selectedRunningItems) {
		self.selectedRunningItems = [[NSMutableArray alloc] init];
		self.selectedCyclingItems = [[NSMutableArray alloc] init];
		self.selectedWalkingItems = [[NSMutableArray alloc] init];
	}
	[self.myTableView reloadData];
}

-(void) updateUI {
	self.myNavigationBar.tintColor = [Me getUIColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateUI];
	self.myTableView.delegate = self;
	self.myTableView.dataSource = self;
}

- (void)viewDidUnload
{
	[self setMyTableView:nil];
	[self setBtnDone:nil];
	[self setBtnCancel:nil];
	[self setMyNavigationBar:nil];
	[self setSegmentedActivityType:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated {
	if ([self.activityType isEqualToString: @"Running"]) {
		self.segmentedActivityType.selectedSegmentIndex = 0;
	}
	else {
		if ([self.activityType isEqualToString: @"Cycling"]) {
			self.segmentedActivityType.selectedSegmentIndex = 1;
		}
		else {
			if ([self.activityType isEqualToString: @"Walking"]) {
				self.segmentedActivityType.selectedSegmentIndex = 2;
			}
		}
	}
	
	if(self.selectedRunningItems) [self.selectedRunningItems removeAllObjects];
	if(self.selectedCyclingItems) [self.selectedCyclingItems removeAllObjects];
	if(self.selectedWalkingItems) [self.selectedWalkingItems removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(int) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.items count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * CellIdentifier = @"cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
			initWithStyle: UITableViewCellStyleDefault
			reuseIdentifier: CellIdentifier];
	}    
	
	DashboardItem * item = [self.items objectAtIndex: indexPath.row];
	
	DashboardItemFormatter * fmt = [[DashboardItemFormatter alloc] initWithItem: item];
	cell.textLabel.text = [fmt displayName];
	cell.accessibilityLabel = fmt.itemCode;
	
	NSMutableArray * selArray = nil;
	switch(self.segmentedActivityType.selectedSegmentIndex) {
		case 0 : {
			selArray = self.selectedRunningItems;
			break;
		}
		case 1: {
			selArray = self.selectedCyclingItems;
			break;
		}
		case 2 : {
			selArray = self.selectedWalkingItems;
			break;
		}
	}
	
	int selIndex = [selArray indexOfObject: fmt.itemCode];
	if (selIndex != NSNotFound) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [self.myTableView cellForRowAtIndexPath: indexPath];
	NSString * itemCode = cell.accessibilityLabel;
	NSMutableArray * selArray = nil;
	switch(self.segmentedActivityType.selectedSegmentIndex) {
		case 0 : {
			selArray = self.selectedRunningItems;
			break;
		}
		case 1: {
			selArray = self.selectedCyclingItems;
			break;
		}
		case 2 : {
			selArray = self.selectedWalkingItems;
			break;
		}
	}
	int selIndex = [selArray indexOfObject: itemCode];
	if (selIndex != NSNotFound) {
		[selArray removeObjectAtIndex: selIndex];
	}
	else {
		[selArray addObject: itemCode];
	}
	[self.myTableView reloadData];
}


@end
