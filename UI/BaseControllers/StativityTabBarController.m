//
//  StativityTabBarController.m
//  Stativity
//
//  Created by Igor Nakshin on 01/10/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "StativityTabBarController.h"

@interface StativityTabBarController ()

@end

@implementation StativityTabBarController

-(BOOL) shouldAutorotate {
	BOOL should = NO;
	if (self.selectedViewController) {
		should = [self.selectedViewController shouldAutorotate];
	}
	return should;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (self.selectedViewController) {
		[self.selectedViewController
		willRotateToInterfaceOrientation: toInterfaceOrientation
		duration: duration];
	}
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	BOOL should = (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	if (self.selectedViewController) {
		should = [self.selectedViewController shouldAutorotateToInterfaceOrientation: toInterfaceOrientation];
	}
	return should;
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
