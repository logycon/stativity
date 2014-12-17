//
//  ConfigureViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "ConfigureViewController.h"
#import "FirstDayOfWeekViewController.h"
#import "HomeScreenImageController.h"
#import "MyNikePlusIDController.h"
#import "MyUnitsController.h"
#import "Me.h"
#import "RunKeeper.h"
#import "StativityData.h"
#import "Endomondo.h"
#import "EndomondoLoginViewController.h"
#import "GarminLoginViewController.h"
#import "iRate.h"
#import "RemindersViewController.h"
#import "Reminder.h"
#import "Garmin.h"

@interface ConfigureViewController ()

@property (nonatomic, strong) EndomondoLoginViewController * endomondoLogin;
@property (nonatomic, strong) GarminLoginViewController * garminlogin;
@property (nonatomic, strong) RemindersViewController * remindersController;

@end

@implementation ConfigureViewController

@synthesize configureTable;
@synthesize lblCurrentUnits;
@synthesize lblRunkeeperStatus;
@synthesize imgCircle;
@synthesize lblFirstDayOfWeek;
@synthesize lblEndomondoStatus;
@synthesize lblEndomondoGreen;
@synthesize lblGarminStatus;
@synthesize lblGarminGreen;
@synthesize lblNextReminder;
@synthesize endomondoLogin;
@synthesize garminlogin;
@synthesize remindersController;

-(BOOL) shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

-(void) viewWillAppear:(BOOL)animated {
	[self updateUI];
}

-(void) connectedToRK {
	[self updateUI];
}

-(void) connectedToEndo {
	[self updateUI];
}

-(void) updateUI {
	UIColor * uiColor = [Me getUIColor];
	[self.navigationController.navigationBar setTintColor: uiColor];
	//[self.tabBarController.tabBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor],UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor, nil];
	[self.navigationController.navigationBar setTitleTextAttributes: attributes];*/	
	
	NSString * myUnits = [Me getMyUnits];
	NSString * unitsText = ([myUnits isEqualToString: @"M"] ? @"Miles" : @"Kilometers");
	self.lblCurrentUnits.text = unitsText;
	
	switch ([Me getFirstDayOfWeek]) {
		case 1 : {
			self.lblFirstDayOfWeek.text = @"Sunday";
			break;
		}
		case 2 : {
			self.lblFirstDayOfWeek.text = @"Monday";
			break;
		}
	}

	RunKeeper * rk = [RunKeeper sharedInstance];
	if (rk.connected) {
		self.lblRunkeeperStatus.text = @"Connected.";
		[self.imgCircle setImage: [UIImage imageNamed: @"circle_green.png"]];
		//self.lblRunkeeperStatus.textColor = [UIColor colorWithRed:0 green:100/256. blue:0 alpha:1];
	}
	else {
		self.lblRunkeeperStatus.text = @"Not Connected. Tap to Connect.";
		[self.imgCircle setImage: [UIImage imageNamed: @"circle_red.png"]];
		//self.lblRunkeeperStatus.textColor = [UIColor redColor];
	}
	
	Endomondo * endo = [Endomondo sharedInstance];
	if (endo.connected) {
		self.lblEndomondoStatus.text = @"Connected.";
		[self.lblEndomondoGreen setImage: [UIImage imageNamed : @"circle_green.png"]];
	}
	else {
		self.lblEndomondoStatus.text = @"Not Connected. Tap to Connect.";
		[self.lblEndomondoGreen setImage: [UIImage imageNamed: @"circle_red.png"]];
	}
	
	Garmin * garmin = [Garmin sharedInstance];
	if (garmin.connected) {
		self.lblGarminStatus.text = @"Connected.";
		[self.lblGarminGreen setImage: [UIImage imageNamed : @"circle_green.png"]];
	}
	else {
		self.lblGarminStatus.text = @"Not Connected. Tap to Connect.";
		[self.lblGarminGreen setImage: [UIImage imageNamed: @"circle_red.png"]];
	}

	lblNextReminder.text = [Reminder getNextReminderDate];

}

-(void) reminderChanged {
	lblNextReminder.text = [Reminder getNextReminderDate];
}

-(void) runsLoaded {
	[self updateUI];
	for(int i = 0; i < [self.tabBarController.viewControllers count]; i++) {
		id nav = [self.tabBarController.viewControllers objectAtIndex: i];
		if ([nav class] == [UINavigationController class]) {
			UINavigationController * _nav = (UINavigationController *)nav;
			for(int j = 0; j < [_nav.viewControllers count]; j++) {
				id tvc = [_nav.viewControllers objectAtIndex: j];
				NSLog(@"%@", [tvc class]);
				if ([tvc class] != [self class]) {
					if ([tvc respondsToSelector: @selector(runsLoaded)]) {
						[tvc performSelector : @selector(runsLoaded)];
					}
				}
			}
		}
	}
}

-(void) doLoadView {
// setup UI color	[self updateUI];
	[self updateUI];
	//self.lblCurrentID.text = [Me getMyID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    
{
	int retval = 0;
	
	if (section == 0) {
		retval = 4; 
	}
	
	// trackers
	if (section == 1) {
		return 2;
	}
	
	if (section == 2) {
		retval = 1;
	}
	
	if (section == 3) {
		retval = 2;
	}
	return retval;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self doLoadView];
	// Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[[NSNotificationCenter defaultCenter] 
		addObserver: self 
		selector: @selector(connectedToRK) 
		name: @"connectedToRK" object:nil];
		
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(connectedToEndo)
		name : @"connectedToEndo" object: nil];
}

