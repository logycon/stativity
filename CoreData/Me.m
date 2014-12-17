//
//  NikePlus.m
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "Me.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "Utilities.h"
#import "RunKeeper.h"
#import "StativityData.h"
#import "Activity.h"


@implementation Me

UIColor * interfaceColor;

+(BOOL) getElite {
	NSString * selite = [[NSUserDefaults standardUserDefaults] objectForKey: @"elite"];
	if (selite) {
		BOOL elite = [selite boolValue];
		return elite;
	}
	else return NO;
}

+(void) setElite:(BOOL)elite {
	NSString * selite = (elite) ? @"Y" : @"N";
	[[NSUserDefaults standardUserDefaults] setObject: selite forKey: @"elite"];
	[[NSUserDefaults standardUserDefaults] synchronize];
} 

+(NSString *) getHomeScreenImageName {
	NSString * retval = [[NSUserDefaults standardUserDefaults] objectForKey: @"HomeScreenImage"];
	if (!retval) {
		retval = @"road.png";
		//retval = @"default.png";
	}
	return retval;
}

+(void) setHomeScreenImage : (NSString *) path {
	[[NSUserDefaults standardUserDefaults] setObject: path forKey: @"HomeScreenImage"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *) getHomeImageOpacity {
	NSNumber * retval = [[NSUserDefaults standardUserDefaults] objectForKey: @"HomeImageOpacity"];
	if (!retval) {
		retval = [NSNumber numberWithFloat: 0.35];
	}
	return retval;
}

+(void) setHomeImageOpacity:(NSNumber *)opacity {
	[[NSUserDefaults standardUserDefaults] setObject: opacity forKey: @"HomeImageOpacity"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

+(void) setTotalRuns:(NSNumber *)theRuns {
	[[NSUserDefaults standardUserDefaults] setObject: theRuns forKey:@"TotalRuns"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *) getTotalRuns {
	NSString * retval = [[NSUserDefaults standardUserDefaults] objectForKey: @"TotalRuns"];
	if (retval == nil) {
		return @"";
	}
	else {
		return retval;
	}
}

// W = week, M = month, Y = year, L = lifetime
+(void) setMyTimeframe:(NSString *)theTimeframe {
	[[NSUserDefaults standardUserDefaults] setObject : theTimeframe forKey : @"MyTimeframe"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// notify
	[[NSNotificationCenter defaultCenter] 
		postNotificationName : @"TimeframeChanged" 
		object : theTimeframe];
}

+(NSString *) getMyTimeframe {
	NSString * retval = [[NSUserDefaults standardUserDefaults] objectForKey: @"MyTimeframe"];
	if (retval == nil) {
		return @"W";
	}
	else return retval;
}

+(Timeframe) toTimeframe:(NSString *)theTimeframe {
	Timeframe retval = AllTime;
	if ([theTimeframe isEqualToString: @"T"]) retval = Today;
	if ([theTimeframe isEqualToString: @"W"]) retval = ThisWeek;
	if ([theTimeframe isEqualToString: @"M"]) retval = ThisMonth;
	if ([theTimeframe isEqualToString: @"Y"]) retval = ThisYear;
	if ([theTimeframe isEqualToString: @"LW"]) retval = LastWeek;
	if ([theTimeframe isEqualToString: @"LM"]) retval = LastMonth;
	if ([theTimeframe isEqualToString: @"LY"]) retval = LastYear;
	if ([theTimeframe isEqualToString: @"D7"]) retval = Days7;
	if ([theTimeframe isEqualToString: @"D14"]) retval = Days14;
	if ([theTimeframe isEqualToString: @"D30"]) retval = Days30;
	if ([theTimeframe isEqualToString: @"D60"]) retval = Days60;
	if ([theTimeframe isEqualToString: @"D90"]) retval = Days90;
	if ([theTimeframe isEqualToString: @"L"]) retval = AllTime;
	return retval;
}

+(NSString *) fromTimeframe:(Timeframe)theTimeframe {
	NSString * retval = @"A";
	switch(theTimeframe) {
		case Today : { retval = @"T"; break; }
		case ThisWeek : { retval = @"W"; break; }
		case ThisMonth : { retval = @"M"; break; }
		case ThisYear : { retval = @"Y"; break; }
		case LastWeek : { retval = @"LW"; break; }
		case LastMonth : { retval = @"LM"; break; }
		case LastYear : { retval = @"LY"; break; }
		case Days7 : { retval = @"D7"; break; }
		case Days14 :  { retval = @"D14"; break; }
		case Days30 : { retval = @"D30"; break; }
		case Days60 : { retval = @"D60"; break; }
		case Days90 : { retval = @"D90"; break; }
		case AllTime : { retval = @"L"; break; }
	}
	return retval;
}

+(Timeframe) getTimeframe {
	NSString * tf = [Me getMyTimeframe];
	return [Me toTimeframe: tf];
}

+(void) setTimeframe:(Timeframe)theTimeframe {
	NSString * tf = [Me fromTimeframe : theTimeframe ];
	[Me setMyTimeframe: tf];
}

+(NSDate *) getPrevTimeframeStart {
	NSDate * retval = [Utilities currentLocalTime];
	Timeframe timeframe = [Me getTimeframe];
	switch (timeframe) {
		case Today : {
			retval = [Utilities getFirstDayOfWeek: [Utilities currentLocalTime]];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2)  // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
			break;
		}
		
		case ThisWeek : {
			retval = [Utilities getFirstDayOfPreviousWeek: retval];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
			break;
		}
		
		case ThisMonth : {
			retval = [Utilities getFirstDayOfPreviousMonth : retval];
			break;
		}
		
		case ThisYear: {
			retval = [Utilities getFirstDayOfPreviousYear: retval];
			break;
		}
		
		case LastWeek : {
			NSDate * lastDayOfPrevious = [Utilities getLastDayOfPreviousWeek: [Utilities currentLocalTime]];
			NSDate * retval = [Utilities getFirstDayOfPreviousWeek : lastDayOfPrevious];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
			}
			break;
		}
		
		case LastMonth : {
			NSDate * lastDayOfPrevious = [Utilities getLastDayOfPreviousMonth: [Utilities currentLocalTime]];
			retval = [Utilities getFirstDayOfPreviousMonth : lastDayOfPrevious];
			break;
		}
		
		case Days7 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-14)];
			break;
		}
		
		case Days14 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-30)];
			break;
		}
		
		case Days30 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-60)];
			break;
		}
		
		case Days60 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-120)];
			break;
		}
		
		case Days90 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-180)];
			break;
		}
		
		case AllTime : {
			NSDateComponents * comp = [[NSDateComponents alloc] init];
			comp.year = 1900;
			comp.month = 1;
			comp.day = 1;
			
			NSCalendar * gregorian = [NSCalendar currentCalendar];
			retval = [gregorian dateFromComponents: comp];
			break;
		}
		
		default : {
			// nothing
			break;
		}
	}
	return retval;
}

