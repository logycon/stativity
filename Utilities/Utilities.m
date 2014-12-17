//
//  Utilities.m
//  HUDMediaApp
//
//  Created by Omnitec Solutions Inc on 5/17/12.
//  Copyright (c) 2012 Omnitec Solutions Inc All rights reserved.
//

#import "Utilities.h"
#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "Me.h"

@implementation Utilities

+(BOOL)isTwitterAvailable {
   return NSClassFromString(@"TWTweetComposeViewController") != nil;
}

+(BOOL)isSocialAvailable {
    return NSClassFromString(@"SLComposeViewController") != nil;
}

+(UIViewController *) getActiveViewController {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	UIWindow * mainWindow = [[UIApplication sharedApplication].windows objectAtIndex: 0];
	
	// using ViewDeck
	IIViewDeckController * rootController = (IIViewDeckController *) mainWindow.rootViewController;
	UITabBarController * tabbar = (UITabBarController *) rootController.centerController;
	UIViewController * currentTab = [tabbar selectedViewController];
	return currentTab; // UINavigationController
	
}

+(void) startNetworkActivity {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
+(void) stopNetworkActivity {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

+(NSString *) fontFamily {
	//return @"Knockout-HTF52-Cruiserweight";
	//return @"PTF-NORDIC-Standard";
	//return @"PTF-NORDIC-Round";
	//return @"Arial Rounded MT Bold";
	return @"HelveticaNeue-Bold";
	//return @"BebasNeue";
}

+(NSString *) fontFamilyRegular {
	return @"HelveticaNeue";
	//return @"BebasNeue";
}

+(int) getNumberOfDaysAgo:(NSDate *)date {
	NSTimeInterval seconds = [[Utilities currentLocalTime] timeIntervalSinceDate: date];
	int retval = seconds / 86400;
	return retval;
}

+ (NSString *) getTimeFromDate:(NSDate *)date {
	NSString * retval = @"?";
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
	unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |NSDayCalendarUnit | NSHourCalendarUnit;
	
	NSDateComponents * dateComp = [gregorian components: flags fromDate: date];
	
	NSDateComponents * diff = [gregorian 
		components: flags 
		fromDate: date 
		toDate: [Utilities currentLocalTime]
		options:0];
		
	NSDateComponents * today = [gregorian components: flags fromDate: [Utilities currentLocalTime]];

	if (NO && ((dateComp.year == today.year) && (dateComp.month = today.month) && (dateComp.day == today.day))) {
		retval = @"Today";
	}
	else {
		if (diff.year > 0) {
			if (diff.year == 1) {
				retval = [NSString stringWithFormat:@"%d year ago" , diff.year];
			}
			else {
				retval = [NSString stringWithFormat:@"%d years ago" , diff.year];
			}
		}
		else {
			if (diff.month > 0) {
				if (diff.month == 1) {
					retval = [NSString stringWithFormat: @"%d month ago", diff.month];
				}
				else {
					retval = [NSString stringWithFormat: @"%d months ago", diff.month];
				}
			}
			else {
				if (diff.day > 0) {
					if (diff.day == 1) {
						retval = [NSString stringWithFormat: @"%d day ago", diff.day];
					}
					else {
						retval = [NSString stringWithFormat: @"%d days ago", diff.day];
					}
				}
				else {
					if (diff.hour > 0) {
						retval = @"Less than a day ago";
						/*
						if (diff.hour == 1) {
							retval = [NSString stringWithFormat: @"%d hour ago", diff.hour];
						}
						else {
							retval = [NSString stringWithFormat: @"%d hours ago", diff.hour];
						}*/
					}
					else {
						retval = @"< Less than an hour ago";
						/*
						if (diff.minute == 1) {
							retval = [NSString stringWithFormat: @"%d minute ago", diff.minute];
						}
						else {
							retval = [NSString stringWithFormat: @"%d minutes ago", diff.minute];
						}*/
					}
				}
			}
		}
	}
	return retval;
}


// received time as string and returns string
// in the "ago" format 
// @"yyyy-MM-dd'T'HH:mm:ss+0000" - facebook format
// @"EEE MM dd HH:mm:ss+0000" - twitter format
+(NSString *) getTimeFromNow:(NSString *)fromDate withFormat:(NSString *)format {
//	fromDate = [fromDate stringByReplacingOccurrencesOfString:@"+0000" withString:@""];
	NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat : format];
	[fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *date = [fmt dateFromString:fromDate];
	return [Utilities getTimeFromDate: date];
}

+(NSString*) getDateAsString:(NSDate *)date withFormat:(id)format {
	NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat : format];
	[fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString * retval = [fmt stringFromDate: date];
	return retval;
}

+(NSDate *) getFirstDayOfWeek:(NSDate *)date {
	// assuming week starts on Sunday = 1
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	
	NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	int daysToAdd = -1 * components.weekday +1; // instead of + 1
	NSDate * retval = [date dateByAddingTimeInterval: 60 * 60 * 24 * daysToAdd];

	NSTimeZone * tz = [NSTimeZone defaultTimeZone];
	int hrsDiff = tz.secondsFromGMT / ( 60 * 60 );
	components = [gregorian components : NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:retval];
	[components setHour:hrsDiff];
	[components setMinute:0];
	[components setSecond:0];
	retval = [gregorian dateFromComponents: components];
	[NSTimeZone resetSystemTimeZone];
	return retval;
}

+(NSDate *) getLastDayOfWeek:(NSDate *)date {
	NSDate * firstDay = [Utilities getFirstDayOfWeek: date];
	NSDate * retval = [firstDay dateByAddingTimeInterval: 60 * 60 * 24 * 7 - 1];
	return retval;
}

+(NSDate *) getLastDayOfPreviousWeek:(NSDate *) date {
	date = [Utilities getFirstDayOfWeek: date];
	NSDate * retval = [date dateByAddingTimeInterval : -1]; // add 1 second
	return retval;
}

+(NSDate *) getFirstDayOfPreviousMonth:(NSDate *)date {
	date = [Utilities getFirstDayOfMonth: date];
	date = [date dateByAddingTimeInterval: -1];
	NSDate * retval = [Utilities getFirstDayOfMonth: date];
	return retval;
}

+(NSDate *) getFirstDayOfPreviousWeek:(NSDate *) date {
	date = [Utilities getFirstDayOfWeek: date];
	//date = [date dateByAddingTimeInterval: -1];
	//NSDate * retval = [Utilities getFirstDayOfWeek : date];
	//return retval;
	int daysToAdd = -7;
	NSDate * retval = [date dateByAddingTimeInterval: 60 * 60 * 24 * daysToAdd];
	return retval;
}


+(NSDate *) getLastDayOfPreviousMonth:(NSDate *)date {
	date = [Utilities getFirstDayOfMonth: date];
	NSDate * retval = [date dateByAddingTimeInterval: -1];
	return retval;
}

+(NSDate *) currentLocalTime {
	NSDate * gmt = [NSDate date];
	NSTimeZone *tz = [NSTimeZone defaultTimeZone];
	NSInteger seconds = [tz secondsFromGMTForDate: gmt];
	[NSTimeZone resetSystemTimeZone];
	return [NSDate dateWithTimeInterval: seconds sinceDate: gmt];
}

+(NSDate *) currentLocalDate {
	NSDate * now = [Utilities currentLocalTime];
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDateComponents * components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:now];
	[components setHour: 0];
	[components setMinute: 0];
	[components setSecond: 0];
	NSDate * retval = [gregorian dateFromComponents: components];
	return retval;
}

+(NSDate *) startOfDateFromDateTime:(NSDate *)dateTime  {
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDateComponents * components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate: dateTime];
	[components setHour: 0];
	[components setMinute: 0];
	[components setSecond: 0];
	NSDate * retval = [gregorian dateFromComponents: components];
	return retval;
}