- (void)viewDidUnload
{
	[self setConfigureTable:nil];
	[self setLblCurrentUnits:nil];
	[self setLblRunkeeperStatus:nil];
	[self setImgCircle:nil];
    [self setLblFirstDayOfWeek:nil];
	[self setLblEndomondoStatus:nil];
	[self setLblEndomondoGreen:nil];
	[self setLblNextReminder:nil];
    [self setLblGarminStatus:nil];
    [self setLblGarminGreen:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		switch(indexPath.row) {
		/*
			case 0 : {
				MeIDController * myIdController = (MeIDController *) [self.storyboard instantiateViewControllerWithIdentifier: @"my_nike_plus_id"];
				// customize detail view top bar buttons
				myIdController.sender = self;
				[myIdController configureView];
			
				[self.navigationController presentModalViewController:myIdController animated:YES];
				[self.configureTable reloadData];
				NSLog(@"reloaded");
				 
			}*/
			
			case 0: { // my units
				MyUnitsController * myUnitsController = (MyUnitsController *) [self.storyboard instantiateViewControllerWithIdentifier: @"my_units"];
				myUnitsController.sender = self;
				[self.navigationController presentModalViewController: myUnitsController animated:YES];
				[self.configureTable reloadData];
				[self updateUI];
				break;
				//[self runsLoaded];
				
			}
			
			case 1 : { // firstDayOFWeek
				FirstDayOfWeekViewController * fwController = (FirstDayOfWeekViewController * ) [self.storyboard instantiateViewControllerWithIdentifier: @"firstDayOfWeek"];
				fwController.sender = self;
				[self.navigationController presentModalViewController: fwController animated: YES];
				[self.configureTable reloadData];
				[self updateUI];
				break;
				//[self runsLoaded];

			}
			
			case 2: { // home screen image 
				HomeScreenImageController * hsController = (HomeScreenImageController *) [self.storyboard instantiateViewControllerWithIdentifier: @"homescreenimage"];
				[self.navigationController presentModalViewController: hsController animated:YES];
				[tableView deselectRowAtIndexPath: indexPath animated:YES];
				break;
			
			}
			
			case 3 : { // reminders
				self.remindersController = nil;
				self.remindersController = [[self storyboard] instantiateViewControllerWithIdentifier: @"reminderscontroller"];
				[self.navigationController pushViewController: remindersController animated:YES];
				[tableView deselectRowAtIndexPath: indexPath animated: YES];
				break;
			}
		}
	}
	
	
	// trackers
	if (indexPath.section == 1) { 
		// runkeeper
		if (indexPath.row == 0) {
			RunKeeper * rk = [RunKeeper sharedInstance];
			if ([rk connected]) {
				[rk disconnect];
				[self updateUI];
			}
			else {
				[rk connect];
			}
			
		}
		
		// endomondo
		if (indexPath.row == 1) {
			if (!self.endomondoLogin) {
				self.endomondoLogin = [self.storyboard 
					instantiateViewControllerWithIdentifier: @"endomondologin"];
			}
			[self.navigationController pushViewController: self.endomondoLogin animated: YES];
		}
		
		// garmin
		if (indexPath.row == 2) {
			if (!self.garminlogin) {
				self.garminlogin = [self.storyboard
					instantiateViewControllerWithIdentifier: @"garminlogin"];
				
			}
			[self.navigationController pushViewController: garminlogin animated: YES];
		}
	}
	
	if (indexPath.section == 2) { //  data
		if (indexPath.row == 0) { // delete
			[tableView deselectRowAtIndexPath: indexPath animated:YES];
			UIActionSheet * sheet = [[UIActionSheet alloc]
				initWithTitle: @"Confirm" 
				delegate: self 
				cancelButtonTitle: @"No, don't delete my data" 
				destructiveButtonTitle:@"Yes, delete my data" otherButtonTitles: nil];
			sheet.backgroundColor = [UIColor grayColor];
			sheet.tag = 1;
			[sheet showFromTabBar: self.tabBarController.tabBar];
			//[sheet showInView: self.view];
			/*
			UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: @"Confirm" 
				message: @"Are you sure to delete all your data from this device?" 
				delegate: self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
			alert.tag = 1;	
			[alert show];
			*/
		}
	}
	
	if (indexPath.section == 3) { // visit on the web
		if (indexPath.row == 0) {
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://www.stativity.com"]];
		}
		if (indexPath.row == 1) {
			[[iRate sharedInstance] promptForRating];
		}
	}
	
	[self.tableView deselectRowAtIndexPath: indexPath animated: YES];
}

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 1) {
		if (buttonIndex == 0) {
		
			StativityData * rkd = [StativityData get];
			[self.view setNeedsDisplay];
			[rkd userRemoveAllActivities];
			[self updateUI];
			//[self runsLoaded];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"runsLoaded" object:nil];
		
		}
		
	}
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {  // delete
		if (buttonIndex == 1) {
			StativityData * rkd = [StativityData get];
			alertView.hidden = YES;
			[self.view setNeedsDisplay];
			[rkd userRemoveAllActivities];
			[self updateUI];
			//[self runsLoaded];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"runsLoaded" object:nil];
				
		}
	}
}

// runkeeper delegates
// Connected is called when an existing auth token is found
- (void)connected
{

    //[self updateViews];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected" 
							 message:@"Stativity is linked to your RunKeeper account"
							delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
	
	[self updateUI];
   
	
	self.view.userInteractionEnabled = YES;
}

// Called when the request to connect to runkeeper failed
- (void)connectionFailed:(NSError*)err
{
    //[self updateViews];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" 
                                                     message:@"StatsKeeper is disconnected from your RunKeeper account."
                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
	
	[self updateUI];
	
	NSLog(@"Connection to RunKeeper failed : %@", err);
}


- (IBAction)btnPostClick:(id)sender {

	StativityData * rkd = [[StativityData alloc] init];
	[rkd postActivities];

}



@end
