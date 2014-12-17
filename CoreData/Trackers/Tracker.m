//
//  Tracker.m
//  Stativity
//
//  Created by Igor Nakshin on 8/18/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "Tracker.h"
#import "RunKeeper.h"
#import "Endomondo.h"
#import "Garmin.h"

@implementation Tracker

+(BOOL) connected {
	BOOL retval = NO;
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = YES;
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = YES;
		}
		else {
			Garmin * g = [Garmin sharedInstance];
			if ([g connected]) {
				retval = YES;
			}
		}
	}
	return retval;
}

+(int) getFitnessActivities : (NSString *) ofType {
	int retval = 0;
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = [rk getFitnessActivities: ofType];
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = [en getFitnessActivities: ofType];
		}
		else {
			Garmin * g = [Garmin sharedInstance];
			if ([g connected]) {
				retval = [g getFitnessActivities: ofType];
			}
		}
		
	}
	return retval;
}

+(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type {
	int retval = 0;
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = [rk getFitnessActivitiesAfter: date ofType: type];
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = [en getFitnessActivitiesAfter: date ofType: type];
		}
		else {
			Garmin * g = [Garmin sharedInstance];
			if ([g connected]) {
				retval = [g getFitnessActivitiesAfter: date ofType: type];
			}
		}
	}
	
	return retval;
}

+(NSString *) getTrackerIconName {
	NSString * retval = @"";
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = @"icon_runkeeper.png";
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = @"icon_endomondo.png";
		}
		else {
			Garmin * g = [Garmin sharedInstance];
			if ([g connected]) {
				retval = @"icon_garmin.png";
			}
		}
	}
	
	return retval;
}

+(NSArray *) getActivityDetail : (NSString *) uri {
	NSArray * retval = [[NSArray alloc] init];
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = [rk getActivityDetail: uri];
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = [en getActivityDetail: uri];
		}
		else {
			Garmin * g = [Garmin sharedInstance];
			if ([g connected]) {
				retval = [g getActivityDetail: uri];
			}
		}
	}
	
	return retval;
}

+(NSString *) getTrackerHashTag {
	NSString * retval = @"#Stativity";
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = @"#RunKeeper";
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = @"#Endomondo";
		}
		else {
			Garmin * g = [Garmin sharedInstance];
			if ([g connected]) {
				retval = @"#Garmin";
			}
		}
	}
	
	return retval;
}


@end