+(NSDate *) endOfDateFromDateTime:(NSDate *)dateTime {
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDateComponents * components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate: dateTime];
	[components setHour: 23];
	[components setMinute: 59];
	[components setSecond: 59];
	NSDate * retval = [gregorian dateFromComponents: components];
	return retval;
}

+(BOOL) isDateInRange:(NSDate *)date :(NSDate *)from :(NSDate *)to {
    if (
		([date compare: from] == NSOrderedDescending) // later than start
		&&
		([date compare: to] == NSOrderedAscending) // earlier than end
   ) {
		return YES;
   }
   else {
		return NO;
   }
	
}

+(NSDate *) getEndOfToday {
	NSDate * now = [Utilities currentLocalTime];
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	//NSTimeZone * tz = [NSTimeZone defaultTimeZone];
	[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDateComponents * components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:now];
	[components setHour: 23];
	[components setMinute: 59];
	[components setSecond: 59];
	NSDate * retval = [gregorian dateFromComponents: components];
	return retval;
}

+(NSDate *) getFirstDayOfMonth:(NSDate *)date {
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
	NSString * jan1 = [NSString stringWithFormat: @"%d/%d/01", components.year, components.month];
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setDateFormat: @"yyyy/MM/dd"];
	[df setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate * retval = [df dateFromString: jan1];
	return retval;
}

