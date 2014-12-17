//
//  MeIDController.m
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "MyNikePlusIDController.h"
#import "Me.h"

@interface MeIDController ()

@end

@implementation MeIDController
@synthesize textBoxID;
@synthesize myNavigationBar;
@synthesize btnCancel;
@synthesize btnSave;
@synthesize sender;

-(void) viewDidLoad {
	// setup UI color
	[self updateUI];	
}

-(void) updateUI {
	UIColor * uiColor = [Me getUIColor];
	[myNavigationBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor],UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor, nil];
	[myNavigationBar setTitleTextAttributes: attributes];	*/
	
	[btnCancel setTintColor: uiColor];
	//[btnCancel setTitleTextAttributes: attributes forState: UIControlStateNormal];
	
	[btnSave setTintColor: uiColor];
	//[btnSave setTitleTextAttributes: attributes forState: UIControlStateNormal];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString * retval = @"";
	if (section == 0) {
		retval = [NSString stringWithFormat : @"Current ID : %@", [Me getMyID]];
	}
	return retval;
	
}

-(void) configureView 
{
	NSString * myID = [Me getMyID];
	if (myID != nil) {
		[self.textBoxID setPlaceholder: @""];
		[self.textBoxID setText: myID];
	}
}

- (IBAction)saveClicked:(id)sender {
	[self saveMyId];
	//[Me loadMyRuns : self.sender];
}

- (IBAction)cancelClicked:(id)sender {
   [self dismissModalViewControllerAnimated:YES];
}


-(void) saveMyId {
	[Me setMyID: self.textBoxID.text];
	[self dismissModalViewControllerAnimated:YES];
}

-(void) runsLoaded {
	[self updateUI];
}

- (void)viewDidUnload
{
	[self setTextBoxID:nil];
	[self setMyNavigationBar:nil];
	[self setBtnCancel:nil];
	[self setBtnSave:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
