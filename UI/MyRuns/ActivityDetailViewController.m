//
//  ActivityDetailViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/7/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "ActivityDetail.h"
#import "Activity.h"
#import "StativityData.h"
#import "Utilities.h"
#import "Me.h"
#import "HeaderView.h"
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>
#import "Tracker.h"
#import <Social/Social.h>
#import "TrainingPeaksExporter.h"

@interface ActivityDetailViewController ()

@property (nonatomic, strong) NSString * slowestMile;
@property (nonatomic, strong) NSString * fastestMile;
@property (nonatomic, strong) NSString * slowestKm;
@property (nonatomic, strong) NSString * fastestKm;

@end

@implementation ActivityDetailViewController

MKPolyline * route;
MKMapRect routeRect;

@synthesize activityDetail;
@synthesize detailScrollView = _detailScrollView;
@synthesize detailMap = _detailMap;
@synthesize lblDistance = _lblDistance;
@synthesize lblPace = _lblPace;
@synthesize lblSpeed = _lblSpeed;
@synthesize lblUnits = _lblUnits;
@synthesize lblWhen = _lblWhen;
@synthesize detailTable = _detailTable;
@synthesize lblTotalTime = _lblTotalTime;
@synthesize lblCalories = _lblCalories;
@synthesize imgSource = _imgSource;
@synthesize viewMode = _viewMode;
@synthesize activity = _activity;
@synthesize distances;
@synthesize miles;
@synthesize kms;
@synthesize slowestKm;
@synthesize slowestMile;
@synthesize fastestKm;
@synthesize fastestMile;

- (IBAction)btnDoneClicked:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


-(void) setActivity:(Activity *)activity {
	[self.detailMap removeOverlays: self.detailMap.overlays];
	self.detailMap.delegate = self;
	_activity = activity;
	StativityData * rkd = [StativityData get];
	self.activityDetail = [rkd fetchActivityDetail: _activity.id];
	//NSArray * segments = [rkd fetchSegments: _activity.id]; 
	self.miles = [rkd fetchSegments: _activity.id ofUnit: @"m"];
	self.kms = [rkd fetchSegments: _activity.id ofUnit: @"k"];
	
	float slowest = -9999999;
	float fastest =  9999999;
	for(int i = 0; i < [self.miles count]; i++) {
		ActivitySegment * seg = [self.miles objectAtIndex: i];
		if ([seg.segmentSeconds floatValue] >= slowest) {
			slowest = [seg.segmentSeconds floatValue];
		}
		if ([seg.segmentSeconds floatValue] <= fastest) {
			fastest = [seg.segmentSeconds floatValue];
		}
	}
	self.slowestMile = [Utilities getSecondsAsDurationShort: slowest];
	self.fastestMile = [Utilities getSecondsAsDurationShort: fastest];
	
	slowest = -9999999;
	fastest =  9999999;
	for(int i = 0; i < [self.kms count]; i++) {
		ActivitySegment * seg = [self.kms objectAtIndex: i];
		if ([seg.segmentSeconds floatValue] >= slowest) {
			slowest = [seg.segmentSeconds floatValue];
		}
		if ([seg.segmentSeconds floatValue] <= fastest) {
			fastest = [seg.segmentSeconds floatValue];
		}
	}
	self.slowestKm = [Utilities getSecondsAsDurationShort: slowest];
	self.fastestKm = [Utilities getSecondsAsDurationShort: fastest];
	
	
	self.viewMode.selectedSegmentIndex = 0;
	
	if ([self.activityDetail count] == 0) {
		self.viewMode.hidden = YES;
		self.detailMap.hidden = YES;
		self.detailTable.hidden = YES;
	}
	else {
		self.viewMode.hidden = NO;
		self.detailMap.hidden = NO;
		self.detailTable.hidden = NO;
	}
	
	
}

-(void) runsLoaded {
	[self displayDetail];
}

