//
//  FirstDayOfWeekViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/9/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "FirstDayOfWeekViewController.h"
#import "Me.h"

@interface FirstDayOfWeekViewController ()

@end

@implementation FirstDayOfWeekViewController

@synthesize myNavigationBar;
@synthesize firstDayTableView;
@synthesize btnDone;
@synthesize sender;


- (IBAction)btnDoneClicked:(id)sender {
	/*
	if (self.sender != nil) {
		[self.sender performSelector: @selector(doLoadView)];
		[self.sender performSelector: @selector(runsLoaded)];
	}
	[self dismissModalViewControllerAnimated:YES];
	[[NSNotificationCenter defaultCenter] 
					postNotificationName:@"runsLoaded" 
					object:nil];
	*/
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"TimeframeChanged" object: nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateUI];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
	[self setMyNavigationBar:nil];
	[self setFirstDayTableView:nil];
	[self setBtnDone:nil];
	[self setMyNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) updateUI {
	UIColor * uiColor = [Me getUIColor];
	[myNavigationBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor],UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor, nil];
	[myNavigationBar setTitleTextAttributes: attributes];	*/
	
	[btnDone setTintColor: uiColor];
	//[btnDone setTitleTextAttributes: attributes forState: UIControlStateNormal];
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
			initWithStyle: UITableViewCellStyleDefault
			reuseIdentifier: CellIdentifier];
	}    
	
	int dow = [Me getFirstDayOfWeek];
	switch(indexPath.row) {
		case 0 : {
			cell.textLabel.text = @"Sunday";
			if (dow == 1) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		}
		
		case 1 : {
			cell.textLabel.text = @"Monday";
			if (dow == 2) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		}
	}
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int clicked = (indexPath.row == 0) ? 1 : 2;
	int current = [Me getFirstDayOfWeek];
	
	if (clicked != current) {
		[Me setFirstDayOfWeek: clicked];
		[self.firstDayTableView reloadData];
		
	}
    
}


@end