/*
+(NSDate *) getPrevTimeframeStartOld {
	NSDate * retval = [Utilities currentLocalTime];
	NSString * timeframe = [Me getMyTimeframe];
	if ([timeframe isEqualToString : @"T"]) {
		retval = [Utilities getFirstDayOfWeek: [Utilities currentLocalTime]];
		int firstDOW = [Me getFirstDayOfWeek];
		if (firstDOW == 2) { // move to monday
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
		}
	}
	else {
	
		if ([timeframe isEqualToString: @"W"]) {
			retval = [Utilities getFirstDayOfPreviousWeek: retval];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
		}
		else {
			if ([timeframe isEqualToString: @"M"]) {
				retval = [Utilities getFirstDayOfPreviousMonth : retval];
			}
			else {
				if ([timeframe isEqualToString: @"Y"]) {
					retval = [Utilities getFirstDayOfPreviousYear: retval];
				}
				else {
					if ([timeframe isEqualToString: @"L"]) {
						NSDateComponents * comp = [[NSDateComponents alloc] init];
						comp.year = 1900;
						comp.month = 1;
						comp.day = 1;
						
						NSCalendar * gregorian = [NSCalendar currentCalendar];
						return [gregorian dateFromComponents: comp];
					}
					else {
						if ([timeframe isEqualToString: @"LW"]) { // last week
							NSDate * lastDayOfPrevious = [Utilities getLastDayOfPreviousWeek: [Utilities currentLocalTime]];
							NSDate * retval = [Utilities getFirstDayOfPreviousWeek : lastDayOfPrevious];
							int firstDOW = [Me getFirstDayOfWeek];
							if (firstDOW == 2) { // move to monday
								retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
							}
							return retval;
						}
						else {
							if ([timeframe isEqualToString: @"LM"]) { // last month
								NSDate * lastDayOfPrevious = [Utilities getLastDayOfPreviousMonth: [Utilities currentLocalTime]];
								NSDate * retval = [Utilities getFirstDayOfPreviousMonth : lastDayOfPrevious];
								return retval;
							}
						}
					}
				}
			}
		}
	}
	return retval;
}
*/

