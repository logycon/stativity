//
//  WelcomeViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/15/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"
#import "Me.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

@synthesize appDelegate;
@synthesize navigationBar;


- (IBAction)btnAcceptClick:(id)sender {
	if (appDelegate) {	
		[appDelegate performSelector: @selector(normalLoad)];
	}
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationBar.tintColor = [Me getUIColor];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	[self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