+(NSDate *) getLastDayOfMonth: (NSDate *) date {
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	[gregorian setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
	NSDateComponents * components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate: date];
	
	int newYear = components.year;
	int newMonth = components.month + 1;
	
	if (components.month == 12) {
		newYear = components.year + 1;
		newMonth = 1;
	}
	
	components.year = newYear;
	components.month = newMonth;
	components.day = 1;
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	
	NSDate * firstOfNextMonth = [gregorian dateFromComponents: components];
	
	// roll 1 second back into the previous month
	NSDate * retval = [firstOfNextMonth dateByAddingTimeInterval: -1];
	return retval;

}

+(NSDate *) getFirstDayOfYear:(NSDate *)date {
	NSCalendar * gregorian = [NSCalendar currentCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *components = [gregorian components: NSYearCalendarUnit fromDate:date];
	NSString * jan1 = [NSString stringWithFormat: @"%d/01/01", components.year];
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setDateFormat: @"yyyy/MM/dd"];
	[df setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate * retval = [df dateFromString: jan1];
	return retval;
} 

+(NSDate *) getFirstDayOfPreviousYear:(NSDate *)date {
	NSDate * jan1 = [Utilities getFirstDayOfYear: date];
	NSDate * dec31 = [jan1 dateByAddingTimeInterval: -1];
	NSDate * retval = [Utilities getFirstDayOfYear: dec31];
	return retval;
}

+(NSDate *) getLastDayOfPreviousYear:(NSDate *)date {
	NSDate * jan1 = [Utilities getFirstDayOfYear:date];
	NSDate * retval = [jan1 dateByAddingTimeInterval: -1];
	return retval;
}

// Based on hints from http://stackoverflow.com/questions/1850824/parsing-a-rfc-822-date-with-nsdateformatter
+ (NSDate *)dateFromRFC1123String:(NSString *)string
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	// Does the string include a week day?
	NSString *day = @"";
	if ([string rangeOfString:@","].location != NSNotFound) {
		day = @"EEE, ";
	}
	// Does the string include seconds?
	NSString *seconds = @"";
	if ([[string componentsSeparatedByString:@":"] count] == 3) {
		seconds = @":ss";
	}
	[formatter setDateFormat:[NSString stringWithFormat:@"%@dd MMM yyyy HH:mm%@ z",day,seconds]];
	return [formatter dateFromString:string];
}


+(NSString *) getSecondsAsDuration:(float)seconds {
	int days = floor(seconds / 86400.0);
	int hours = floor((seconds - days * 86400.0) / 3600.0);
	int minutes = floor((seconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int sec = floor(seconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%d days %d hrs", days, hours];
	}
		else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%d hrs %d min", hours, minutes];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%d min %d sec", minutes, sec];
		} 
	}
	return strDuration;
}

+(NSString *) getSecondsAsDurationShort:(float)seconds {
	int days = floor(seconds / 86400.0);
	int hours = floor((seconds - days * 86400.0) / 3600.0);
	int minutes = floor((seconds - days * 86400.0 - hours  * 3600.0) / 60.0);
	int sec = floor(seconds - days * 86400.0 - hours * 3600.0 - minutes * 60.0);
	NSString * strDuration = @"";
	if (days > 0) {
		strDuration = [NSString stringWithFormat: @"%d d %d h", days, hours];
	}
		else {
		if (hours > 0) {
			strDuration = [NSString stringWithFormat: @"%d:%02d\"%02d'", hours, minutes, sec];
			
		}
		else {
			strDuration = [NSString stringWithFormat: @"%d\"%02d'", minutes, sec];
		} 
	}
	return strDuration;
}

+(NSString*)ordinalNumberFormat:(NSInteger)num{
    NSString *ending;

    int ones = num % 10;
    int tens = floor(num / 10);
    tens = tens % 10;
    if(tens == 1){
        ending = @"th";
    }else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    return [NSString stringWithFormat:@"%d%@", num, ending];
}

@end