+(NSString *) getTimeframeText {
	NSString * retval = @"";
	NSString * timeframe = [Me getMyTimeframe];
	NSDate * start = [Me getTimeframeStart];
	NSDate * end = [Me getTimeframeEnd];
	if ([timeframe isEqualToString: @"T"]) {
		retval = [Utilities getDateAsString: start withFormat: @"EEEE, MMMM d yyyy"];
	}
	else {
		// for all time we need to get start from first activity ever
		if ([timeframe isEqualToString: @"L"]) {
			StativityData * rkd = [StativityData get];
			Activity * firstActivity = [rkd getFirstActivity];
			if (rkd != nil) {
				start = firstActivity.start_time;
			}
		}
	
		start = [start dateByAddingTimeInterval:1]; // we set start 1 second back 
		NSCalendar * gregorian = [NSCalendar currentCalendar];
		[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
		NSDateComponents * startComponents = [gregorian components: NSYearCalendarUnit fromDate: start];
		NSDateComponents * endComponents = [gregorian components: NSYearCalendarUnit fromDate:end];
	
		// default assumes same year
		NSString * startFormat = @"MMMM d";
		NSString * endFormat = @"MMMM d yyyy";
		
		int startYear = startComponents.year;
		int endYear = endComponents.year;
		
		if (startYear != endYear) { // include year in both start and end
			startFormat = @"MMMM d yyyy";
			endFormat = @"MMMM d yyyy";
		}
	
		retval = [NSString stringWithFormat: @"%@ - %@",
			[Utilities getDateAsString: start withFormat: startFormat],
			[Utilities getDateAsString: end   withFormat: endFormat]
		];
		
	}

	return retval;
}

+(NSDate *) getTimeframeStart {
	NSDate * retval = [Utilities currentLocalTime];
	Timeframe timeframe = [Me getTimeframe];
	switch (timeframe) {
		case Today : {
			retval = [Utilities currentLocalDate];
			break;
		}
		
		case ThisWeek : {
			retval = [Utilities getFirstDayOfWeek: retval];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
			break;
		}
		
		case ThisMonth : {
			retval = [Utilities getFirstDayOfMonth : retval];
			break;
		}
		
		case ThisYear : {
			retval = [Utilities getFirstDayOfYear: retval];
			break;
		}
		
		case AllTime : {
			NSDateComponents * comp = [[NSDateComponents alloc] init];
			comp.year = 1900;
			comp.month = 1;
			comp.day = 1;
			
			NSCalendar * gregorian = [NSCalendar currentCalendar];
			return [gregorian dateFromComponents: comp];
			break;
		}
		
		case Days7 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
			break;
		}
		
		case Days14 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-14)];
			break;
		}
		
		case Days30 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-30)];
			break;
		}
		
		case Days60 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-60)];
			break;
		}
		
		case Days90 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-90)];
			break;
		}
	
		default : {
			break;
		}
	}
	
	return retval;
}

