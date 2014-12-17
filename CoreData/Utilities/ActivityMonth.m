//
//  RunKeeperMonth.m
//  Stativity
//
//  Created by Igor Nakshin on 7/19/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "ActivityMonth.h"
#import "StativityData.h"
#import "Activity.h"
#import "Utilities.h"
#import "Me.h"

@implementation ActivityMonth

@synthesize year;
@synthesize monthNumber;
@synthesize monthStart;
@synthesize monthEnd;
@synthesize value;
@synthesize numberOfActivities;
@synthesize totalTime;
@synthesize totalDistance;
@synthesize totalCalories;
@synthesize yearStart;
@synthesize yearMonthStartName;
@synthesize rank;
@synthesize order;

-(NSString *) description {
	return [NSString stringWithFormat: @"%@ - %@", monthStart, monthEnd];
}

+(NSArray *) getMonths {
	NSMutableArray * retval = [[NSMutableArray alloc] init];

	StativityData * rkd = [StativityData get];
	Activity * first = [rkd getFirstActivity];
	Activity * last  = [rkd getLastActivity];
	
	NSDate * startDate = [Utilities getFirstDayOfMonth: first.start_time];
	NSDate * endDate = [Utilities getLastDayOfMonth: last.start_time];
	NSDate * curDate = startDate;
	
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar ];
	[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
	
	while ([curDate compare: endDate] == NSOrderedAscending) {
		NSDate * curMonthStart = [Utilities getFirstDayOfMonth: curDate];
		NSDate * curMonthEnd   = [Utilities getLastDayOfMonth: curDate];
		
		ActivityMonth * am = [[ActivityMonth alloc] init];
		am.monthStart = curMonthStart;
		am.monthEnd = curMonthEnd;
		
		NSDateComponents * components = [gregorian components: NSYearCalendarUnit fromDate: am.monthStart];
		am.yearMonthStartName = [NSString stringWithFormat: @"%d", components.year];

		[retval addObject: am];
		
		curDate = [curMonthEnd dateByAddingTimeInterval: 1]; // first of next month
	}
	return [retval copy];
}

+(NSArray *) getMonthsBetween : (NSDate *) startDate and : (NSDate *) endDate {
	return nil;
}

+(NSArray *) getMonthlyStatsForActivityType:(NSString *)activityType {
	NSArray * months = [ActivityMonth getMonths];
	
	StativityData * rkd = [StativityData get];
	for(int i = 0; i < [months count]; i++) {
		ActivityMonth * month = [months objectAtIndex: i];
		NSArray * activities = [rkd fetchActivitiesBetweenStartDate: month.monthStart 
			andEndDate: month.monthEnd ofType: activityType];
			
		month.numberOfActivities = [NSNumber numberWithInt: [activities count]];
		float distance = 0;
		float time = 0;
		float calories = 0;
		for(int j = 0; j < [activities count]; j++) {
			Activity * act = [activities objectAtIndex: j];
			distance = distance + [act.total_distance floatValue];
			time = time + [act.duration floatValue];
			calories = calories + [act.total_calories floatValue];
		}
		
		month.totalCalories = [NSNumber numberWithFloat: calories];
		month.totalDistance = [NSNumber numberWithFloat: distance];
		month.totalTime = [NSNumber numberWithFloat: time];
	}
	
	// rank
	NSSortDescriptor * desc = [[NSSortDescriptor alloc] initWithKey: @"totalDistance" ascending: NO];
	NSMutableArray * sorted = [[NSMutableArray alloc] init];
	for(int i = 0; i < [months count]; i++) {
		[sorted addObject: [months objectAtIndex: i]];
	}
	[sorted sortUsingDescriptors: [[NSArray alloc] initWithObjects: desc, nil]];
	
	for(int i = 0; i < [months count]; i++) {
		ActivityMonth * month = [months objectAtIndex: i];
		NSUInteger index = [sorted indexOfObject: month] + 1;
		month.rank = [NSNumber numberWithInt: index];
	}
	
	// sort by date
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"monthStart" ascending:NO];
	NSArray * _retval = [months sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	// order
	int count = [_retval count];
	for(int i = 0; i < [_retval count]; i++) {
		ActivityMonth * month = [_retval objectAtIndex: i];
		month.order = [NSNumber numberWithInt: count - i];
	}
	
	return _retval;
}

-(NSString *) getDistanceFormatted {
	NSString * retval = @"";
	if ([[Me getMyUnits] isEqualToString : @"K"]) {
		retval = [NSString stringWithFormat: @"%.2f km", [self.totalDistance floatValue]/1000];
	}
	else {
		retval = [NSString stringWithFormat: @"%.2f mi", [self.totalDistance floatValue]/1000 *  0.621371192];
	}
	return retval;
}

-(NSString *) getDurationFormatted {
	float totalSeconds = floor([self.totalTime floatValue]);
	
	int days = floor(totalSeconds / 86400.0);
	int hours = floor((totalSeconds - days * 86400.0) / 3600.0);
	int minutes = floor((totalSeconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int seconds = floor(totalSeconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%d days %d hrs", days, hours];
	}
	else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%d hrs %d min", hours, minutes];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%d min %d sec", minutes, seconds];
		} 
	}
	return strDuration;
}

-(NSString *) getWhenFormatted {
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"MMMM yyyy"];  	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString * formattedDate = [dateFormatter stringFromDate: self.monthStart]; 
	return formattedDate;
}

-(NSNumber *) getDistanceInUnits {
	NSNumber * retval = [NSNumber numberWithInt: 0];
	if ([[Me getMyUnits] isEqualToString: @"K"]) {
		retval = [NSNumber numberWithFloat: [self.totalDistance floatValue]/1000];
	}
	else{
		retval = [NSNumber numberWithFloat: [self.totalDistance floatValue]/1000 *  0.621371192];
	}
	return retval;
}

-(NSNumber *) getMiles {
	float km = [self.totalDistance floatValue] / 1000;
	return [NSNumber numberWithFloat: km *  0.621371192];
}


@end
