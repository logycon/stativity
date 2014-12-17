//
//  DashboardViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "DashboardViewController.h"
#import "Me.h"
#import "Utilities.h"
#import "IIViewDeckController.h"
#import "MBProgressHUD.h"
#import "StativityData.h"
#import "ChooseDashboardItemsViewController.h"
#import "DashboardItem.h"
#import "DashboardItemFormatter.h"
#import <QuartzCore/QuartzCore.h>
#import "PullToRefreshView.h"
#import "ActivityDetailViewController.h"
#import "ActivityListViewController.h"
#import <Twitter/Twitter.h>
#import "Tracker.h"

@interface DashboardViewController ()

@property (nonatomic, strong) NSString * loading;
@property (nonatomic, strong) NSString * currentUnits;
@property (nonatomic, strong) NSString * currentTimeframe;
@property (nonatomic, strong) NSNumber * currentFirstDOW;
@property (nonatomic, strong) NSMutableArray * dashboardItems;
@property (nonatomic, strong) ChooseDashboardItemsViewController * chooser;
@property (nonatomic, strong) NSString * twitterString;
@property (nonatomic, strong) ActivityListViewController * activityListView;
@property (nonatomic, strong) ActivityDetailViewController * detailView;

@end

@implementation DashboardViewController

PullToRefreshView * pullView;

@synthesize loading;
@synthesize currentUnits;
@synthesize currentTimeframe;
@synthesize currentFirstDOW;
@synthesize dashboardItems;
@synthesize chooser;
@synthesize twitterString;

@synthesize activityType;
@synthesize segmentedActivityType;
@synthesize btnAdd;
@synthesize myTableView;
@synthesize lblPeriod;

@synthesize activityListView;
@synthesize detailView;



-(void) awakeFromNib {
	[self initDashboardItems];
}

-(void) initDashboardItems {
	StativityData * rkd = [StativityData get];
	//[rkd removeAllDashboardItems];
	int numItems = [rkd getNumberOfDashboardItems];
	if (numItems == 0) {
		[rkd createDashboardItems];
	}
	else {
		[rkd updateDashboardItems];
	}
}

- (IBAction)segmentedActivityTypeChanged:(id)sender {
	switch(segmentedActivityType.selectedSegmentIndex) {
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
	
	NSNumber * option = [NSNumber numberWithInt : segmentedActivityType.selectedSegmentIndex];
	[[NSUserDefaults standardUserDefaults] setObject: option forKey: @"activityType2"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// reload the UX
	[self doLoadDashboard];
	//[self loadDashboard];
}


-(void) checkReload {
	BOOL needReload = NO;
	if (self.currentUnits) {
		if (![self.currentUnits isEqualToString: [Me getMyUnits]]) {
			needReload = YES;
		}
	}
	
	if (!needReload) {
		if (![self.currentTimeframe isEqualToString: [Me getMyTimeframe]]) {
			needReload = YES;
		}
	}
	
	if (!needReload) {
		if ([self.currentFirstDOW intValue] != [Me getFirstDayOfWeek]) {
			needReload = YES;
		}
	}
	
	if (needReload) {
		//NSLog(@"need reload");
		[self doLoadDashboard];
		//[self loadDashboard];
		//[self updateUI];
	}
	
}

-(void) viewWillAppear:(BOOL)animated {
	[self initDashboardItems];
}

-(void) viewDidAppear:(BOOL)animated {
	[self doLoadDashboard];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateUI];
	self.loading = @"n";
	self.myTableView.dataSource = self;
	self.myTableView.delegate = self;
	
		// load left menu UX
	UIImage * img = [UIImage imageNamed: @"259-list.png"];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
		initWithImage: img
		style: UIBarButtonItemStyleBordered
		target:self.viewDeckController 
		action:@selector(toggleLeftView)];	
		
	// setup notifications
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector : @selector(timeFrameChanged)
		name : @"TimeframeChanged"
		object : nil];
		
		// register for notification
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector : @selector(runsLoadedNotification:)
		name : @"runsLoaded"
		object : nil];
		
	NSNumber * option = [[NSUserDefaults standardUserDefaults] objectForKey: @"activityType2"];
	if (option) {
		segmentedActivityType.selectedSegmentIndex = [option intValue];
			switch(segmentedActivityType.selectedSegmentIndex) {
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
	else {
		self.activityType = @"Running";
	}
	
	pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.myTableView];
	[pullView setDelegate:self];
	[pullView refreshLastUpdatedDate];
	[self.myTableView addSubview:pullView];
	
	[self doLoadDashboard];
	//[self loadDashboard];
}

