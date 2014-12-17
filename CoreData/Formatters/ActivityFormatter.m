//
//  RunKeeperRunFormatter.m
//  Stativity
//
//  Created by Igor Nakshin on 6/30/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "ActivityFormatter.h"
#import "Activity.h"
#import "ActivitySegment.h"
#import "Me.h"

@implementation ActivityFormatter

@synthesize activityId;
@synthesize duration;  // seconds
@synthesize distance; // meters
@synthesize calories;
@synthesize start_time;
@synthesize segmentDuration;

+(ActivityFormatter *) initWithRun:(Activity *) run {
	if (!run) return nil;
	ActivityFormatter * retval = [[ActivityFormatter alloc] init];
	retval.activityId = run.id;
	retval.distance = run.total_distance;
	retval.duration = run.duration;
	retval.start_time = run.start_time;
	return retval;
}

+(ActivityFormatter *) initWithSegment:(ActivitySegment *)segment {
	if (!segment) return nil;
	ActivityFormatter * retval = [[ActivityFormatter alloc] init];
	retval.activityId = segment.activityId;
	retval.distance = segment.meters;
	retval.duration =  segment.seconds;
	retval.start_time = segment.activityTime;
	retval.segmentDuration = segment.segmentSeconds;
	return retval;
}

+(ActivityFormatter *) initWithDuration:(NSNumber *)duration andDistance:(NSNumber *)distance {
	ActivityFormatter * retval = [[ActivityFormatter alloc] init];
	retval.duration = duration;
	retval.distance = distance;
	return retval;
}

