//
//  MyUnitsController.m
//  Stativity
//
//  Created by Igor Nakshin on 6/4/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "MyUnitsController.h"
#import "Me.h"

@interface MyUnitsController ()

@end

@implementation MyUnitsController

@synthesize unitsTableView;
@synthesize myNavigationBar;
@synthesize btnDone;
@synthesize sender;


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
	[self setUnitsTableView:nil];
	[self setMyNavigationBar:nil];
	[self setBtnDone:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneClicked:(id)sender {
	/*
	if (self.sender != nil) {
		//[self.sender performSelector: @selector(doLoadView)];
		[self.sender performSelector: @selector(runsLoaded)];
	}*/
	[[NSNotificationCenter defaultCenter] postNotificationName: @"TimeframeChanged" object: nil];
	[self dismissModalViewControllerAnimated:YES];
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
    static NSString *CellIdentifier = @"myUnitsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc]
			initWithStyle: UITableViewCellStyleDefault
			reuseIdentifier: CellIdentifier];
	}
    // Configure the cell...
	NSString * myUnits = [Me getMyUnits];
	switch(indexPath.row) {
		case 0 : {
			cell.textLabel.text = @"Miles";
			if ([myUnits isEqualToString: @"M"]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		}
		
		case 1 : {
			cell.textLabel.text = @"Kilometers";
			if ([myUnits isEqualToString: @"K"]) {
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * clicked = (indexPath.row == 0) ? @"M" : @"K";
	NSString * current = [Me getMyUnits];
	
	if (clicked != current) {
		[Me setMyUnits: clicked];
		[self.unitsTableView reloadData];
	}
    
}

@end