-(void) timeFrameChanged {
	//if (self.isViewLoaded && self.view.window) {
		[self updateUI];
		[self doLoadDashboard];
	//}
}

-(void) runsLoadedNotification:(NSNotification *)notification {
	int newActivities = -1;
	if (notification.object) newActivities = [notification.object intValue];
	[self doLoadDashboard];
	[self updateUI];
	self.twitterString = [NSString stringWithFormat: @"%@\n", [[Me getTimeframeName] lowercaseString ]];
	[self.myTableView reloadData];
}

-(void) updateUI {
	UIColor * uiColor = [Me getUIColor];
	[self.navigationController.navigationBar setTintColor: uiColor];
	[self.tabBarController.tabBar setTintColor: [Me getTabBarColor]]; 
	self.navigationController.navigationBar.tintColor = uiColor;
	//[self.tabBarController.tabBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor],UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor, nil];
	[self.navigationController.navigationBar setTitleTextAttributes: attributes];	
	*/
	UIFont *font = [UIFont fontWithName: [Utilities fontFamily] size :12.0f];
	NSDictionary *fontAttr = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
	[self.segmentedActivityType setTitleTextAttributes:fontAttr forState:UIControlStateNormal];
	lblPeriod.text = [Me getTimeframeText];

}

-(void) loadDashboard {
	[self doLoadDashboard];
	return;

	if (self.isViewLoaded && self.view.window) {
				
		if ([self.loading isEqualToString: @"n"]) {
			MBProgressHUD * __block HUD = nil;
			UIView * hudView __block = nil;
			if  (self.view.window) {
				//hudView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
				hudView = self.view;
				if (hudView) {
					HUD = [MBProgressHUD HUDForView: hudView];
					if (!HUD) {
						HUD = [MBProgressHUD showHUDAddedTo: hudView animated:YES];
						HUD.labelText = @"Refreshing Dashboard...";
						HUD.removeFromSuperViewOnHide = YES;
						HUD.delegate = self;
					}
				}
			}
			else {
				HUD = nil;
			}
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{						
				[self doLoadDashboard];
				[self updateUI];
				self.twitterString = [NSString stringWithFormat: @"%@\n", [[Me getTimeframeName] lowercaseString ]];
				[self.myTableView reloadData];
			
				dispatch_async(dispatch_get_main_queue(), ^{
				/*
					[self updateUI];
					self.twitterString = [NSString stringWithFormat: @"%@\n", [[Me getTimeframeName] lowercaseString ]];
					;*/
					if (HUD) {
						[MBProgressHUD hideHUDForView: hudView animated:YES];
					}
					[pullView finishedLoading];
					[self.myTableView reloadData];
				});
			});
		}
	}
}

- (void)viewDidUnload
{
	[self setSegmentedActivityType:nil];
	[self setBtnAdd:nil];
	[self setMyTableView:nil];
	[self setMyTableView:nil];
	[self setLblPeriod:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) doLoadDashboard {
	//NSLog(@"doLoadDashboard");
	
	if (!self.dashboardItems) {
		self.dashboardItems = [[NSMutableArray alloc] init];
	}
	else {
		[self.dashboardItems removeAllObjects];
	}
	
	self.loading = @"y";
	self.currentUnits = [Me getMyUnits];
	self.currentTimeframe = [Me getMyTimeframe];
	self.currentFirstDOW = [NSNumber numberWithInt: [Me getFirstDayOfWeek]];
	
	NSDate * startDate = [Me getTimeframeStart];
	NSDate * endDate = [Me getTimeframeEnd];
	
	// load the items here
	StativityData * rkd = [StativityData get];
	NSArray * items = [rkd fetchSelectedDashboardItemsForActivity: [self getActivityTypeStr]];
	for(int i = 0; i < [items count]; i++) {
		DashboardItemFormatter * fmt = [[DashboardItemFormatter alloc] 
			initWithItem: [items objectAtIndex: i]];
		[fmt loadForPeriod: startDate andEnding: endDate];
		[self.dashboardItems addObject: fmt];
	}
	self.loading = @"n";
	NSDate * lastRefresh = [Utilities currentLocalTime];
	[[NSUserDefaults standardUserDefaults] setValue: lastRefresh forKey: @"lastDashboardRefresh"];
	
	[pullView finishedLoading];
	
	self.twitterString = [NSString stringWithFormat: @"%@\n", [[Me getTimeframeName] lowercaseString ]];
	[self.myTableView reloadData];
}

#pragma mark PullToRefreshViewDelegate methods
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view 
{
	[self doLoadDashboard];
	//[self loadDashboard];
}

-(NSDate *) pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
	return [[NSUserDefaults standardUserDefaults] valueForKey: @"lastDashboardRefresh"];
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	//[hud release];
	hud = nil;
}

