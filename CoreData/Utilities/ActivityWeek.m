//
//  RunKeeperWeek.m
//  Stativity
//
//  Created by Igor Nakshin on 7/12/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "ActivityWeek.h"
#import "StativityData.h"
#import "Activity.h"
#import "Me.h"
#import "Utilities.h"

@implementation ActivityWeek

@synthesize year;
@synthesize weekNumber;
@synthesize weekStart;
@synthesize weekEnd;
@synthesize value;
@synthesize numberOfActivities;
@synthesize totalTime;
@synthesize totalDistance;
@synthesize totalCalories;
@synthesize yearStart;
@synthesize monthStart;
@synthesize yearMonthStartName;
@synthesize rank;
@synthesize order;

-(NSString *) description {
	return [NSString stringWithFormat: 
		@"%d. %@  - %@ %d k", [self.order intValue], [self yearMonthStartName], weekStart, [totalDistance intValue]/1000];
	//return [NSString stringWithFormat: @"y %d w%d start %@ end %@", [year intValue] , [weekNumber intValue], weekStart, weekEnd];
}

+(NSArray *) getWeeksBetween:(NSDate *)startDate and:(NSDate *)endDate {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	NSMutableArray * eow = [[NSMutableArray alloc] init];
	
	StativityData * rkd = [StativityData get];
	NSArray * activities = [rkd fetchActivitiesBetweenStartDate: startDate andEndDate: endDate ofType: @""];
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
	for(int i = 0; i < [activities count]; i++) {
		Activity * activity = [activities objectAtIndex: i];
		NSDate * activityDate = activity.start_time;
		
		NSDateComponents *components = [gregorian components: NSYearCalendarUnit | NSWeekOfYearCalendarUnit fromDate: activityDate];
		ActivityWeek * week = [[ActivityWeek alloc] init];
		week.year = [NSNumber numberWithInt: components.year];
		week.weekNumber = [NSNumber numberWithInt: components.weekOfYear];
		NSDateComponents *comp = [gregorian components:NSYearCalendarUnit fromDate: activityDate];
		[comp setWeek : components.weekOfYear];
		[comp setWeekday: 1];
		week.weekStart = [gregorian dateFromComponents: comp];
		
		int firstDOW = [Me getFirstDayOfWeek];
		if (firstDOW == 2) { // move to monday
			week.weekStart = [week.weekStart dateByAddingTimeInterval: 60 * 60 * 24];
		}
		
		[comp setWeekday: 7];
		[comp setHour: 23];
		[comp setMinute: 59];
		[comp setSecond: 59];
		week.weekEnd = [gregorian dateFromComponents: comp];
		if (firstDOW == 2) { // move to monday
			week.weekEnd = [week.weekEnd dateByAddingTimeInterval: 60 * 60 * 24];
		}
		
		if (![eow containsObject: week.weekStart]) {
			if (week.weekStart < [Utilities currentLocalDate]) {
				[retval addObject: week];
				[eow addObject: week.weekStart];
			}
		}
	}
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"weekStart" ascending:YES];
	NSArray * _retval = [retval sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
	return _retval;
}

+(NSArray *) getWeeklyStatsForActivityType : (NSString *) activityType {
	NSArray * weeks = [ActivityWeek getWeeks];
	
	StativityData * rkd = [StativityData get];
	for(int i = 0; i < [weeks count]; i++) {
		ActivityWeek * week = [weeks objectAtIndex: i];
		NSArray * activities = [rkd fetchActivitiesBetweenStartDate: week.weekStart 
			andEndDate: week.weekEnd ofType: activityType];
			
		week.numberOfActivities = [NSNumber numberWithInt: [activities count]];
		float distance = 0;
		float time = 0;
		float calories = 0;
		for(int j = 0; j < [activities count]; j++) {
			Activity * act = [activities objectAtIndex: j];
			distance = distance + [act.total_distance floatValue];
			time = time + [act.duration floatValue];
			calories = calories + [act.total_calories floatValue];
		}
		
		week.totalCalories = [NSNumber numberWithFloat: calories];
		week.totalDistance = [NSNumber numberWithFloat: distance];
		week.totalTime = [NSNumber numberWithFloat: time];
		
	}
	
	// rank
	NSSortDescriptor * desc = [[NSSortDescriptor alloc] initWithKey: @"totalDistance" ascending: NO];
	NSMutableArray * sorted = [[NSMutableArray alloc] init];
	for(int i = 0; i < [weeks count]; i++) {
		[sorted addObject: [weeks objectAtIndex: i]];
	}
	[sorted sortUsingDescriptors: [[NSArray alloc] initWithObjects: desc, nil]];
	
	for(int i = 0; i < [weeks count]; i++) {
		ActivityWeek * week = [weeks objectAtIndex: i];
		NSUInteger index = [sorted indexOfObject: week] + 1;
		week.rank = [NSNumber numberWithInt: index];
	}
	
	// sort by date
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"weekStart" ascending:NO];
	NSArray * _retval = [weeks sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	// order
	int count = [_retval count];
	for(int i = 0; i < [_retval count]; i++) {
		ActivityWeek * week = [_retval objectAtIndex: i];
		week.order = [NSNumber numberWithInt: count - i];
	}
	
	return _retval;
}