/*
+(NSDate *) getTimeframeStartOld {
	NSDate * retval = [Utilities currentLocalTime];
	NSString * timeframe = [Me getMyTimeframe];
	if ([timeframe isEqualToString: @"T"]) {
		retval = [Utilities currentLocalDate];
	}
	else {
		if ([timeframe isEqualToString: @"W"]) {
			retval = [Utilities getFirstDayOfWeek: retval];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
		}
		else {
			if ([timeframe isEqualToString: @"M"]) {
				retval = [Utilities getFirstDayOfMonth : retval];
			}
			else {
				if ([timeframe isEqualToString: @"Y"]) {
					retval = [Utilities getFirstDayOfYear: retval];
				}
				else {
					if ([timeframe isEqualToString: @"L"]) {
						NSDateComponents * comp = [[NSDateComponents alloc] init];
						comp.year = 1900;
						comp.month = 1;
						comp.day = 1;
						
						NSCalendar * gregorian = [NSCalendar currentCalendar];
						return [gregorian dateFromComponents: comp];
					}
					else {
						if ([timeframe isEqualToString: @"LW"]) { // last week
							NSDate * retval = [Utilities getFirstDayOfPreviousWeek:[Utilities currentLocalTime]];
							int firstDOW = [Me getFirstDayOfWeek];
							if (firstDOW == 2) { // move to monday
								retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
								NSCalendar * gregorian = [NSCalendar currentCalendar];
								[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
								NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit fromDate: [Utilities currentLocalTime]];
								if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
									retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
								}
							}
							return retval;
						}
						else {
							if ([timeframe isEqualToString: @"LM"]) { // last month
								NSDate * retval = [Utilities getFirstDayOfPreviousMonth : [Utilities currentLocalTime]];
								return retval;
							}
						}
					}
				}
			}
		}
	}
	return retval;
}
*/

+(NSDate *) getTimeframeEnd {
	Timeframe tf = [Me getTimeframe];
	NSDate * retval = [Utilities getEndOfToday];
	
	switch (tf) {
		case ThisWeek : {
			retval = [Utilities getLastDayOfWeek :[Utilities currentLocalTime]];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) ) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
			break;
		}
		
		case LastWeek : {
			retval = [Utilities getLastDayOfPreviousWeek:[Utilities currentLocalTime]];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) ) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
			break;
		}
	
		case LastMonth : {
			retval = [Utilities getLastDayOfPreviousMonth : [Utilities currentLocalTime]];
			break;
		}
		
		default : {
			break; // today
		}
	}
	
	return retval;
	
}


/*
+(NSDate *) getTimeframeEndOld {
	NSString * timeFrame = [Me getMyTimeframe];
	if ([timeFrame isEqualToString: @"LM"]) {
		NSDate * to = [Utilities getLastDayOfPreviousMonth : [Utilities currentLocalTime]];
		return to;
	}
	else {
		if ([timeFrame isEqualToString : @"W"]) {
			NSDate * retval = [Utilities getLastDayOfWeek :[Utilities currentLocalTime]];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) ) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}

			return retval;
		}
		else {
			if ([timeFrame isEqualToString: @"LW"]) {
				NSDate * retval = [Utilities getLastDayOfPreviousWeek:[Utilities currentLocalTime]];
				int firstDOW = [Me getFirstDayOfWeek];
				if (firstDOW == 2) { // move to monday
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
					
					NSCalendar * gregorian = [NSCalendar currentCalendar];
					[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
					NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
					if ((components.weekday == 1) ) { // if today is sunday (1) and firstDow is monday (2) then move back a week
						retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
					}
				}
				return retval;
			}
			else { // for everything that' ending today
				//NSDate * retval = [Utilities currentLocalTime]; // now
			
				NSDate * retval = [Utilities getEndOfToday];
				//NSString * timeframe = [NikePlus getMyTimeframe];
				return retval;
			}
		}
	}
}
*/