// tableview delegates

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([self.dashboardItems count] == 0) {
		return 1;
	}
	else {
		return [self.dashboardItems count];
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat retval = 0;
	if ([self.dashboardItems count] == 0) {
		retval = self.myTableView.frame.size.height;
	}
	else {
		retval = 85;
	}
	return retval;
}

-(void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [tableView cellForRowAtIndexPath: indexPath];
	UILabel * lblPR = (UILabel *) [cell viewWithTag: 7];
	UILabel * lblPRWhen = (UILabel *) [cell viewWithTag: 8];
	UIImageView * imgMedal = (UIImageView *) [cell viewWithTag: 10];
	UIImageView * imgDisclosure = (UIImageView *) [cell viewWithTag: 11];
	UILabel * lblPrLabel = (UILabel *) [cell viewWithTag: 12];
	
	lblPR.hidden = YES;
	lblPRWhen.hidden = YES;
	imgMedal.hidden = YES;
	imgDisclosure.hidden = YES;
	lblPrLabel.hidden = YES;
}

-(void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row <= [self.dashboardItems count] - 1) {
		DashboardItemFormatter * fmt = [self.dashboardItems objectAtIndex: indexPath.row];
		UITableViewCell * cell = [tableView cellForRowAtIndexPath: indexPath];
		[self updateCellPRAreaForCell: cell withFormatter: fmt];
	}
}

