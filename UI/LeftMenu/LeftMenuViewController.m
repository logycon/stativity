//
//  LeftMenuViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 6/6/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "LeftMenuViewController.h"
#import "IIViewDeckController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "Me.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController


-(void) viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
	[self setMyTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger retval = 0;
	switch(section) {
		case 0 : { retval = 1; break; }
		case 1 : { retval = 5; break; }
		case 2 : { retval = 5; break; }
		case 3 : { retval = 2; break; }
	}
	return retval;
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 0;
	}
	else {
		return 22;
	}
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	int viewHeight = (section == 0) ? 0 : 22;
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width, viewHeight)];
	if (section > 0) {
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];

		headerLabel.textAlignment = UITextAlignmentLeft;
		headerLabel.font = [UIFont fontWithName: [Utilities fontFamily] size:12];
		headerLabel.textColor = [ UIColor colorWithRed:123/255. green: 122/255. blue: 141/255. alpha:1];
		headerLabel.backgroundColor = [UIColor colorWithRed:67/255. green:70/255. blue:90/255. alpha:1];
		
		switch (section) {
			case 0 : { headerLabel.text = @""; break; }
			case 1 : { headerLabel.text = @"   TIME FRAME"; break; }
			case 2 : { headerLabel.text = @"   TIME RANGE"; break; }
			case 3 : { headerLabel.text = @"   UNITS"; break; }
		}
		[headerView addSubview:headerLabel];
	}
	
	return headerView;

}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float retval = 40;
	if ((indexPath.section == 1) && (indexPath.row == 5)) {
		retval = 20;
	}
	return retval;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
			initWithStyle: UITableViewCellStyleDefault 
			reuseIdentifier: CellIdentifier];
			
		//	cell colors
		//cell.backgroundColor = [UIColor colorWithRed:50/250. green:57/250. blue:75/250. alpha:0.75];
	}
	
	UIImageView * imageView = (UIImageView *) [cell viewWithTag:1];
	UILabel * textLabel = (UILabel *) [cell viewWithTag:2];
	
	//textLabel.backgroundColor = [UIColor colorWithRed:54/255. green: 56/255. blue: 74/255. alpha:1];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = [UIColor colorWithRed:191/255. green: 195/255. blue: 211/255. alpha:1];
	
		cell.layer.borderWidth = 0.1;
		//cell.layer.borderColor = textLabel.backgroundColor.CGColor;
		cell.layer.borderColor = [UIColor colorWithRed:41/255. green: 44/255. blue: 56/255. alpha:1].CGColor;;
	
	//textLabel.font = [UIFont boldSystemFontOfSize:16];
	textLabel.font = [UIFont fontWithName: [Utilities fontFamily] size: 16];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSString *cellText = @"";
	
	if (indexPath.section == 0) {
		textLabel.text = @"OPTIONS";
		[imageView setImage: nil];
		//[imageView setImage: [UIImage imageNamed: @"298-circlex-white.png"]];
	}
	
	if (indexPath.section == 1) {
		NSString * curTimeframe = [Me getMyTimeframe];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		BOOL hasCheckMark = NO;
		switch(indexPath.row) {
			case 0 : {
				cellText = @"TODAY";
				if ([curTimeframe isEqualToString: @"T"]) {
					hasCheckMark = YES;
				}				
				break;
			}
			case 1 : {  // W
				cellText = @"THIS WEEK"; 
				if ([curTimeframe isEqualToString: @"W"]) {
					hasCheckMark= YES;
				}
				break; 
			} 
			case 2 : { // M
				cellText = @"THIS MONTH"; 
				if ([curTimeframe isEqualToString: @"M"]) {
					hasCheckMark= YES;
				}
				break;
			}
			case 3 : { // Y
				cellText = @"THIS YEAR";  
				if ([curTimeframe isEqualToString: @"Y"]) {
					hasCheckMark= YES;
				}
				break;

			}  
			case 4 : { // L
				cellText = @"ALL-TIME";  
				if ([curTimeframe isEqualToString: @"L"]) {
					hasCheckMark= YES;
				}
				break;
			}  // L
		}
		
		if (hasCheckMark) {
			[imageView setImage: [UIImage imageNamed: @"258-checkmark-white.png"]];
		}
		else {
			[imageView setImage : nil];
		}
		textLabel.text = cellText;
	} // section 1
			
	if (indexPath.section == 2) {
		NSString * curTimeframe = [Me getMyTimeframe];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		BOOL hasCheckMark = NO;
		switch(indexPath.row) {	
			case 0 : {
				cellText = @"LAST 7 DAYS";
				if ([curTimeframe isEqualToString: @"D7"]) {
					hasCheckMark = YES;
				}
				break;
			}
			
			case 1 : {
				cellText = @"LAST 14 DAYS";
				if ([curTimeframe isEqualToString: @"D14"]) {
					hasCheckMark = YES;
				}
				break;
			}
			
			case 2 : {
				cellText = @"LAST 30 DAYS";
				if ([curTimeframe isEqualToString: @"D30"]) {
					hasCheckMark = YES;
				}
				break;
			}
			
			case 3 : {
				cellText = @"LAST 60 DAYS";
				if ([curTimeframe isEqualToString: @"D60"]) {
					hasCheckMark = YES;
				}
				break;
			}
			
			case 4 : {
				cellText = @"LAST 90 DAYS";
				if ([curTimeframe isEqualToString: @"D90"]) {
					hasCheckMark = YES;
				}
				break;
			}
		}
		
		if (hasCheckMark) {
			[imageView setImage: [UIImage imageNamed: @"258-checkmark-white.png"]];
		}
		else {
			[imageView setImage : nil];
		}
		textLabel.text = cellText;
	} // section 2
	
	if (indexPath.section == 3) {
		NSString * curUnits = [Me getMyUnits];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		BOOL hasCheckMark = NO;
		switch(indexPath.row) {
			case 0 : {
				cellText = @"MILES";
				if ([curUnits isEqualToString: @"M"]) {
					hasCheckMark = YES;
				}
				break;
			}
			case 1 : {
				cellText = @"KM";
				if ([curUnits isEqualToString: @"K"]) {
					hasCheckMark = YES;
				}
				break;
			}
		}
		if (hasCheckMark) {
			[imageView setImage: [UIImage imageNamed: @"258-checkmark-white.png"]];
		}
		else {
			[imageView setImage : nil];
		}
		textLabel.text = cellText;
	} // section 3

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 3) { // UNITS
		UITableViewCell * cell = [tableView cellForRowAtIndexPath: indexPath];
		if (cell != nil) {
			NSString * newUnits = @"";
			switch(indexPath.row) {
				case 0 : { newUnits = @"M"; break; }
				case 1 : { newUnits = @"K"; break; }
			}
			
			UIActivityIndicatorView * __block activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(182,11, 21, 21)];
			//activity.center = CGPointMake(160, 240);
			activity.hidesWhenStopped = YES;
			[self.view addSubview: activity];
			[activity startAnimating];
			
			dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				sleep(1);
				dispatch_async(dispatch_get_main_queue(), ^{
					[Me setMyUnits: newUnits];
					[self.viewDeckController closeLeftViewAnimated: YES];
					[tableView reloadData];
					[activity stopAnimating];
					[activity removeFromSuperview];
					activity = nil;
				});
			});
		}
	}

	if ((indexPath.section == 1) || (indexPath.section == 2)) { // TIME FRAME
		UITableViewCell * cell = [tableView cellForRowAtIndexPath: indexPath];
		if (cell != nil) {
//			UIImageView * imageView = (UIImageView *) [cell viewWithTag:1];
			//UILabel * textLabel = (UILabel *) [cell viewWithTag:2];
			
			NSString * newTimeFrame = @"";
			if (indexPath.section == 1) {
				switch(indexPath.row) {
					case 0 : { newTimeFrame = @"T"; break; }
					case 1 : { newTimeFrame = @"W"; break; }
					case 2 : { newTimeFrame = @"M"; break; }
					case 3 : { newTimeFrame = @"Y"; break; }
					case 4 : { newTimeFrame = @"L"; break; }
				}
			}
			if (indexPath.section == 2) {
				switch(indexPath.row) {
					case 0 : { newTimeFrame = @"D7"; break; }
					case 1 : { newTimeFrame = @"D14"; break; }
					case 2 : { newTimeFrame = @"D30"; break; }
					case 3 : { newTimeFrame = @"D60"; break; }
					case 4 : { newTimeFrame = @"D90"; break; }
				}
			}
			
			//[Me setMyTimeframe: newTimeFrame];
			/*
			
			[self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
				if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
					UITableViewController* cc = (UITableViewController*)((UINavigationController*)controller.centerController).topViewController;
					cc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
					if ([cc respondsToSelector:@selector(tableView)]) {
						[cc.tableView deselectRowAtIndexPath:[cc.tableView indexPathForSelectedRow] animated:NO];    
					}
				}
				//[NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
				[tableView reloadData];
			} completion:^(IIViewDeckController *controller) {
				[Me setMyTimeframe: newTimeFrame];
			}];
			*/
			
			UIActivityIndicatorView * __block activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(182,11, 21, 21)];
			//activity.center = CGPointMake(160, 240);
			activity.hidesWhenStopped = YES;
			[self.view addSubview: activity];
			[activity startAnimating];
			
			dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				sleep(1);
				dispatch_async(dispatch_get_main_queue(), ^{
					[Me setMyTimeframe: newTimeFrame];
					[self.viewDeckController closeLeftViewAnimated: YES];
					[tableView reloadData];
					[activity stopAnimating];
					[activity removeFromSuperview];
					activity = nil;
				});
			});
			
			/*
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
				if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
					UITableViewController* cc = (UITableViewController*)((UINavigationController*)controller.centerController).topViewController;
					cc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
					if ([cc respondsToSelector:@selector(tableView)]) {
						[cc.tableView deselectRowAtIndexPath:[cc.tableView indexPathForSelectedRow] animated:NO];    
					}
				}
				//[NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
				[tableView reloadData];
				//[Me setMyTimeframe: newTimeFrame];
			}];*/
			
			
		}
	}
	else {
		[self.viewDeckController toggleLeftViewAnimated: YES]; // close
	}

}

@end
