//
//  Activity.m
//  Stativity
//
//  Created by Igor Nakshin on 30/09/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "Activity.h"
#import "ActivityFormatter.h"
#import "Endomondo.h"


@implementation Activity

@dynamic averageGrade;
@dynamic avgAltitude;
@dynamic climb;
@dynamic detailCount;
@dynamic duration;
@dynamic heartRate;
@dynamic id;
@dynamic maxAltitude;
@dynamic minAltitude;
@dynamic source;
@dynamic start_time;
@dynamic stdevAltitude;
@dynamic total_calories;
@dynamic total_distance;
@dynamic type;
@dynamic uri;
@dynamic minHeartRate;
@dynamic maxHeartRate;

@synthesize daysFromNow;
@synthesize weeksFromNow;
@synthesize monthsFromNow;
@synthesize yearsFromNow;

-(NSString *) getCommonDistance {
	ActivityFormatter * fmt = [ActivityFormatter initWithRun: self];
	return [fmt getCommonDistance];
}

-(void) fromDict:(NSDictionary *)rd {
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss"];  	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSLocale *locale = [[NSLocale alloc]  initWithLocaleIdentifier:@"en_US_POSIX"];
	[dateFormatter setLocale: locale];
	
	self.duration = [NSNumber numberWithFloat: [[rd objectForKey: @"duration"] floatValue]];
	
	NSString * startTime = [rd objectForKey: @"start_time"];
	NSDate * converted = [dateFormatter dateFromString: startTime];
	self.start_time = converted; 
	
	self.total_distance = [NSNumber numberWithFloat: [[rd objectForKey: @"total_distance"] floatValue] ];
	self.type = [rd objectForKey:@"type"];
	self.uri = [rd objectForKey: @"uri"];
	self.id = [self.uri stringByReplacingOccurrencesOfString: @"/fitnessActivities/" withString:@""];
}

-(void) fromEndomondoDict:(NSDictionary *)rd {
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[df setDateFormat: @"yyyy-MM-dd HH:mm:ss z"];
	[df setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: [NSTimeZone systemTimeZone].secondsFromGMT]];
	double secondsFromGmt = [NSTimeZone systemTimeZone].secondsFromGMT;
	self.duration = [NSNumber numberWithFloat: [[rd objectForKey: @"duration_sec"] floatValue]];
	self.start_time = [df dateFromString : [rd objectForKey: @"start_time"]];
	self.start_time = [self.start_time dateByAddingTimeInterval: secondsFromGmt];
	self.total_distance = [NSNumber numberWithFloat: [[rd objectForKey: @"distance_km"] floatValue] * 1000.0];
	self.type = [Endomondo sportToActivityType: [rd objectForKey: @"sport"]];
	self.uri = [NSString stringWithFormat: @"%d", [[rd objectForKey: @"id"] intValue]];
	self.id = [NSString stringWithFormat: @"%d", [[rd objectForKey: @"id"] intValue]];
	self.total_calories = [NSNumber numberWithFloat: [[rd objectForKey: @"calories"] floatValue]];
}

-(void) updateTimeComponents {
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDateComponents * diff = [gregorian 
		components: flags 
		fromDate: self.start_time
		toDate: [NSDate date] 
		options:0];
		
	self.daysFromNow = [NSNumber numberWithInt: diff.day];
	self.weeksFromNow = [NSNumber numberWithInt: diff.week];
	self.monthsFromNow = [NSNumber numberWithInt: diff.month];
	self.yearsFromNow = [NSNumber numberWithInt: diff.year];
}

-(NSNumber *) getSpeed {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getSpeed];
}

-(NSNumber *) getMinutes {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getMinutes];
}

-(NSNumber *) getMiles {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getMiles];
}

-(NSString *) getSpeedFormatted {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getSpeedFormatted];
}

-(NSNumber *) getDistanceInUnits {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun : self];
	return [formatter getDistanceInUnits];
}

-(NSString *) getPaceFormatted {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getPaceFormatted];
}

-(NSString *) getWhenFormatted {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getWhenFormatted];
}

-(NSString *) getDistanceFormatted {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getDistanceFormatted];
}

-(NSString *) getDurationFormatted {
	ActivityFormatter * formatter = [ActivityFormatter initWithRun: self];
	return [formatter getDurationFormatted];
}


@end
