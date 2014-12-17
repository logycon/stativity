//
//  GarminLoginViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 9/3/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "GarminLoginViewController.h"
#import "Garmin.h"
#import "Endomondo.h"
#import "RunKeeper.h"

@interface GarminLoginViewController ()

@end

@implementation GarminLoginViewController
@synthesize tbEmail;
@synthesize tbPassword;


-(void) loginToGarmin {
	NSString * email = tbEmail.text;
	NSString * password = tbPassword.text;
	if ([email isEqualToString: @""] || [password isEqualToString: @""]) {
		[[[UIAlertView alloc] 
			initWithTitle: @"Required" 
			message: @"Email and password are required"
			delegate: nil 
			cancelButtonTitle: @"OK" 
			otherButtonTitles: nil] show];
	}
	else {
		Garmin * garmin = [Garmin sharedInstance];
		NSString * status = [garmin connectUser: email withPassword: password];
		if ([status isEqualToString: @""]) {
			[[[UIAlertView alloc] initWithTitle: @"Success" message: @"Connected!" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
			
			// disconnect RunKeeper
			RunKeeper * rk = [RunKeeper sharedInstance];
			[rk disconnect];
			
			// disconnect Endomondo
			Endomondo * en = [Endomondo sharedInstance];
			[en disconnect];
			
			[self.navigationController popViewControllerAnimated: YES];
		}
		else {
			[[[UIAlertView alloc] 
				initWithTitle: @"Error" 
				message: status
				delegate: nil 
				cancelButtonTitle: @"OK" 
				otherButtonTitles: nil] show];
		}
	}
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	tbPassword.delegate = self;
	tbEmail.delegate = self;
	
	self.navigationItem.title = @"Garmin";
	self.navigationItem.backBarButtonItem = 
		[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
			style: UIBarButtonItemStyleBordered
			target: nil
			action: nil];
			
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem * loginButton = 
		[[UIBarButtonItem alloc]
			initWithTitle : @"Connect"
			style : UIBarButtonItemStyleBordered
			target : self
			action : @selector(loginToGarmin)];
	self.navigationItem.rightBarButtonItem = loginButton;
}

-(BOOL) textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == self.tbPassword) {
		[theTextField resignFirstResponder];
	}
	else if (theTextField == self.tbEmail) {
		[self.tbPassword becomeFirstResponder];
	}
	return YES;
}

- (void)viewDidUnload
{
	[self setTbEmail:nil];
	[self setTbPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