+(NSDate *) getPrevTimeframeEnd {
	NSDate * retval = [Utilities currentLocalTime];
	Timeframe tf = [Me getTimeframe];
	
	switch(tf) {
		case Today : {
			NSDate * today = [Utilities currentLocalDate];
			retval = [today dateByAddingTimeInterval: 60 * 60 * 24 - 1];
			break;
		}
		
		case ThisWeek : {
			retval = [Utilities getLastDayOfPreviousWeek: retval];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
			
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
			break;
		}
		
		case ThisMonth: {
			retval = [Utilities getLastDayOfPreviousMonth : retval];
			break;
		}
		
		case ThisYear : {
			retval = [Utilities getLastDayOfPreviousYear: retval];
			break;
		}
		
		case AllTime : {
			retval = [Utilities getEndOfToday];
			break;
		}
		
		case LastWeek : {
			NSDate * firstDayOfPrevious = [Utilities getLastDayOfPreviousWeek: [Utilities currentLocalTime]];
			retval = [Utilities getLastDayOfPreviousWeek : firstDayOfPrevious];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
			break;
		}
		
		case LastMonth : {
			NSDate * firstDayOfPrevious = [Utilities getLastDayOfPreviousMonth: [Utilities currentLocalTime]];
			retval = [Utilities getLastDayOfPreviousMonth : firstDayOfPrevious];
			break;
		}
		
		case Days7 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
			break;
		}
		
		case Days14 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-14)];
			break;
		}
		
		case Days30 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-30)];
			break;
		}
		
		case Days60 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-60)];
			break;
		}
		
		case Days90 : {
			retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-90)];
			break;
		}
		
		default : {
			// break;
		}
	}
	
	return retval;
}

/*
+(NSDate *) getPrevTimeframeEndOld {
	NSDate * retval = [Utilities currentLocalTime];
	NSString * timeframe = [Me getMyTimeframe];
	if ([timeframe isEqualToString: @"T"]) {
		NSDate * today = [Utilities currentLocalDate];
		//NSDate * yesterday = [today dateByAddingTimeInterval: -1];
		retval = [today dateByAddingTimeInterval: 60 * 60 * 24 - 1];
		return retval;
	}
	else {
		if ([timeframe isEqualToString: @"W"]) {
			retval = [Utilities getLastDayOfPreviousWeek: retval];
			int firstDOW = [Me getFirstDayOfWeek];
			if (firstDOW == 2) { // move to monday
				retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
			
				NSCalendar * gregorian = [NSCalendar currentCalendar];
				[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
				if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
					retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
				}
			}
		}
		else {
			if ([timeframe isEqualToString: @"M"]) {
				retval = [Utilities getLastDayOfPreviousMonth : retval];
			}
			else {
				if ([timeframe isEqualToString: @"Y"]) {
					retval = [Utilities getLastDayOfPreviousYear: retval];
				}
				else {
					if ([timeframe isEqualToString: @"L"]) {
						NSDate * retval = [Utilities getEndOfToday];
						return retval;
					}
					else {
						if ([timeframe isEqualToString: @"LW"]) { // last week
							NSDate * firstDayOfPrevious = [Utilities getLastDayOfPreviousWeek: [Utilities currentLocalTime]];
							NSDate * retval = [Utilities getLastDayOfPreviousWeek : firstDayOfPrevious];
							int firstDOW = [Me getFirstDayOfWeek];
							if (firstDOW == 2) { // move to monday
								retval = [retval dateByAddingTimeInterval: 60 * 60 * 24];
								NSCalendar * gregorian = [NSCalendar currentCalendar];
								[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
								NSDateComponents * components = [gregorian components: NSWeekdayCalendarUnit fromDate: [Utilities currentLocalTime]];
								if ((components.weekday == 1) && (firstDOW == 2)) { // if today is sunday (1) and firstDow is monday (2) then move back a week
									retval = [retval dateByAddingTimeInterval: 60 * 60 * 24 * (-7)];
								}
							}
							return retval;
						}
						else {
							if ([timeframe isEqualToString: @"LM"]) { // last month
								NSDate * firstDayOfPrevious = [Utilities getLastDayOfPreviousMonth: [Utilities currentLocalTime]];
								NSDate * retval = [Utilities getLastDayOfPreviousMonth : firstDayOfPrevious];
								return retval;
							}
						}
					}
				}
			}
		}
	}
	return retval;
}
*/

