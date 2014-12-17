//
//  GoalFormatter.m
//  Stativity
//
//  Created by Igor Nakshin on 7/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "GoalFormatter.h"
#import "StativityData.h"
#import "Activity.h"
#import "ActivitySegment.h"
#import "Me.h"

@implementation GoalFormatter

@synthesize activityType; // Running, Cycling, Walking
@synthesize kind; // Speed, Distance, Time
@synthesize goalDuration; // in seconds
@synthesize goalDistance; // in meters
@synthesize goalUnits; // m or k
@synthesize goalMeters; // for sorting speed goals
@synthesize bestActivityId; // activity id that created this goal
@synthesize bestActivity;
@synthesize bestStartTime;

+(GoalFormatter *) initWithGoal : (Goal *) goal {
	GoalFormatter * retval = [[GoalFormatter alloc] init];
	retval.activityType = goal.activityType;
	retval.kind = goal.kind;
	retval.goalDistance = goal.goalDistance;
	retval.goalDuration = goal.goalDuration;
	retval.goalUnits = goal.goalUnits;
	retval.goalMeters = goal.goalMeters;
	retval.bestActivityId = goal.bestActivityId;
	
	StativityData * rkd = [StativityData get];
	retval.bestActivity = [rkd fetchActivity: retval.bestActivityId];
	if (retval.bestActivity) {
		retval.bestStartTime = retval.bestActivity.start_time;
	}
	else {
		retval.bestStartTime = nil;
	}
	return retval;
}

// 
//   Beat farthest Run
//		activityType = Running 
//		kind = Distance
//      goalDistance = max total_distance from Activities
//		goalDuration = 0
//		units = ""

//   Beat longest Run
//		activityType = Running
//		kind = Time
//		goalDistance = 0
//		goalDuration = max duration from Activities
//		goalUnits = ""

//	 Beat 5K run time
//		activityType = Running
//		kind = Speed
//		goalDistance = 5
//		goalUnits = k
//		goalDuration = max seconds from ActivitySegment where 
//						units = goalUnits and title = goalDistance
//

-(Activity *) getActivityToBeat {
	StativityData * rkd = [StativityData get];
	Activity * retval = nil;
	
	if ([self.kind isEqualToString: @"Distance"]) {
		// find farthest activity
		Activity * farthest = [rkd getFarthestActivityOfType: self.activityType];
		retval = farthest;
	}
	
	if ([self.kind isEqualToString: @"Time"]) {
		// find longest activity
		Activity * longest = [rkd getLongestActivityOfType: self.activityType];
		return longest;
	}
	
	if ([self.kind isEqualToString: @"Speed"]) {
		// find fastest activity of type, units and title
		ActivitySegment * seg = [rkd getFastestSegmentOfType: self.activityType
			withTitle: [NSString stringWithFormat: @"%i", [self.goalDistance intValue]]
			andUnits: self.goalUnits];
		if (seg) {
			Activity * fastest = [rkd fetchActivity: seg.activityId];
			retval = fastest;
		}
	}
	
	return retval;
}

-(ActivitySegment *) getSegmentToBeat {
	StativityData * rkd = [StativityData get];
	ActivitySegment * retval = nil;
	
	if ([self.kind isEqualToString: @"Speed"]) {
		ActivitySegment * seg = [rkd getFastestSegmentOfType: self.activityType
			withTitle: [NSString stringWithFormat: @"%i", [self.goalDistance intValue]]
			andUnits: self.goalUnits];
		retval = seg;
	}
	
	return retval;
}

-(NSString *) getDistanceFormatted {
	NSString * retval = @"";
	if ([[Me getMyUnits] isEqualToString : @"K"]) {
		retval = [NSString stringWithFormat: @"%.2f km", [self.goalDistance floatValue]/1000];
	}
	else {
		retval = [NSString stringWithFormat: @"%.2f mi", [self.goalDistance floatValue]/1000 *  0.621371192];
	}
	return retval;
}


-(NSString *) getDurationFormatted {
	float totalSeconds = floor([self.goalDuration floatValue]);
	
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

-(NSString *)getSpeedFormatted {
	NSNumber * theSpeed = [self getSpeed];
	if ([[Me getMyUnits] isEqualToString : @"K"])  {
		return [NSString stringWithFormat: @"%.1f km/h", [theSpeed floatValue]];	
	}
	else {
		return [NSString stringWithFormat: @"%.1f mph", [theSpeed floatValue]];	
	}
}

-(NSString *)getPaceFormatted {
	float thePace = [[self getPace] floatValue];
	
	int min = floor(thePace);
	int sec = (thePace - min) * 60.0;
	
	if ([[Me getMyUnits] isEqualToString : @"K"])  {
		return [NSString stringWithFormat: @"%01d:%.2d min/km", min, sec];	
	}
	else {
		return [NSString stringWithFormat: @"%01d:%02d min/mi", min, sec];
	}
}


-(NSNumber *) getSpeed {
	@try {
		if (self.goalDistance == 0) {
			return [NSNumber numberWithFloat: 0];
		}
		else {
			double numerator = [self.goalDistance floatValue] / 1000.0; // in KM
			double denominator = [[self getHours] floatValue]; // in HRS
			
			if ([[Me getMyUnits] isEqualToString: @"M"]) {
				numerator = [[self getMiles] floatValue ]; // into miles
			}
			float dpd = numerator / denominator;
			
			if (isnan(dpd)) {
				dpd = 0;
			}
			
			NSNumber * retval = [NSNumber numberWithFloat: dpd];
			return retval;
		}
	}
	@catch ( NSException * ex ) {
		return 0;
	}
}

-(NSNumber *) getPace {
	@try {
		if (self.goalDistance == 0) {
			return [NSNumber numberWithFloat: 0];
		}
		else {
			double denominator = [self.goalDistance floatValue] / 1000.0; // in KM
			double numerator = [[self getMinutes] floatValue]; 
			
			if ([[Me getMyUnits] isEqualToString: @"M"]) {
				denominator = [[self getMiles] floatValue ]; // into miles
			}
			
			if (denominator == 0) {
				return [NSNumber numberWithFloat: 0];
			}
			else {
				if (denominator != 0) {
					float dpd = numerator / denominator;
					NSNumber * retval = [NSNumber numberWithFloat: dpd];
					return retval;
				}
				else {
					return [NSNumber numberWithFloat: 0];
				}			
			}
		}
	}
	@catch ( NSException * ex ) {
		return 0;
	}
}

-(NSNumber *) getMinutes {
	double minutes = [self.goalDistance floatValue] / 60.0 ; 
	return [NSNumber numberWithFloat: minutes];
}


-(NSNumber *) getHours {
	double hours = [[self getMinutes] floatValue] / 60.0;
	return [NSNumber numberWithFloat: hours];
}

-(NSNumber *) getMiles {
	double miles = ([self.goalDistance floatValue] / 1000) * 0.621371192;
	return [NSNumber numberWithFloat: miles];
}

-(NSNumber *) getDistanceInUnits {
	NSNumber * retval = [NSNumber numberWithInt: 0];
	if ([[Me getMyUnits] isEqualToString: @"K"]) {
		retval = [NSNumber numberWithFloat: [self.goalDistance floatValue]/1000];
	}
	else{
		retval = [NSNumber numberWithFloat: [self.goalDistance floatValue]/1000 *  0.621371192];
	}
	return retval;
}











@end
