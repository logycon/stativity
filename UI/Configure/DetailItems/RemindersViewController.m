//
//  RemindersViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 8/23/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "RemindersViewController.h"
#import "Reminder.h"

@interface RemindersViewController ()

@end

@implementation RemindersViewController
@synthesize switchEnabled;
@synthesize tbHours;
@synthesize btnShowSample;
@synthesize lblNextReminder;
@synthesize delegate;

-(BOOL) shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


-(void) viewWillAppear:(BOOL)animated {
	NSNumber * reminderInterval = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_interval"];
	//NSString * reminderBody = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_body"];
	//NSString * reminderTitle = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_title"];
	NSString * reminderEnabled = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_enabled"];

	switchEnabled.on = (reminderEnabled && [reminderEnabled isEqualToString: @"y"]);
	
	NSDate * reminderDate = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_date"];
	if (reminderDate) {
		NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
		[formatter setDateFormat:@"EEEE, MMMM dd yyyy hh:mm:ss a"];
		lblNextReminder.text =[formatter stringFromDate: reminderDate];
	}
	else {
		lblNextReminder.text = @"Never";
	}
	
	if (reminderInterval) {
		tbHours.text = [reminderInterval stringValue];
	}
	else {
		tbHours.text = @"23";
	}
}

-(void) showSampleReminder {
	[Reminder showSample];
}

- (IBAction)btnShowSampleClick:(id)sender {
	[self showSampleReminder];
}

-(void) saveReminders {
	if (switchEnabled.on) {
		[[NSUserDefaults standardUserDefaults] setObject: @"y" forKey: @"reminder_enabled"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject: @"n" forKey: @"reminder_enabled"];
	}
	float hrs = [tbHours.text floatValue];
	[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithFloat: hrs] forKey: @"reminder_interval"];

	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[Reminder updateReminder];
	
	if (delegate) {
		if ([delegate respondsToSelector: @selector(reminderChanged)]) {
			[delegate performSelector: @selector(reminderChanged)];
			
		}
	}
	
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Reminder";
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem * saveButton = 
		[[UIBarButtonItem alloc] 
			initWithTitle:@"Save" 
			style:UIBarButtonItemStyleBordered 
			target:self action:@selector(saveReminders)];
	self.navigationItem.rightBarButtonItem = saveButton;
	
	[self.tbHours setDelegate:self];
	[self.tbHours setKeyboardType: UIKeyboardTypeDecimalPad];
//	[self.tbHours setKeyboardAppearance: UIKeyboardAppearanceAlert];
    [self.tbHours setReturnKeyType:UIReturnKeyDone];
    [self.tbHours addTarget:self
                  action:@selector(textFieldFinished:)
        forControlEvents:UIControlEventEditingDidEndOnExit];
 
}

- (IBAction)textFieldFinished:(id)sender
{
     [sender resignFirstResponder];
}

- (void)viewDidUnload
{
	[self setSwitchEnabled:nil];
	[self setTbHours:nil];
	[self setBtnShowSample:nil];
	[self setLblNextReminder:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	if ([self.tbHours isFirstResponder]) {
		[self.tbHours resignFirstResponder];
	}
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
	 if (indexPath.row == 3) {
		[self showSampleReminder];
	 }
}

@end