-(void) updateCellPRAreaForCell : (UITableViewCell *) cell withFormatter : (DashboardItemFormatter *) fmt {
	UILabel * lblPR = (UILabel *) [cell viewWithTag: 7];
	lblPR.textColor = [UIColor darkGrayColor];
	UILabel * lblPRWhen = (UILabel *) [cell viewWithTag: 8];
	UIImageView * imgMedal = (UIImageView *) [cell viewWithTag: 10];
	UIImageView * imgDisclosure = (UIImageView *) [cell viewWithTag: 11];
	UILabel * lblPrLabel = (UILabel *) [cell viewWithTag: 12];
	lblPrLabel.hidden = YES;
	if ((fmt.allTimeActivity) && (![fmt.allTimeActivity.activityId isEqualToString: fmt.periodActivity.activityId])) {
		imgMedal.hidden = NO;
		[imgMedal setImage: nil];
		imgMedal.backgroundColor = [UIColor whiteColor];
		imgMedal.layer.cornerRadius = 20;
		imgMedal.layer.frame = CGRectMake(217, 3, 76, 78);
		imgMedal.layer.borderColor = [UIColor grayColor].CGColor;
		imgMedal.layer.borderWidth = 2;
		lblPR.hidden = NO;
		lblPRWhen.hidden = NO;
		lblPrLabel.hidden = NO;
		lblPR.text = [fmt getPRResult];
		lblPRWhen.text = [fmt getPRWhen];
		if (![[fmt getPeriodResult] isEqualToString: @"N/A"]) {
			imgDisclosure.hidden = NO;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		else {
			imgDisclosure.hidden = YES;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	else {
		if (fmt.allTimeActivity) {
			imgMedal.hidden = NO;	
			imgMedal.backgroundColor = [UIColor whiteColor];
			[imgMedal setImage: [UIImage imageNamed 	: @"goldbadge.png"]];
			imgMedal.layer.cornerRadius = 0;
			imgMedal.layer.frame = CGRectMake(207, 3, 96, 78);
			imgMedal.layer.borderColor = [UIColor whiteColor].CGColor;
			imgMedal.layer.borderWidth = 0;
					
			lblPR.hidden = NO;
			lblPR.text = @"New Personal Best!";
			lblPR.textColor = [UIColor redColor];
			lblPRWhen.hidden = YES;
			if (![[fmt getPeriodResult] isEqualToString: @"N/A"]) {
				imgDisclosure.hidden = NO;
				cell.selectionStyle = UITableViewCellSelectionStyleGray;
			}
			else {
				imgDisclosure.hidden = YES;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
		}
		else {
			imgMedal.hidden = YES;
			lblPR.hidden = YES;
			lblPRWhen.hidden = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			imgDisclosure.hidden = YES;
		}
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	if ([self.dashboardItems count] == 0) {
		CellIdentifier = @"emptyCell";
	}
	else {
		CellIdentifier = @"Cell";
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
		cell = [[UITableViewCell alloc]
			initWithStyle: UITableViewCellStyleDefault 
			reuseIdentifier: CellIdentifier];
	}
    // Configure the cell...
		
	if ([self.dashboardItems count] == 0) { // emptyCell
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"tap to add items";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	else { // cell
		cell.textLabel.text = @"";
		DashboardItemFormatter * fmt = [self.dashboardItems objectAtIndex: indexPath.row];
		cell.accessibilityLabel = [NSString stringWithFormat: @"%d", indexPath.row];
		
		UIImageView * imageView = (UIImageView *) [cell viewWithTag: 1];
		NSString * imageName = @"";
		if ([fmt.itemCategory isEqualToString: @"Distance"]) {
			imageName = @"238-road@2x.png";
		}
		if ([fmt.itemCategory isEqualToString: @"Speed"]) {
			imageName = @"81-dashboard@2x.png";
		}
		if ([fmt.itemCategory isEqualToString: @"Duration"]) {
			imageName = @"11-clock@2x.png";
		}
		[imageView setImage: [UIImage imageNamed: imageName]];
		
		NSString * periodName = [[Me getTimeframeName] capitalizedString];
		UILabel * lblDisplayName = (UILabel *) [cell viewWithTag: 2];
		lblDisplayName.text = [[fmt displayName] stringByAppendingFormat: @" %@", periodName];
		lblDisplayName.textColor = [UIColor grayColor];
		
		UILabel * lblResult = (UILabel *) [cell viewWithTag: 3];
		lblResult.textColor = [Me getUIColor];
		lblResult.text = [fmt getPeriodResult];
		
		UILabel * lblWhen = (UILabel *) [cell viewWithTag: 4];
		lblWhen.textColor = [UIColor grayColor];
		lblWhen.text = [fmt getPeriodWhen];
		
		UILabel * lblAgo = (UILabel *) [cell viewWithTag: 5];
		lblAgo.textColor = [UIColor grayColor];
		lblAgo.text = [fmt getPeriodAgo];
		
		[self updateCellPRAreaForCell : cell withFormatter : fmt];
		
		cell.showsReorderControl = NO;
	}
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return [self.dashboardItems count] > 0;
}


-(int) findItemIndex : (NSString *) itemCode {
	int retval = NSNotFound;
	for(int i = 0; i < [self.dashboardItems count]; i++) {
		DashboardItemFormatter * fmt = [self.dashboardItems objectAtIndex: i];
		if ([fmt.itemCode isEqualToString: itemCode]) {
			retval = i;
			break;
		}
	}
	return retval;
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone; 
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	 if ([self.dashboardItems count] == 0) {
		if(indexPath.row == 0) {
			if (!self.chooser) {
				chooser = (ChooseDashboardItemsViewController *) [self.storyboard 
				instantiateViewControllerWithIdentifier: @"pickdashboarditems"];
				chooser.delegate = self;
			}
			chooser.segmentedActivityType.selectedSegmentIndex = self.segmentedActivityType.selectedSegmentIndex;
			chooser.activityType = [self getActivityTypeStr];
			[chooser loadItems];
			[self presentModalViewController: chooser animated: YES];
		}
	 }
	 else {
		UITableViewCell * cell = [self.myTableView cellForRowAtIndexPath: indexPath];
		int index = [cell.accessibilityLabel intValue];
		DashboardItemFormatter * formatter = [self.dashboardItems objectAtIndex: index];
		NSString * periodResult = [formatter getPeriodResult];
		NSString * prResult = [formatter getPRResult];
		
		if (!([periodResult isEqualToString: @"N/A"] && [prResult isEqualToString: @"N/A"]) ) {
			if ([formatter.itemCategory isEqualToString: @"Speed"]) {
				//NSLog(@"Display list for %@", formatter.itemCode);
				self.activityListView = nil;
				if (!self.activityListView) {
					self.activityListView = [self.storyboard instantiateViewControllerWithIdentifier: @"activityListViewController"];
				}
				[self.navigationController pushViewController: self.activityListView animated: YES];
				NSString * displayName = [formatter.displayName stringByReplacingOccurrencesOfString: @"Best " withString: @""]; // options:<#(NSStringCompareOptions)#> range:<#(NSRange)#>
				[self.activityListView displayActivitiesOfType : self.activityType andCode : formatter.itemCode andDisplayName : displayName];
				
				/*
				if (!detailView) {
					detailView = [self.storyboard instantiateViewControllerWithIdentifier: @"activityDetail"];
				}
				StativityData * rkd = [StativityData get];
				Activity * activity = [rkd fetchActivity: formatter.periodActivity.activityId];
				[detailView setActivity: activity];
				[self.navigationController pushViewController: detailView animated: YES];
				[detailView displayDetail];
				*/
			}
			else {
				self.detailView = nil;
				if (!self.detailView) {
					self.detailView = [self.storyboard instantiateViewControllerWithIdentifier: @"activityDetail"];
				}
				StativityData * rkd = [StativityData get];
				Activity * activity = [rkd fetchActivity: formatter.periodActivity.activityId];
				[self.detailView setActivity: activity];
				[self.navigationController pushViewController: self.detailView animated: YES];
				[self.detailView displayDetail];
			}
		}
		[self.myTableView deselectRowAtIndexPath: indexPath animated: YES];
		
	 }
}

-(NSString *) getActivityTypeStr {
	NSString * retval = @"";
	switch(self.segmentedActivityType.selectedSegmentIndex) {
		case 0 : {
			retval = @"Running";
			break;
		}
		case 1 : {
			retval = @"Cycling";
			break;
		}
		case 2 : {
			retval = @"Walking";
			break;
		}
	}
	return retval;
}

- (IBAction)btnAddClick:(id)sender {
	if ([self.dashboardItems count] > 0) {
		UIActionSheet * actionSheet;
		
		if ([Utilities isSocialAvailable]) {
			actionSheet = [[UIActionSheet alloc]
				initWithTitle: @"Actions" 
				delegate:self 
				cancelButtonTitle: @"Close" 
				destructiveButtonTitle: nil 
				otherButtonTitles: 
					@"Add Items",
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
					@"Add Items",
					@"Take Screen Shot",
					@"Tweet",
					@"Copy",
					nil];
		}
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		actionSheet.alpha = 0.85;
		[actionSheet showFromTabBar: self.tabBarController.tabBar];
	}
	else {
		if (!self.chooser) {
			chooser = (ChooseDashboardItemsViewController *) [self.storyboard 
			instantiateViewControllerWithIdentifier: @"pickdashboarditems"];
			chooser.delegate = self;
		}
		chooser.segmentedActivityType.selectedSegmentIndex = self.segmentedActivityType.selectedSegmentIndex;
		[chooser setActivityType: [self getActivityTypeStr]];
		[chooser loadItems];
		[self presentModalViewController: chooser animated: YES];
	}
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (!self.chooser) {
			chooser = (ChooseDashboardItemsViewController *) [self.storyboard 
				instantiateViewControllerWithIdentifier: @"pickdashboarditems"];
			chooser.delegate = self;
			
		}
		chooser.segmentedActivityType.selectedSegmentIndex = self.segmentedActivityType.selectedSegmentIndex;
		[chooser setActivityType : [self getActivityTypeStr]];
		[chooser loadItems];
		[self presentModalViewController: chooser animated: YES];
	}
	
	if (buttonIndex == 1) {
		UIGraphicsBeginImageContext(self.view.frame.size);
		[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
		
		[[[UIAlertView alloc] 
			initWithTitle: @"Done" 
			message: @"Screen Shot was added to your Photo Library." 
			delegate: nil 
			cancelButtonTitle: @"OK" 
			otherButtonTitles: nil] 
		show];
	}
	
	if (buttonIndex == 2) {
		[self tweet];
	}
	
	if ([Utilities isSocialAvailable]) {
		if (buttonIndex == 3) {
			[self facebook];
		}
		
		if (buttonIndex == 4) {
			[self copyToPasteBoard];
		}
	}
	else {
		if (buttonIndex == 3) {
			[self copyToPasteBoard];
		}
	}
}

-(void) copyToPasteBoard {
	[self updateTwitterString];
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString: self.twitterString];
	
	[[[UIAlertView alloc] 
		initWithTitle: @"Done" message: 
		[NSString stringWithFormat: @"%@ has been copied to PasteBoard", @"DashBoard content"]
		delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
}

-(void) updateTwitterString {
	NSString * suffix = [NSString stringWithFormat: @"with %@ via @Stativity", [Tracker getTrackerHashTag]];
	int maxLen = 140 - [suffix length];
	self.twitterString = [NSString stringWithFormat: @"%@\n", [Me getTimeFrameProperCased]];
	for(int i = 0; i < [self.dashboardItems count]; i++) {
		DashboardItemFormatter * fmt = [self.dashboardItems objectAtIndex:i];
		if (![[fmt getPeriodResult] isEqualToString: @"N/A"]) {
			NSString * newString = [NSString stringWithFormat: @"%@ %@\n", 
					fmt.displayName, [fmt getPeriodResultVeryShort]];
			
			NSString * totalString = [self.twitterString stringByAppendingString : newString];
			if ([totalString length] < maxLen) {
				self.twitterString = [self.twitterString stringByAppendingString : newString];
			}
			else {
				break;
			}
		}
	}
	self.twitterString = [self.twitterString stringByAppendingString: suffix];
}

-(void) facebook {
	if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
		[self updateTwitterString];
        SLComposeViewController *mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		[mySLComposerSheet setInitialText: self.twitterString];
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
		TWTweetComposeViewController * twitter = [[TWTweetComposeViewController alloc] init];
		[self updateTwitterString];
		[twitter setInitialText: self.twitterString];
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


-(DashboardItemFormatter *) findItemByCode : (NSString *) code {
	DashboardItemFormatter * retval = nil;
	for(int i = 0; i < [self.dashboardItems count]; i++) {
		DashboardItemFormatter * item = [self.dashboardItems objectAtIndex : i];
		if ([item.itemCode isEqualToString: code])  {
			retval = item;
			break;
		}
	}
	return retval;
}

-(void) editingDone {
	// save item order
	for(int i = 0; i < [self.dashboardItems count]; i++) {
		NSIndexPath * indexPath = [NSIndexPath indexPathForRow: i inSection: 0];
		UITableViewCell * cell = [self.myTableView cellForRowAtIndexPath: indexPath];
		int itemIndex = [cell.accessibilityLabel intValue];
		DashboardItemFormatter * item = [self.dashboardItems objectAtIndex: itemIndex];
		item.itemOrder = [NSNumber numberWithInt: i];
	}
	
	StativityData * rkd = [StativityData get];
	[rkd updateItemOrders: [self.dashboardItems copy] forActivity: self.activityType];
	[self.myTableView setEditing: NO animated: NO];
	[self doLoadDashboard];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
			initWithBarButtonSystemItem: UIBarButtonSystemItemAdd // UIBarButtonSystemItemAction
			target:self action: @selector(btnAddClick:)];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		UITableViewCell * cell = [self.myTableView cellForRowAtIndexPath: indexPath];
		int itemIndex = [cell.accessibilityLabel intValue];
		DashboardItemFormatter * item = [self.dashboardItems objectAtIndex: itemIndex];
		NSString * itemCode = item.itemCode;
		[self.dashboardItems removeObjectAtIndex: itemIndex];
		
	    //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		StativityData * rkd = [StativityData get];
    	[rkd deselectDashboardItem: itemCode forActivity: [self getActivityTypeStr]];
		
		// save item order
		for(int i = 0; i < [self.dashboardItems count]; i++) {
			NSIndexPath * indexPath = [NSIndexPath indexPathForRow: i inSection: 0];
			UITableViewCell * cell = [self.myTableView cellForRowAtIndexPath: indexPath];
			int itemIndex = [cell.accessibilityLabel intValue];
			DashboardItemFormatter * item = [self.dashboardItems objectAtIndex: itemIndex];
			item.itemOrder = [NSNumber numberWithInt: i];
		}
		
		rkd = [StativityData get];
		[rkd updateItemOrders: [self.dashboardItems copy] forActivity: self.activityType];
			
		[self doLoadDashboard];
	}   
	
	
	/*
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    } */  
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	toIndexPath:(NSIndexPath *)toIndexPath
{
	

}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}





@end