+(NSArray *) getWeeks {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	NSMutableArray * dates = [[NSMutableArray alloc] init];
	StativityData * rkd = [StativityData get];
	Activity * first = [rkd getFirstActivity];
	Activity * last = [rkd getLastActivity];
	
	NSDate * firstDate = [Utilities getFirstDayOfWeek: first.start_time];
	NSDate * lastDate = [Utilities getLastDayOfWeek: last.start_time];
	
	int firstDOW = [Me getFirstDayOfWeek];
	if (firstDOW == 2) { // move to monday
		firstDate = [firstDate dateByAddingTimeInterval: 60 * 60 * 24];
		lastDate = [lastDate dateByAddingTimeInterval: 60 * 60 * 24];
	}
	lastDate = [lastDate dateByAddingTimeInterval: 1]; // beginning of next week
	NSDate * curDate = firstDate;
	while ([curDate compare: lastDate] == NSOrderedAscending) {
		[dates addObject: curDate];
		curDate = [curDate dateByAddingTimeInterval: 7 * 60 * 60 * 24];
	}
	
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
	
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setDateFormat: @"MMM YYYY"];
	
	for(int i = 0; i < [dates count]; i++) {
		NSDate * bow = [dates objectAtIndex: i];
		ActivityWeek * week = [[ActivityWeek alloc] init];
		week.weekStart = bow;
		week.order = [NSNumber numberWithInt: i + 1];
		week.weekEnd = [Utilities getLastDayOfWeek: bow];
		if (firstDOW == 2) {
			week.weekEnd = [week.weekEnd dateByAddingTimeInterval: 60 * 60 * 24];
		}
		
		NSDateComponents * comp = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate: bow];
		week.yearStart = [NSNumber numberWithInt: comp.year];
		week.monthStart = [NSNumber numberWithInt: comp.month];
		NSString * start = [df stringFromDate: week.weekStart];
		//NSString * end = [df stringFromDate: week.weekEnd];
		week.yearMonthStartName = [NSString stringWithFormat: @"%@", start];
		week.weekEnd = [week.weekStart dateByAddingTimeInterval: 7 * 60 * 60 * 24 - 1];
		[retval addObject: week]; 
	} 
	
	return [retval copy];
}

+(NSArray *) getWeeks2 {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	NSMutableArray * eow = [[NSMutableArray alloc] init];
	
	StativityData * rkd = [StativityData get];
	NSArray * activities = [rkd fetchAllActivities];
	
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]
		 initWithKey: @"start_time" ascending: YES];
	activities = [activities sortedArrayUsingDescriptors: [NSArray arrayWithObject: sd]];
		
	
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
	for(int i = 0; i < [activities count]; i++) {
		Activity * activity = [activities objectAtIndex: i];
		NSDate * activityDate = activity.start_time;
		NSLog(@"%@", activityDate);
		NSDateComponents *components = [gregorian components: NSYearCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit fromDate: activityDate];
		ActivityWeek * week = [[ActivityWeek alloc] init];
		week.year = [NSNumber numberWithInt: components.year];
		if ([week.year intValue] == 2012) {
			NSLog(@"stop");
		}
		week.weekNumber = [NSNumber numberWithInt: components.weekOfYear];
		NSDateComponents *comp = [gregorian components:NSYearCalendarUnit fromDate: activityDate];
		[comp setWeek : components.weekOfYear];
		[comp setWeekday: 1];
		week.weekStart = [gregorian dateFromComponents: comp];
		int firstDOW = [Me getFirstDayOfWeek];
		if (firstDOW == 2) { // move to monday
			week.weekStart = [week.weekStart dateByAddingTimeInterval: 60 * 60 * 24];
		}
		
		[comp setWeekday: 7];
		[comp setHour: 23];
		[comp setMinute: 59];
		[comp setSecond: 59];
		week.weekEnd = [gregorian dateFromComponents: comp];
		if (firstDOW == 2) { // move to monday
			week.weekEnd = [week.weekEnd dateByAddingTimeInterval: 60 * 60 * 24];
		}
		
		if (![eow containsObject: week.weekStart]) {
			if (week.weekStart <= [Utilities currentLocalDate]) {
				NSLog(@"%@", week);
				[retval addObject: week];
				[eow addObject: week.weekStart];
			}
		}
	}
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"weekStart" ascending:YES];
	NSArray * _retval = [retval sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
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
	[dateFormatter setDateFormat: @"MMM d yyyy"];  	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString * formattedDate = [dateFormatter stringFromDate: self.weekStart]; 
	formattedDate = [@"Week of " stringByAppendingFormat: @"%@", formattedDate];
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
