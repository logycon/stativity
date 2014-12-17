//
//  DashboardItemFormatter.m
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "DashboardItemFormatter.h"
#import "DashboardItem.h"
#import "Activity.h"
#import "ActivitySegment.h"
#import "StativityData.h"
#import "Utilities.h"
#import "Me.h"

@implementation DashboardItemFormatter

@synthesize activityType;
@synthesize displayName;
@synthesize itemCategory;
@synthesize itemCode;
@synthesize itemOrder;
@synthesize userSelected;
@synthesize defaultOrder;
@synthesize periodActivity;
@synthesize allTimeActivity;

-(NSString *) description {
	return [NSString stringWithFormat: @"%@ : %@ - %@", defaultOrder, activityType, displayName];
}

// d_longest - Longest activity (distance)
// d_longestweek - Longest week (distance)
// d_longestmonth - Longest month (distance)
// t_longest - Longest activity (time)
// s_1k - fastest 1k (speed)
// s_1m - fastest 1m
// s_5k - fastest 5k
// s_3m - fastest 3m
// s_5m - fastest 5m
// s_10k - fastest 10k
// s_10m - fastest 10m
// s_h - fastest half
// s_f - fastest full 

+(NSArray *) getDefaultItems {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	return [retval copy];
}
	
-(DashboardItemFormatter *) initWithItem:(DashboardItem *)item {
	self.activityType = item.activityType;
	self.displayName = item.displayName;
	self.itemCategory = item.itemCategory;
	self.itemCode = item.itemCode;
	self.itemOrder = item.itemOrder;
	self.userSelected = item.userSelected;
	self.defaultOrder = item.defaultOrder;
	return self;
}


+(NSArray *)createItems {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	
	NSArray * activityTypes = [[NSArray alloc] initWithObjects: @"Running", @"Cycling", @"Walking", nil];
	NSArray * activityActions = [[NSArray alloc] initWithObjects: @"Run", @"Ride", @"Walk", nil];
	DashboardItemFormatter * fmt = nil;
	int groupIndex = 0;
	// d_farthest - Farthest activity (distance)
	for(int i = 0; i < [activityTypes count]; i++) {
		NSString * activityType = [activityTypes objectAtIndex: i];
		NSString * activityAction = [activityActions objectAtIndex: i];
		fmt = [[DashboardItemFormatter alloc] init];
		fmt.activityType = activityType;
		fmt.displayName = [NSString stringWithFormat: @"Farthest %@", activityAction];
		fmt.itemCategory = @"Distance";
		// d_farthest_run, d_farthest_ride, d_farthest_walk
		fmt.itemCode = @"d_farthest"; //[NSString stringWithFormat: @"d_farthest_%@", [activityAction lowercaseString]]; 
		fmt.itemOrder = [NSNumber numberWithInt: 100000000];
		fmt.userSelected = [NSNumber numberWithBool: NO];
		fmt.defaultOrder = [NSNumber numberWithInt: groupIndex * i + 1];
		[retval addObject: fmt];
	}
	
	// t_longest - (duration)
	groupIndex =0;
	for(int i = 0; i < [activityTypes count]; i++) {
		NSString * activityType = [activityTypes objectAtIndex: i];
		NSString * activityAction = [activityActions objectAtIndex: i];
		fmt = [[DashboardItemFormatter alloc] init];
		fmt.activityType = activityType;
		fmt.displayName = [NSString stringWithFormat: @"Longest %@", activityAction];
		fmt.itemCategory = @"Duration";
		// d_farthest_run, d_farthest_ride, d_farthest_walk
		fmt.itemCode = @"t_longest"; //[NSString stringWithFormat: @"t_longest"]; 
		fmt.itemOrder = [NSNumber numberWithInt: 100000001];
		fmt.userSelected = [NSNumber numberWithBool: NO];
		fmt.defaultOrder = [NSNumber numberWithInt: groupIndex * i + 1];
		[retval addObject: fmt];
	}

	// s_1k - fastest 1k (speed)
	// s_1m - fastest 1m
	// s_5k - fastest 5k
	// s_3m - fastest 3m
	// s_5m - fastest 5m
	// s_10k - fastest 10k
	// s_10m - fastest 10m
	// s_h - fastest half
	// s_f - fastest full 
	
	groupIndex = 2;
	NSArray * distances = [[NSArray alloc] 
		initWithObjects: @"1K", @"1M", @"3M", @"5K", @"5M", @"10K", @"15K", @"10M", @"20K", @"30K", @"40K", @"50K", nil];
	NSArray * meters = [[NSArray alloc]
		initWithObjects: 
		[NSNumber numberWithFloat: 1000],
		[NSNumber numberWithFloat: 1600],
		[NSNumber numberWithFloat: 3000],
		[NSNumber numberWithFloat: 5000],
		[NSNumber numberWithFloat: 8046],
		[NSNumber numberWithFloat: 10000],
		[NSNumber numberWithFloat: 15000],
		[NSNumber numberWithFloat: 16093],
		[NSNumber numberWithFloat: 20000],
		[NSNumber numberWithFloat: 30000],
		[NSNumber numberWithFloat: 40000],
		[NSNumber numberWithFloat: 50000],
		nil];
	for(int i = 0; i < [activityTypes count]; i++) {
		NSString * activityType = [activityTypes objectAtIndex: i];
		for(int j = 0; j < [distances count]; j++) {
			NSString * distance = [distances objectAtIndex: j];
			NSNumber * dist = [meters objectAtIndex: j];
			fmt = [[DashboardItemFormatter alloc] init];
			fmt.activityType = activityType;
			fmt.displayName = [NSString stringWithFormat: @"Best %@", distance];
			fmt.itemCategory = @"Speed";
			fmt.itemCode = [NSString stringWithFormat: @"s_%@", [distance lowercaseString]];
			fmt.itemOrder = [NSNumber numberWithInt: 0];
			fmt.userSelected = [NSNumber numberWithBool: NO];
			fmt.defaultOrder = [NSNumber numberWithInt: [dist intValue]];
			[retval addObject: fmt];
		}
		
		// add HALF and FULL for running
		if ([activityType isEqualToString: @"Running"]) {
			fmt = [[DashboardItemFormatter alloc] init];
			fmt.activityType = activityType;
			fmt.displayName = @"Best Half-Marathon";
			fmt.itemCategory = @"Speed";
			fmt.itemCode = @"s_half";
			fmt.itemOrder = [NSNumber numberWithInt: 0];
			fmt.userSelected = [NSNumber numberWithBool: NO];
			fmt.defaultOrder = [NSNumber numberWithInt: 21097];
			[retval addObject: fmt];
			
			fmt = [[DashboardItemFormatter alloc] init];
			fmt.activityType = activityType;
			fmt.displayName = @"Best Marathon";
			fmt.itemCategory = @"Speed";
			fmt.itemCode = @"s_full";
			fmt.itemOrder = [NSNumber numberWithInt: 0];
			fmt.userSelected = [NSNumber numberWithBool: NO];
			fmt.defaultOrder = [NSNumber numberWithInt: 42194];
			[retval addObject: fmt];
		}
	}
	return [retval copy];
}

