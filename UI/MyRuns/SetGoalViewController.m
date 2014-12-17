//
//  SetGoalViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 8/21/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "SetGoalViewController.h"
#import "Me.h"
#import <QuartzCore/QuartzCore.h>
#import "StativityData.h"
#import "DistanceGoal.h"

@interface SetGoalViewController ()

@end

@implementation SetGoalViewController

@synthesize tbGoal;
@synthesize lblUnits;
@synthesize lblTitle;
@synthesize activityType;
@synthesize goalTimeFrame;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem * loginButton = 
		[[UIBarButtonItem alloc] 
			initWithTitle:@"Set Goal" 
			style:UIBarButtonItemStyleBordered 
			target:self action:@selector(doSetGoal)];
	self.navigationItem.rightBarButtonItem = loginButton;
	
	self.tbGoal.borderStyle = UITextBorderStyleRoundedRect;
	//self.tbGoal.layer.cornerRadius = 10;
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	if ([self.goalTimeFrame isEqualToString: @"W"]) {
		self.navigationItem.title = @"Weekly Goal";
		self.lblTitle.text = @"My Weekly Distance Goal is";
	}
	if ([self.goalTimeFrame isEqualToString: @"M"]) {
		self.navigationItem.title = @"Monthly Goal";
		self.lblTitle.text = @"My Monthly Distance Goal is";
	}
	if ([self.goalTimeFrame isEqualToString: @"Y"]) {
		self.navigationItem.title = @"Annual Goal";
		self.lblTitle.text = @"My Annual Distance Goal is";
	}
	
	NSString * units = [Me getMyUnits];
	if ([units isEqualToString: @"M"]) {
		self.lblUnits.text = @"miles";
	}
	else {
		self.lblUnits.text = @"km";
	}
	
	if ([self.activityType isEqualToString: @"Cycling"]) {
		self.navigationItem.title = @"Biking";
	}
	else {
		self.navigationItem.title = self.activityType;
	}
	
	StativityData * sd = [StativityData get];
	DistanceGoal * goal = [sd findDistanceGoalForActivity: self.activityType andFrequency: self.goalTimeFrame];
	if ([goal.units isEqualToString: units]) {
		if ([goal.distance floatValue] > 0) {
			tbGoal.text = [goal.distance stringValue];
		}
		else {
			tbGoal.text = @"";
		}
	}
	else { // need to convert 
		if ([goal.units isEqualToString: @"M"]) {
			// converting from M into K
			double kmDistance = [goal.distance doubleValue] * 1.60934;
			if (kmDistance > 0) {
				tbGoal.text = [NSString stringWithFormat: @"%d", (int)round(kmDistance)];
			}
			else {	
				tbGoal.text = @"";
			}
		}
		else {
			// converting from K into M
			double mileDistance = [goal.distance doubleValue] * 0.621371;
			if (mileDistance > 0) {
				tbGoal.text = [NSString stringWithFormat: @"%d", (int)round(mileDistance)];
			}
			else {
				tbGoal.text = @"";
			}
		}
	}
	
	[self.tbGoal becomeFirstResponder];
}

-(void) doSetGoal {
	float dist = [tbGoal.text floatValue];
	NSString * units = [Me getMyUnits];
	NSString * frequency = self.goalTimeFrame;
		
	StativityData * sd = [StativityData get];
	[sd setDistanceGoalForActivity: self.activityType 
		andFrequency: frequency 
		atDistance: [NSNumber numberWithFloat: dist]
		andUnits: units];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"TimeframeChanged" object: nil];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
	[self setTbGoal:nil];
	[self setLblUnits:nil];
	[self setLblTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