+(NSString *) getTimeFrameProperCased {
	NSString * retval = @"";
	Timeframe timeframe = [Me getTimeframe];
	switch(timeframe) {
		case Today : { retval = @"Today"; break; }
		case ThisWeek : { retval = @"This week"; break; }
		case ThisMonth : { retval = @"This month"; break; }
		case ThisYear : { retval = @"This year"; break; }
		case LastWeek : { retval = @"Last week"; break; }
		case LastMonth : { retval = @"Last month"; break; }
		case AllTime : { retval = @"All-Time"; break; }
		case Days7 : { retval = @"Last 7 days"; break; }
		case Days14 : { retval = @"Last 14 days"; break; }
		case Days30 : { retval = @"Last 30 days"; break; }
		case Days60 : { retval = @"Last 60 days"; break; }
		case Days90 : { retval = @"Last 90 days"; break; }
		default : {
			break;
		}
	}
	return retval;
}
	

+(NSString *) getTimeframeName {
	NSString * retval = [[Me getTimeFrameProperCased] uppercaseString];
	return retval;
}

+(NSString *) getTimeFrameFrequency {
	NSString * retval = @"";
	NSString * timeframe = [Me getMyTimeframe];
	if ([timeframe isEqualToString: @"T"]) {
		retval = @"Daily";
	}
	else {
		if ([timeframe isEqualToString: @"W"]) {
			retval = @"Weekly";
		}
		else {
			if ([timeframe isEqualToString: @"M"]) {
				retval = @"Monthly";
			}
			else {
				if ([timeframe isEqualToString: @"Y"]) {
					retval = @"Annual";
				}
				else {
					if ([timeframe isEqualToString: @"LW"]) {
						retval = @"";
					}
					else {
						if ([timeframe isEqualToString: @"LM"]) {
							retval = @"";
						}
						else {
							retval = @"All-Time";
						}
					}
				}
			}
		}
	}
	return retval;
}

+(BOOL) isTimeframeThis {	
	BOOL retval = NO;
	NSString * timeframe = [Me getMyTimeframe];
	if ([timeframe isEqualToString: @"T"] || [timeframe isEqualToString: @"Y"] || [timeframe isEqualToString: @"M"] || [timeframe isEqualToString: @"W"]) {
		retval = YES;
	}
	
	return retval;
}

+(NSString *) getPrevTimeframeName {
	NSString * retval = @"";
	//NSString * timeframe = [Me getMyTimeframe];
	Timeframe tf = [Me getTimeframe];
	
	switch(tf) {
		case Today : { retval = @"THIS WEEK"; break; }
		case ThisWeek : { retval = @"LAST WEEK"; break; }
		case ThisMonth : { retval = @"LAST MONTH"; break; }
		case ThisYear : { retval = @"LAST YEAR"; break; }
		case LastWeek : { retval = @"2 WEEKS AGO"; break; }
		case LastMonth : { retval = @"2 MONTHS AGO"; break; }
		case AllTime : { retval = @""; break; }
		case Days7 : { retval = @"PREV 7 DAYS"; break; }
		case Days14 : { retval = @"PREV 14 DAYS"; break; }
		case Days30 : { retval = @"PREV 30 DAYS"; break; }
		case Days60 : { retval = @"PREV 60 DAYS"; break; }
		case Days90 : { retval = @"PREV 90 DAYS"; break; }
		default : {
			break;
		}
	}
	return retval;
}