-(void) loadForPeriod:(NSDate *)starting andEnding:(NSDate *)ending {
	//NSLog(@"Loading %@ - %@", self.itemCode, self.displayName);
	
	self.periodActivity = nil;
	self.allTimeActivity = nil;
	
	if ([self.itemCategory isEqualToString: @"Distance"]) {
		if ([self.itemCode isEqualToString: @"d_farthest"]) {
			StativityData * rkd = [StativityData get];
			Activity * act = [rkd getFarthestActivityBetweenStartDate: starting andEndDate: ending ofType: self.activityType];
			Activity * act1 = [rkd getFarthestActivityOfType: self.activityType];
			self.periodActivity = [ActivityFormatter initWithRun: act];
			self.allTimeActivity = [ActivityFormatter initWithRun: act1];
		}
	}
	
	if ([self.itemCategory isEqualToString: @"Duration"]) {
		if ([self.itemCode isEqualToString: @"t_longest"]) {
			StativityData * rkd = [StativityData get];
			Activity * act = [rkd getLongestActivityBetweenStartDate: starting andEndDate: ending ofType: self.activityType];
			Activity * act1 = [rkd getLongestActivityOfType : self.activityType];
			self.periodActivity = [ActivityFormatter initWithRun: act];
			self.allTimeActivity = [ActivityFormatter initWithRun: act1];
		
		}
	}
	
	if ([self.itemCategory isEqualToString: @"Speed"]) {
		if ([self.itemCode isEqualToString: @"s_1k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"1" andUnits: @"k"];
				
			//seg1.seconds = seg1.segmentSeconds;
			
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"1" andUnits: @"k"];
			
			//seg2.seconds = seg2.segmentSeconds;
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_1m"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"1" andUnits: @"m"];
				
			//seg1.seconds = seg1.segmentSeconds;
			
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"1" andUnits: @"m"];
				
			//seg2.seconds = seg2.segmentSeconds;
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_3m"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"3" andUnits: @"m"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"3" andUnits: @"m"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_5k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"5" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"5" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_5m"]) {
			StativityData * rkd = [StativityData get];
			
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"5" andUnits: @"m"];
				
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"5" andUnits: @"m"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}

		if ([self.itemCode isEqualToString: @"s_10k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"10" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"10" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}

		if ([self.itemCode isEqualToString: @"s_15k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"15" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"15" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_10m"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"10" andUnits: @"m"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"10" andUnits: @"m"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_20k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"20" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"20" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_half"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"half" andUnits: @"half"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"half" andUnits: @"half"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
		
		if ([self.itemCode isEqualToString: @"s_30k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"30" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"30" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}


		if ([self.itemCode isEqualToString: @"s_40k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"40" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"40" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}

		if ([self.itemCode isEqualToString: @"s_full"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"full" andUnits: @"full"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"full" andUnits: @"full"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}

		if ([self.itemCode isEqualToString: @"s_50k"]) {
			StativityData * rkd = [StativityData get];
			ActivitySegment * seg1 = [rkd
				getFastestSegmentBetweenStartDate: starting andEndDate:ending ofType: self.activityType 
				withTitle: @"50" andUnits: @"k"];
			ActivitySegment * seg2 = [rkd
				getFastestSegmentOfType: self.activityType 
				withTitle: @"50" andUnits: @"k"];
			
			self.periodActivity = [ActivityFormatter initWithSegment: seg1];
			self.allTimeActivity = [ActivityFormatter initWithSegment: seg2];
		}
	}
}

-(NSString *) getPeriodSpeed {
	@try {
		NSString * retval = @"";
		float theSpeed = 0;
		double denominator = 0;
		double numerator = 0;
		
		if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
			denominator = [self.periodActivity.segmentDuration floatValue] / (60.0 * 60.0); // duration is in seconds
			numerator = 1;
			if ([self.itemCode isEqualToString: @"s_1k"]) {
				if ([[Me getMyUnits] isEqualToString: @"M"]) {
					numerator = 1 * 0.621371;
				}
			}
			else { // 1 m
				if ([[Me getMyUnits] isEqualToString: @"K"]) {
					numerator = 1 * 1.60934;
				}
			}
		}
		else {
			numerator = [self.periodActivity.distance floatValue] / 1000.0; // km
			if ([[Me getMyUnits] isEqualToString: @"M"]) {
				numerator = [self.periodActivity.distance floatValue] / 1000.0 * 0.621371;
			}
			
			denominator = [[self.periodActivity getMinutes] floatValue] / 60.0; // hrs
		}
		
		if (denominator == 0) {
			theSpeed = 0;
		}
		else {
			theSpeed = numerator / denominator;
		}
		
		
		if ([[Me getMyUnits] isEqualToString : @"K"])  {
			retval = [NSString stringWithFormat: @"%.1f km/h", theSpeed];	
		}
		else {
			retval = [NSString stringWithFormat: @"%.1f mph", theSpeed];	
		}
		return retval;
	}
	@catch (NSException * ex) {
		return @"";
	}
}


-(NSString *) getPeriodPace {
	@try {
		NSString * retval = @"";
		float thePace = 0;
		double denominator = 0;
		double numerator = 0;
		
		if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
			numerator = [self.periodActivity.segmentDuration floatValue] / 60.0; // duration is in seconds
			denominator = 1;
			if ([self.itemCode isEqualToString: @"s_1k"]) {
				if ([[Me getMyUnits] isEqualToString: @"M"]) {
					denominator = 1 * 0.621371;
				}
			}
			else { // 1 m
				if ([[Me getMyUnits] isEqualToString: @"K"]) {
					denominator = 1 * 1.60934;
				}
			}
		}
		else {
			denominator = [self.periodActivity.distance floatValue] / 1000.0; // km
			if ([[Me getMyUnits] isEqualToString: @"M"]) {
				denominator = [self.periodActivity.distance floatValue] / 1000.0 * 0.621371;
			}
			
			numerator = [[self.periodActivity getMinutes] floatValue];
		}
		
		if (denominator == 0) {
			thePace = 0;
		}
		else {
			thePace = numerator / denominator;
		}
		
		
		int min = floor(thePace);
		int sec = (thePace - min) * 60.0;
		if ([[Me getMyUnits] isEqualToString : @"K"])  {
			retval = [NSString stringWithFormat: @"%01d:%.2d min/km", min, sec];	
		}
		else {
			retval = [NSString stringWithFormat: @"%01d:%02d min/mi", min, sec];
		}		
		
		return retval;
	}
	@catch (NSException * ex) {
		return @"";
	}
}
	
-(NSString *) getPeriodResult {
	NSString * retval = @"";
	if (self.periodActivity) {
		if ([self.itemCategory isEqualToString: @"Distance"]) {
			retval = [self.periodActivity getDistanceFormatted];
		}
		else {
			if ([self.itemCategory isEqualToString: @"Duration"]) {
				retval = [self.periodActivity getDurationFormatted];
			}
			else { // speed
				if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
					retval = [self.periodActivity getSegmentDurationFormatted];
				}
				else {
					retval = [self.periodActivity getDurationFormatted];
				}
			}
		}
	}
	else {
		return @"N/A";
	}
	return retval;
}

-(NSString *) getPeriodResultShort {
	NSString * retval = @"";
	if (self.periodActivity) {
		if ([self.itemCategory isEqualToString: @"Distance"]) {
			retval = [self.periodActivity getDistanceFormattedShort];
		}
		else {
			if ([self.itemCategory isEqualToString: @"Duration"]) {
				retval = [self.periodActivity getDurationFormattedShort];
			}
			else { // speed
				if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
					retval = [self.periodActivity getSegmentDurationFormattedShort];
				}
				else {
					retval = [self.periodActivity getDurationFormattedShort];
				}
			}
		}
	}
	else {
		return @"N/A";
	}
	return retval;
}

-(NSString *) getPeriodResultVeryShort {
	NSString * retval = @"";
	if (self.periodActivity) {
		if ([self.itemCategory isEqualToString: @"Distance"]) {
			retval = [self.periodActivity getDistanceFormattedShort];
		}
		else {
			if ([self.itemCategory isEqualToString: @"Duration"]) {
				retval = [self.periodActivity getDurationFormattedVeryShort];
			}
			else { // speed
				if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
					retval = [self.periodActivity getSegmentDurationFormattedVeryShort];
				}
				else {
					retval = [self.periodActivity getDurationFormattedVeryShort];
				}
			}
		}
	}
	else {
		return @"N/A";
	}
	return retval;
}

-(NSString *) getPRResult {
	NSString * retval = @"";
	if (self.allTimeActivity) {
		if ([self.itemCategory isEqualToString: @"Distance"]) {
			retval = [self.allTimeActivity getDistanceFormattedShort];
		}
		else {
			if ([self.itemCategory isEqualToString: @"Duration"]) {
				retval = [self.allTimeActivity getDurationFormattedShort];
			}
			else { // speed
				if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
					retval = [self.allTimeActivity getSegmentDurationFormattedShort];
				}
				else {
					retval = [self.allTimeActivity getDurationFormattedShort];
				}

			}
		}
	}
	else {
		return @"N/A";
	}
	return retval;
}

-(NSString *) getPeriodWhen {
	NSString * retval = @"";
	if (self.periodActivity) {
		retval = [self.periodActivity getWhenFormatted];
	}
	return retval;
}

-(NSString *) getPRWhen {
	NSString * retval = @"";
	if (self.allTimeActivity) {
		retval = [self.allTimeActivity getWhenFormattedShort];
	}
	return retval;
}

-(NSString *) getPeriodAgo {
	NSString * retval = @"";
	if (self.periodActivity) {
		retval = [Utilities getTimeFromDate: self.periodActivity.start_time];
	}
	return retval;
}


-(NSString *) getAllTimeResult {
	NSString * retval = @"";
	if (self.allTimeActivity) {
		if ([self.itemCategory isEqualToString: @"Distance"]) {
			retval = [self.allTimeActivity getDistanceFormatted];
		}
		else {
			if ([self.itemCategory isEqualToString: @"Duration"]) {
				retval = [self.allTimeActivity getDurationFormatted];
			}
			else { // speed
				if ([self.itemCode isEqualToString: @"s_1k"] || [self.itemCode isEqualToString: @"s_1m"]) {
					retval = [self.allTimeActivity getSegmentDurationFormatted];
				}
				else {
					retval = [self.allTimeActivity getDurationFormatted];
				}
			}
		}
	}
	else {
		retval = @"N/A";
	}
	
	
	return retval;
}
	
@end
