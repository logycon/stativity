//
//  StativityNavigationController.m
//  Stativity
//
//  Created by Igor Nakshin on 01/10/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "StativityNavigationController.h"

@interface StativityNavigationController ()

@end

@implementation StativityNavigationController

-(BOOL) shouldAutorotate {
	BOOL should = NO;
	if (self.topViewController) {
		should = [self.topViewController shouldAutorotate];
	}
	return should;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (self.topViewController) {
		[self.topViewController
		willRotateToInterfaceOrientation: toInterfaceOrientation
		duration: duration];
	}
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	BOOL should = NO;
	if (self.topViewController) {
		should = [self.topViewController
			shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
	}
	return should;
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