-(void) displayDetail {
	[self displayActivity];
	if ([self.activityDetail count] > 0) {
		[self setupDetail];
		[self.detailTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
	}
}

-(void) awakeFromNib {
	self.detailMap.delegate = self;
	[self.viewMode setTintColor: [Me getUIColorWithAlpha: 0.50]];
	
	[self.detailMap setBounds: [self getDetailBounds]];
	[self.detailTable setBounds: [self getDetailBounds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.detailMap.delegate = self;
	self.detailTable.delegate = self;
	self.detailTable.dataSource = self;
	[self.viewMode setTintColor: [Me getUIColorWithAlpha: 0.50]];
	
	self.navigationItem.rightBarButtonItem = 
		[[UIBarButtonItem alloc]
			initWithBarButtonSystemItem: UIBarButtonSystemItemAction 
			target: self action: @selector(actionClick)];
}

-(void) actionClick {
	UIActionSheet * actionSheet;
	
	if ([Utilities isSocialAvailable]) {
		actionSheet = [[UIActionSheet alloc]
			initWithTitle: @"Actions" 
			delegate:self 
			cancelButtonTitle: @"Close" 
			destructiveButtonTitle: nil 
			otherButtonTitles: 
				@"Take Screen Shot",
				@"Tweet",
				@"Facebook",
				@"Copy",
				@"Send to TrainingPeaks",
				nil];
	}
	else {
		actionSheet = [[UIActionSheet alloc]
			initWithTitle: @"Actions" 
			delegate:self 
			cancelButtonTitle: @"Close" 
			destructiveButtonTitle: nil 
			otherButtonTitles: 
				@"Take Screen Shot",
				@"Tweet",
				@"Copy",
				@"Send to TrainingPeaks",
				nil];
	}
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.alpha = 0.85;
	[actionSheet showFromTabBar: self.tabBarController.tabBar];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([Utilities isSocialAvailable]) {
		if (buttonIndex == 0) {
			[self takeScreenShot];
		}
		if (buttonIndex == 1) { // tweet
			[self tweet];
		}
		if (buttonIndex == 2) { // facebook
			[self facebook];
		}
		
		if (buttonIndex == 3) { // copy
			[self copyToPasteBoard];
		}
		
		if (buttonIndex == 4) {
			[self sendToTrainingPeaks];
		}
	}
	else {
		if (buttonIndex == 0) {
			[self takeScreenShot];
		}
		if (buttonIndex == 1) { // tweet
			[self tweet];
		}
		
		if (buttonIndex == 2) { // copy
			[self copyToPasteBoard];
		}
		
		if (buttonIndex == 3) {
			[self sendToTrainingPeaks];
		}
	}
}

-(void) sendToTrainingPeaks {
	[[[TrainingPeaksExporter alloc] init] sendActivityWithID: self.activity.id];
}

-(void) takeScreenShot {
	UIGraphicsBeginImageContext(self.view.frame.size);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
	[[[UIAlertView alloc] 
		initWithTitle: @"Done" 
		message: @"Screen Shot was added to your Photo Library." 
		delegate: nil 
		cancelButtonTitle: @"OK" 
		otherButtonTitles: nil] 
	show];
}

-(void) copyToPasteBoard {
	NSString * action = @"";
	if ([self.activity.type isEqualToString: @"Running"]) {
		action = @"ran";
	}
	if ([self.activity.type isEqualToString: @"Cycling"]) {
		action = @"biked";
	}
	if ([self.activity.type isEqualToString: @"Walking"]) {
		action = @"walked";
	}
	
	NSString * tweetText = @"";
	ActivityFormatter * fmt = [ActivityFormatter initWithRun: self.activity];
	tweetText = [tweetText stringByAppendingFormat: @"%@ ", [fmt getWhenFormattedShort]];
	tweetText = [tweetText stringByAppendingFormat: @"%@ ", action];
	tweetText = [tweetText stringByAppendingFormat: @"%@ ", [fmt getDistanceFormattedShort]];
	tweetText = [tweetText stringByAppendingFormat: @"with avg pace of %@ ", [fmt getPaceFormatted]];
	tweetText = [tweetText stringByAppendingFormat: @"with %@ via @Stativity", [Tracker getTrackerHashTag]];
	
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString: tweetText];
	
	[[[UIAlertView alloc] 
		initWithTitle: @"Done" message: 
		[NSString stringWithFormat: @"\"%@\" has been copied to PasteBoard", tweetText]
		delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
}

-(void) facebook {
	if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		
		NSString * action = @"";
			if ([self.activity.type isEqualToString: @"Running"]) {
				action = @"ran";
			}
			if ([self.activity.type isEqualToString: @"Cycling"]) {
				action = @"biked";
			}
			if ([self.activity.type isEqualToString: @"Walking"]) {
				action = @"walked";
			}

			
			NSString * tweetText = @"";
			ActivityFormatter * fmt = [ActivityFormatter initWithRun: self.activity];
			tweetText = [tweetText stringByAppendingFormat: @"%@ ", [fmt getWhenFormattedShort]];
			tweetText = [tweetText stringByAppendingFormat: @"%@ ", action];
			tweetText = [tweetText stringByAppendingFormat: @"%@ ", [fmt getDistanceFormattedShort]];
			tweetText = [tweetText stringByAppendingFormat: @"with avg pace of %@", [fmt getPaceFormatted]];
			
		
			[mySLComposerSheet setInitialText:
				[tweetText stringByAppendingFormat : @" with %@ via @Stativity", [Tracker getTrackerHashTag]]];
			[self presentViewController:mySLComposerSheet animated:YES completion:nil];
    
			[mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
			NSString *output = @"";
			switch (result) {
				case SLComposeViewControllerResultCancelled:
					//output = @"Action Cancelled";
					break;
				case SLComposeViewControllerResultDone:
					output = @"Post Successfull";
					break;
				default:
					break;
			}
			if (![output isEqualToString: @""]) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			}
		}];
	}
	else {
		[[[UIAlertView alloc]
			initWithTitle: @"Unavailable"
			message: @"Facebook requires iOS6 and must be configured on the device."
			delegate: nil
			cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
	}
}

-(void) tweet {

	if ([TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController * twitter = 
			[[TWTweetComposeViewController alloc] init];
			
			NSString * action = @"";
			if ([self.activity.type isEqualToString: @"Running"]) {
				action = @"ran";
			}
			if ([self.activity.type isEqualToString: @"Cycling"]) {
				action = @"biked";
			}
			if ([self.activity.type isEqualToString: @"Walking"]) {
				action = @"walked";
			}

			
			NSString * tweetText = @"";
			ActivityFormatter * fmt = [ActivityFormatter initWithRun: self.activity];
			tweetText = [tweetText stringByAppendingFormat: @"%@ ", [fmt getWhenFormattedShort]];
			tweetText = [tweetText stringByAppendingFormat: @"%@ ", action];
			tweetText = [tweetText stringByAppendingFormat: @"%@ ", [fmt getDistanceFormattedShort]];
			tweetText = [tweetText stringByAppendingFormat: @"with avg pace of %@", [fmt getPaceFormatted]];
			
			[twitter setInitialText: [tweetText stringByAppendingFormat: @" with %@ via @Stativity", [Tracker getTrackerHashTag]]];
	
			twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
				if (res == TWTweetComposeViewControllerResultDone) {
					[[[UIAlertView alloc]
						initWithTitle: @"Tweet Posted" 
						message: @"Your message has been posted." 
						delegate:nil 
						cancelButtonTitle: @"OK" 
						otherButtonTitles: nil] show];
				}
				else {
				/*
					[[[UIAlertView alloc]
						initWithTitle: @"Tweet Failed" 
						message: @"Post to Twitter failed." 
						delegate:nil 
						cancelButtonTitle: @"OK" 
						otherButtonTitles: nil] show];*/
				}
				
				[self dismissModalViewControllerAnimated: YES];
			};
							
			[self presentModalViewController: twitter animated: YES];
	}
	else {
		[[[UIAlertView alloc] 
			initWithTitle: @"Twitter not available"
			message:@"Please make sure Twitter is configured on your device."
			delegate: nil cancelButtonTitle: @"OK" 
			otherButtonTitles: nil] show];
	}
}


-(CGRect) getDetailBounds {
	CGRect retval = CGRectMake(0, 460, 320, 317);
	return retval;
}

- (IBAction)viewModeChanged:(id)sender {
	[self setupDetail];
}

-(void) setupDetail {
	self.detailMap.hidden = YES;
	self.detailTable.hidden = YES;
	int vMode = self.viewMode.selectedSegmentIndex;
	switch(vMode) {
		case 0 : { // map
			//CGRect bounds = [self getDetailBounds];
			self.detailMap.hidden = NO;
			[self displayMap];
			break;
		}
		
		case 1 : { // segments
			self.detailTable.hidden = NO;
			[self displaySegments];
			break;
		}
			
	}
}

-(void) displayActivity {

	//self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"63-white-runner.png"]];;
	self.navigationItem.title = self.activity.type;
	self.lblWhen.textColor = [UIColor whiteColor];
	self.lblDistance.font = [UIFont fontWithName: [Utilities fontFamily] size:35];
	self.lblDistance.textColor = [UIColor whiteColor];
	self.lblPace.font = [UIFont fontWithName: [Utilities fontFamily] size:15];
	self.lblPace.textColor = [UIColor whiteColor];
	self.lblSpeed.font = [UIFont fontWithName: [Utilities fontFamily] size:15];
	self.lblSpeed.textColor = [UIColor whiteColor];
	self.lblUnits.font = [UIFont fontWithName: [Utilities fontFamily] size:14];
	self.lblUnits.textColor = [UIColor whiteColor];
	self.lblWhen.font = [UIFont fontWithName: [Utilities fontFamily] size:12];
	self.lblTotalTime.font = [UIFont fontWithName: [Utilities fontFamily] size:14];
	self.lblCalories.font = [UIFont fontWithName: [Utilities fontFamily] size:14];
	self.lblHeartRate.font = [UIFont fontWithName: [Utilities fontFamily] size: 10];
	
	NSNumber * distanceInUnits = [self.activity getDistanceInUnits];
	self.lblDistance.text = [NSString 
		stringWithFormat: @"%.2f", 
		[distanceInUnits floatValue]
	];
	NSString * units = [Me getMyUnits];
	if ([units isEqualToString: @"M"]) {
		self.lblUnits.text = @"mi";
	}
	else {
		self.lblUnits.text = @"km";
	}
	self.lblPace.text = [self.activity getPaceFormatted];
	self.lblSpeed.text = [self.activity getSpeedFormatted];
	self.lblWhen.text = [self.activity getWhenFormatted];
	self.lblTotalTime.text = [Utilities getSecondsAsDuration: [self.activity.duration floatValue]];
	self.lblCalories.text = [NSString stringWithFormat: @"%d calories", [self.activity.total_calories intValue]];
	
	if (!self.activity.source || [self.activity.source isEqualToString: @"RunKeeper"] || [self.activity.source isEqualToString: @""]) {
		[self.imgSource setImage: [UIImage imageNamed: @"icon_runkeeper.png"]];
	}
	else {
		if ([self.activity.source isEqualToString: @"Endomondo"]) {
			[self.imgSource setImage: [UIImage imageNamed : @"icon_endomondo.png"]];
		}
	}
	
	int heartRate = [self.activity.heartRate intValue];
	if (heartRate > 0) {
		self.lblHeartRate.hidden = NO;
		self.imgHeartRate.hidden = NO;
		self.lblHeartRate.text = [NSString stringWithFormat: @"%i", heartRate];
		self.lblHeartRate.textColor = [UIColor whiteColor];
		self.lblHeartRate.backgroundColor =[UIColor clearColor];
	}
	else {
		self.lblHeartRate.hidden = YES;
		self.imgHeartRate.hidden = YES;
	}
	  
	[self setupDetail];
}

-(void) displayMap {
	MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
	
	MKMapPoint * points = malloc(sizeof(CLLocationCoordinate2D) * [self.activityDetail count]);
	for(int i = 0; i < [self.activityDetail count]; i++) {
		ActivityDetail * det = [self.activityDetail objectAtIndex: i];
		
		CLLocationDegrees lat = [det.latitude doubleValue];
		CLLocationDegrees lng = [det.longitude doubleValue];
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake( lat, lng );
		MKMapPoint point = MKMapPointForCoordinate( coord );
		if (i == 0) {
			northEastPoint = point;
			southWestPoint = point;
		}
		else {
			if (point.x > northEastPoint.x) northEastPoint.x = point.x;
			if (point.y > northEastPoint.y) northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) southWestPoint.y = point.y;
		}
		points[i] = point;
	}
	
	route = [MKPolyline polylineWithPoints: points count: [self.activityDetail count]];
	[self.detailMap addOverlay: route];

	routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
	[self.detailMap setVisibleMapRect: [route boundingMapRect]];
}

// mapview delegate
-(MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
	MKPolylineView * overlayView = nil;
	//if (overlay == route) {
		overlayView = [[MKPolylineView alloc] initWithPolyline: route];
		overlayView.fillColor = [UIColor redColor];
		overlayView.strokeColor = [UIColor redColor];
		overlayView.lineWidth = 3;
	//}
	return overlayView;
}

- (void)viewDidUnload
{
	[self setDetailScrollView:nil];
	[self setDetailMap:nil];
	[self setLblDistance:nil];
	[self setLblPace:nil];
	[self setLblSpeed:nil];
	[self setLblUnits:nil];
	[self setLblWhen:nil];
	[self setDetailTable:nil];
	[self setLblTotalTime:nil];
    [self setLblCalories:nil];
	[self setImgSource:nil];
	[self setImgHeartRate:nil];
	[self setLblHeartRate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) displaySegments {
	[self.detailTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString * units = [[Me getMyUnits] lowercaseString];
	if ([units isEqualToString: @"m"]) {
		if (section == 0) {
			return [self.miles count];
		}
		else {
			return [self.kms count];
		}
	}
	else {
		if (section == 0) {
			return [self.kms count];
		}
		else {	
			return [self.miles count];
		}
	}
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString * units = [[Me getMyUnits] lowercaseString];
	if ([units isEqualToString: @"m"]) {
		if (section == 0) {
			return @"MILES";
		}
		else {
			return @"KILOMETERS";
		}
	}
	else {
		if (section == 0) {
			return @"KILOMETERS";
		}
		else {	
			return @"MILES";
		}
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	//return 22;
	return 26;
}


-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString * text = @"";
	
	NSString * units = [[Me getMyUnits] lowercaseString];
	if ([units isEqualToString: @"m"]) {
		if (section == 0) {
			text= @"MILES";
		}
		else {
			text= @"KILOMETERS";
		}
	}
	else {
		if (section == 0) {
			text= @"KILOMETERS";
		}
		else {	
			text= @"MILES";
		}
	}


	return [[HeaderView alloc] 
		initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 26)
		andText : text
		andRightText: @""
	];

}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * CellIndentifier = @"segmentCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
	}
	
	ActivitySegment * dist = nil;
	
	NSString * slowest = @"";
	NSString * fastest = @"";
	NSString * units = [[Me getMyUnits] lowercaseString];
	if ([units isEqualToString: @"m"]) {
		if (indexPath.section == 0) {
			dist = [self.miles objectAtIndex: indexPath.row];
			slowest = self.slowestMile;
			fastest = self.fastestMile;
		}
		else {
			dist = [self.kms objectAtIndex: indexPath.row];
			slowest = self.slowestKm;
			fastest = self.fastestKm;
		}
	}
	else {
		if (indexPath.section == 0) {
			dist = [self.kms objectAtIndex: indexPath.row];
			slowest = self.slowestKm;
			fastest = self.fastestKm;
		}
		else {	
			dist = [self.miles objectAtIndex: indexPath.row];
			slowest = self.slowestMile;
			fastest = self.fastestMile;
		}
	}
	
	UILabel * lblDistance = (UILabel *) [cell viewWithTag: 1];
	UILabel * lblTime = (UILabel *) [cell viewWithTag: 2];
	UILabel * lblSegmentTime = (UILabel *) [cell viewWithTag: 3];
	UILabel * lblDelta = (UILabel *) [cell viewWithTag: 4];
	UIImageView * imgSpeed = (UIImageView *) [cell viewWithTag: 5];
	UIImageView * imgHeartRate = (UIImageView *) [cell viewWithTag: 6];
	UILabel * lblHeartRate = (UILabel *) [cell viewWithTag: 7];
	
	int heartRate = [dist.heartRate intValue];
	if (heartRate > 0) {
		imgHeartRate.hidden = NO;
		lblHeartRate.hidden = NO;
		lblHeartRate.textColor = [UIColor whiteColor];
		lblHeartRate.backgroundColor = [UIColor clearColor];
		lblHeartRate.text = [NSString stringWithFormat: @"%i", heartRate];
	}
	else {
		imgHeartRate.hidden = YES;
		lblHeartRate.hidden = YES;
	}
	
	NSString * fontFamily = [Utilities fontFamily];
	
	if ([dist.units isEqualToString: units]) {
		cell.contentView.backgroundColor = [UIColor colorWithRed:245/256. green:245/256. blue:245/256. alpha:1];
	}
	else {
		fontFamily = [Utilities fontFamilyRegular];
		cell.contentView.backgroundColor = [UIColor whiteColor];
	}
	
	lblDistance.font = [UIFont fontWithName: fontFamily size:14];
	lblTime.font = [UIFont fontWithName: fontFamily size:14];
	lblSegmentTime.font = [UIFont fontWithName: fontFamily size:14];
	lblDelta.font = [UIFont fontWithName: fontFamily size:14];

	NSNumberFormatter * fmt = [[NSNumberFormatter alloc] init];
	fmt.numberStyle = NSNumberFormatterPercentStyle;
	//NSString * pct = [fmt stringFromNumber: dist.elevationChange];
	
	lblDistance.text = [NSString stringWithFormat: @"%@", dist.title];
	
	//lblDistance.text = [NSString stringWithFormat : @"%@", dist.meters];
	
	lblTime.text = [Utilities getSecondsAsDurationShort: [dist.seconds floatValue]];
	
	imgSpeed.hidden = YES;
	if (dist.segmentSeconds != 0) {
		lblSegmentTime.text = [Utilities getSecondsAsDurationShort: [dist.segmentSeconds floatValue]];
		
		if ([lblSegmentTime.text isEqualToString: slowest]) {
			imgSpeed.hidden = NO;
			[imgSpeed setImage: [UIImage imageNamed: @"turtle.png"]];
		}
		if ([lblSegmentTime.text isEqualToString: fastest]) {
			imgSpeed.hidden = NO;
			[imgSpeed setImage: [UIImage imageNamed: @"rabbit.png"]];
			//NSLog(@"%@", lblTime.text);
		}
	}
	else {
		lblSegmentTime.text = @"";
		
	}
	
	if (dist.delta) {
		float deltaSeconds = [dist.delta floatValue];
		if (deltaSeconds > 0) { // increase is bad
			lblDelta.text = [NSString stringWithFormat : @"+%@", [Utilities getSecondsAsDurationShort: [dist.delta floatValue]]];
			lblDelta.textColor = [UIColor redColor];
		}
		else { // decrease is good
			lblDelta.textColor = [UIColor colorWithRed: 0 green: 100/256. blue:0 alpha:1]; // dark green
			lblDelta.text = [NSString stringWithFormat : @"-%@", [Utilities getSecondsAsDurationShort: abs(deltaSeconds)]];
		}
	}
	else {
		lblDelta.text = @"";
	}
	
	return cell;

}

@end