+(void) setMyID:(NSString *)theID {
	[[NSUserDefaults standardUserDefaults] setObject: theID forKey:@"NikePlusID"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *) getMyID {
	NSString * retval = [[NSUserDefaults standardUserDefaults] objectForKey: @"NikePlusID"];
	if (retval == nil) {
		return @"";
	}
	else {
		return retval;
	}
}


// K or M
+(void) setMyUnits:(NSString *)theUnits {
	[[NSUserDefaults standardUserDefaults] setObject : theUnits forKey : @"MyUnits"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName : @"TimeframeChanged" 
		object : nil];
}

+(NSString *) getMyUnits {
	NSString * retval = [[NSUserDefaults standardUserDefaults] objectForKey: @"MyUnits"];
	if (retval == nil) {
		return @"M"; // default to miles
	}
	else {
		return retval;
	}
}

// 1 or 2
+(void) setFirstDayOfWeek:(int)theDay {
	[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: theDay] forKey: @"FirstDayOfWeek"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(int) getFirstDayOfWeek {
	NSNumber * num = [[NSUserDefaults standardUserDefaults] objectForKey: @"FirstDayOfWeek"];
	if (num) {
		return [num intValue];
	}
	else {
		return 1;
	}
}

+(void) setTotalKM:(NSNumber *)theKM {
	[[NSUserDefaults standardUserDefaults] setObject: theKM forKey:@"TotalKM"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *) getTotalKM {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"TotalKM"];
	//return [NSNumber numberWithInt: 5002];
}

+(UIColor *) getTabBarColor {
	return [UIColor colorWithRed: 47/255. green: 49/255. blue: 50/255. alpha:1];
}

+(UIColor *) getUIColor {
	if (!interfaceColor) {
		interfaceColor = [Me getUIColorWithAlpha: 1];
	}
	return interfaceColor;
}

+(void) refreshUIColor {
	interfaceColor = [Me getUIColorWithAlpha: 1];
}

+(UIColor *) getUIColorWithAlpha:(float)alpha {
	StativityData * appData = [StativityData get];
	NSArray * runs = [appData fetchActivities: @"Running"];
	float totalDistance = 0;
	for(int i = 0; i < [runs count]; i++) {
		Activity * run = [runs objectAtIndex: i];
		totalDistance += [run.total_distance floatValue];
		
	}
	totalDistance = totalDistance / 1000;
	UIColor * retval = [UIColor colorWithRed:175/255. green:25/255. blue:5/255. alpha: alpha]; // deep red
	//retval = [UIColor colorWithRed:62/255. green:122/255. blue:148/255. alpha: alpha]; // deep red
	return retval;
	//retval = [UIColor colorWithRed:255/255. green:153/255. blue:51/255. alpha: alpha];
	//return retval;
	//UIColor * retval = [UIColor colorWithRed:51/255. green:164/255. blue:211/255. alpha:1];
	//UIColor * retval = [UIColor colorWithRed:89/255. green:83/255. blue:173/255. alpha:alpha];
	//return retval;
	//int totalDistance = [[Me getTotalKM] intValue];
	if (totalDistance > 0) {
		if (totalDistance < 50) retval = [UIColor colorWithRed:255/255. green:197/255. blue:0. alpha: alpha]; // yellow
		else if (totalDistance < 250) retval = [UIColor colorWithRed:255/255. green:138/255. blue:0. alpha: alpha]; //orange
			else if (totalDistance < 1000) retval = [UIColor colorWithRed:119/255. green:195/255. blue:0. alpha: alpha]; //green
				else if (totalDistance < 2500) retval = [UIColor colorWithRed:45/255. green:110/255. blue:186/255. alpha: alpha]; //blue
					else if (totalDistance < 5000) retval = [UIColor colorWithRed:89/255. green:83/255. blue:173/255. alpha:alpha]; //purple
						else retval = [UIColor colorWithRed:43/255. green:43/255. blue:43/255. alpha:alpha]; //black
	}
					
	return retval;
}

+(UIColor *) getTextColor {
	int intTotalKM = [[Me getTotalKM] intValue];
	if (intTotalKM == 0) {
		return [UIColor whiteColor];
	}
	UIColor * retval = nil;
	
	if (intTotalKM < 1000) { // yellow, orange, green = black
		retval = [UIColor colorWithRed:43/255. green:43/255. blue:43/255. alpha:1]; //black
	}
	else { // blue, purple, black = white
		retval = [UIColor whiteColor];
	}
	return retval;
}


/*
// URL to get the run
// http://nikeplus.nike.com/nikeplus/v1/services/app/get_run.jsp?id={runid}&userID={userid}
// http://nikeplus.nike.com/nikeplus/v1/services/app/get_run.jsp?userID=944839198&id=622031443

+(NSArray *) loadMyRuns : (id) sender {
	NSMutableArray * runs = [[NSMutableArray alloc] init];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString * surl = @"http://nikeplus.nike.com/nikeplus/v1/services/widget/get_public_run_list.jsp?userID=";
		//944839198
		
		NSString * myID = [Me getMyID];
		if (myID == @"") {
			[ActivityAlert dismiss];
			
			UIAlertView *message = [[UIAlertView alloc] 
				initWithTitle:@"Can't do this yet"
                message:@"Please set up your Nike+ ID first."
                delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
			[message show];
		}
		else {
			surl = [surl stringByAppendingString : [Me getMyID]];
			
			NSURL * url = [NSURL URLWithString: surl];
			CXMLDocument *xmlParser = [[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];

			dispatch_async(dispatch_get_main_queue(), ^{
				// runs
				NSArray * runNodes = [xmlParser nodesForXPath:@"//run" error:nil];
				for (int i = 0; i < [runNodes count]; i++) {	
					CXMLElement * resultElement = [runNodes objectAtIndex: i];
					NSMutableDictionary * runItem = [[NSMutableDictionary alloc] init];
					
					NSString * _id = [[resultElement attributeForName: @"id"] stringValue];
					NSString * _workoutType = [[resultElement attributeForName: @"workoutType"] stringValue];
					
					[runItem setObject : _id forKey: @"id"];
					[runItem setObject : _workoutType forKey : @"workoutType"];
					
					for(int counter = 0; counter < [resultElement childCount]; counter++) {
						[runItem 
							setObject:[[resultElement childAtIndex:counter] stringValue] 
							forKey:[[resultElement childAtIndex:counter] name]];
					}
					// Add the blogItem to the global blogEntries Array so that the view can access it.
					[runs addObject:[runItem copy]];
				}
				
				if ([runs count] > 0) {
					// summary
					NSArray * summaryNodes = [xmlParser nodesForXPath: @"//runListSummary" error: nil];
					CXMLElement * summaryItem = [summaryNodes objectAtIndex:0];

					NSString * totalRuns = [[summaryItem childAtIndex: 0] stringValue];
					NSString * totalKM = [[summaryItem childAtIndex: 1] stringValue ];
					//NSString * totalDuration = [[summaryItem childAtIndex :2] stringValue];

					[Me setTotalKM: [NSNumber numberWithFloat: [totalKM floatValue]]];
					[Me setTotalRuns: [NSNumber numberWithFloat: [totalRuns floatValue]]];
					
					
					// load into db
					NikeData * data = [NikeData get];
					
					[data loadRuns: [runs copy] fromSender: sender];
				}
				
				[ActivityAlert dismiss];

			});
		}
	});
	
	return [runs copy]; // array of dictionaries
}
*/


	
@end
