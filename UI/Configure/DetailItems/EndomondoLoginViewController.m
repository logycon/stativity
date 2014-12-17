//
//  EndomondoLoginViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 8/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "EndomondoLoginViewController.h"
#import "Endomondo.h"
#import "RunKeeper.h"
#import "Garmin.h"

@interface EndomondoLoginViewController ()

@end

@implementation EndomondoLoginViewController
@synthesize tbEmail;
@synthesize tbPassword;

-(void) loginToEndomondo {
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
		Endomondo * en = [Endomondo sharedInstance];
		NSString * status = [en connectUser : email withPassword : password];
		if ([status isEqualToString: @""]) { // OK
			[[[UIAlertView alloc] initWithTitle: @"Success" message: @"Connected!" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
			
			// disconnect RunKeeper
			RunKeeper * rk = [RunKeeper sharedInstance];
			[rk disconnect];
			
			// diconnect Garmin
			Garmin * garmin = [Garmin sharedInstance];
			[garmin disconnect];
			
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

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.tbPassword) {
        [theTextField resignFirstResponder];
    } else if (theTextField == self.tbEmail) {
        [self.tbPassword becomeFirstResponder];
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	tbPassword.delegate = self;
	tbEmail.delegate = self;
	
	// Do any additional setup after loading the view.
	self.navigationItem.title = @"Endomondo";
	self.navigationItem.backBarButtonItem =
		[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
            style:UIBarButtonItemStyleBordered
			target:nil
			action:nil];
	
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem * loginButton = 
		[[UIBarButtonItem alloc] 
			initWithTitle:@"Connect" 
			style:UIBarButtonItemStyleBordered 
			target:self action:@selector(loginToEndomondo)];
	self.navigationItem.rightBarButtonItem = loginButton;
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