-(NSNumber *) getSpeed {
	@try {
		if (self.distance == 0) {
			return [NSNumber numberWithFloat: 0];
		}
		else {
			double numerator = [self.distance floatValue] / 1000.0; // in KM
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
		if (self.distance == 0) {
			return [NSNumber numberWithFloat: 0];
		}
		else {
			double denominator = [self.distance floatValue] / 1000.0; // in KM
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
	double minutes = [self.duration floatValue] / 60.0 ; 
	return [NSNumber numberWithFloat: minutes];
}


-(NSNumber *) getHours {
	double hours = [[self getMinutes] floatValue] / 60.0;
	return [NSNumber numberWithFloat: hours];
}

-(NSNumber *) getMiles {
	double miles = ([self.distance floatValue] / 1000) * 0.621371192;
	return [NSNumber numberWithFloat: miles];
}

-(NSNumber *) getKms {
	double kms = [self.distance floatValue] / 1000;
	return [NSNumber numberWithFloat: kms];
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

-(NSNumber *) getDistanceInUnits {
	NSNumber * retval = [NSNumber numberWithInt: 0];
	if ([[Me getMyUnits] isEqualToString: @"K"]) {
		retval = [NSNumber numberWithFloat: [self.distance floatValue]/1000];
	}
	else{
		retval = [NSNumber numberWithFloat: [self.distance floatValue]/1000 *  0.621371192];
	}
	return retval;
}

-(NSString *) getDistanceFormatted {
	NSString * retval = @"";
	if ([[Me getMyUnits] isEqualToString : @"K"]) {
		retval = [NSString stringWithFormat: @"%.2f km", [self.distance floatValue]/1000];
	}
	else {
		retval = [NSString stringWithFormat: @"%.2f mi", [self.distance floatValue]/1000 *  0.621371192];
	}
	return retval;
}

-(NSString *) getDistanceFormattedShort {
	NSString * retval = @"";
	if ([[Me getMyUnits] isEqualToString : @"K"]) {
		retval = [NSString stringWithFormat: @"%.2f km", [self.distance floatValue]/1000];
	}
	else {
		retval = [NSString stringWithFormat: @"%.2f mi", [self.distance floatValue]/1000 *  0.621371192];
	}
	return retval;
}

-(NSString *) getDurationFormatted {
	float totalSeconds = floor([self.duration floatValue]);
	
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

-(NSString *) getSegmentDurationFormatted {
	if (!self.segmentDuration) return @"";
	
	float totalSeconds = floor([self.segmentDuration floatValue]);
	
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

-(NSString *) getDurationFormattedShort {
	float totalSeconds = floor([self.duration floatValue]);
	
	int days = floor(totalSeconds / 86400.0);
	int hours = floor((totalSeconds - days * 86400.0) / 3600.0);
	int minutes = floor((totalSeconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int seconds = floor(totalSeconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%d d %d h", days, hours];
	}
	else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%d h %d m", hours, minutes ];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%d m %d s", minutes, seconds];
		} 
	}
	return strDuration;
}

-(NSString *) getSegmentDurationFormattedShort {
	if (!self.segmentDuration) return @"";
	
	float totalSeconds = floor([self.segmentDuration floatValue]);
	
	int days = floor(totalSeconds / 86400.0);
	int hours = floor((totalSeconds - days * 86400.0) / 3600.0);
	int minutes = floor((totalSeconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int seconds = floor(totalSeconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%d d %d h", days, hours];
	}
	else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%d h %d m", hours, minutes ];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%d m %d s", minutes, seconds];
		} 
	}
	return strDuration;
}

-(NSString *) getDurationFormattedVeryShort {
	float totalSeconds = floor([self.duration floatValue]);
	
	int days = floor(totalSeconds / 86400.0);
	int hours = floor((totalSeconds - days * 86400.0) / 3600.0);
	int minutes = floor((totalSeconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int seconds = floor(totalSeconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%dd%dh", days, hours];
	}
	else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%dh%dm", hours, minutes ];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%dm%ds", minutes, seconds];
		} 
	}
	return strDuration;
}

-(NSString *) getSegmentDurationFormattedVeryShort {
	if (!self.segmentDuration) return @"";
	
	float totalSeconds = floor([self.segmentDuration floatValue]);
	
	int days = floor(totalSeconds / 86400.0);
	int hours = floor((totalSeconds - days * 86400.0) / 3600.0);
	int minutes = floor((totalSeconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int seconds = floor(totalSeconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%dd%dh", days, hours];
	}
	else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%dh%dm", hours, minutes ];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%dm%ds", minutes, seconds];
		} 
	}
	return strDuration;
}


-(NSString *) getWhenFormatted {
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	//[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	//[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat: @"EEE, MMM d yyyy"];  	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString * formattedDate = [dateFormatter stringFromDate: self.start_time]; 
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	//[dateFormatter setDateFormat: @"hh:mm a"];
	NSString * formattedTime = [dateFormatter stringFromDate : start_time];
	formattedDate = [formattedDate stringByAppendingFormat : @" at %@", formattedTime];
	return formattedDate;
}

-(NSString *) getWhenFormattedShort {
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"MMM d ''yy"];  	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString * formattedDate = [dateFormatter stringFromDate: self.start_time]; 
	return formattedDate;
}


-(NSString *) getCommonDistance {
	NSString * retval = @"";
	// in descending order
	if (1.0/1000 * [self.distance floatValue] >= 100)		return @"100k";
	if (1.0/1000 * [self.distance floatValue] >= 42.195)	return @"FULL";
	if (1.0/1000 * [self.distance floatValue] >= 30)		return @"30K";
	if (1.0/1000 * [self.distance floatValue] >= 25)		return @"25K";
	if (1.0/1000 * [self.distance floatValue] >= 21.097)	return @"HALF";
	if (1.0/1000 * [self.distance floatValue] >= 20)		return @"20K";
	if (1.0/1000 * [self.distance floatValue] >= 16.09)		return @"10M";
	if (1.0/1000 * [self.distance floatValue] >= 16)		return @"16K";
	if (1.0/1000 * [self.distance floatValue] >= 15)		return @"15K";
	if (1.0/1000 * [self.distance floatValue] >= 12)		return @"12K";
	if (1.0/1000 * [self.distance floatValue] >= 10)		return @"10K";
	if (1.0/1000 * [self.distance floatValue] >= 8.046)		return @"5M";
	if (1.0/1000 * [self.distance floatValue] >= 8)			return @"8K";
	if (1.0/1000 * [self.distance floatValue] >= 5)			return @"5K";
	if (1.0/1000 * [self.distance floatValue] >= 4.827)		return @"3M";
	if (1.0/1000 * [self.distance floatValue] >= 4)			return @"4K";
	if (1.0/1000 * [self.distance floatValue] >= 3.218)		return @"2M";
	if (1.0/1000 * [self.distance floatValue] >= 3)			return @"3K";
	if (1.0/1000 * [self.distance floatValue] >= 2)			return @"2K";
	if (1.0/1000 * [self.distance floatValue] >= 1.609)		return @"1M";
	if (1.0/1000 * [self.distance floatValue] >= 1)			return @"1K";
	
	return retval;
}

@end
