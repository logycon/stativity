//
//  Reminder.m
//  Stativity
//
//  Created by Igor Nakshin on 8/24/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "Reminder.h"
#import "StativityData.h"
#import "Utilities.h"

@implementation Reminder

+(void) showSample {
	NSNumber * reminderInterval = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_interval"];
	if (!reminderInterval) {
		reminderInterval = [NSNumber numberWithInt: 23];
	}
	
	StativityData * sd = [StativityData get];
	Activity * last = [sd getLastRun];

	NSString * aType = @"activity";
	if ([last.type isEqualToString: @"Running"]) aType = @"run";
	if ([last.type isEqualToString: @"Cycling"]) aType = @"biking";
	if ([last.type isEqualToString: @"Walking"]) aType = @"walk";
	
	UILocalNotification * notif = [[UILocalNotification alloc] init];
	notif.fireDate = [NSDate date];
	NSString * reminderBody = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_body"];
	//if (!reminderBody) {
		reminderBody = [NSString stringWithFormat: @"It's been %.0f hours since your last %@. Is it time to get active again?", [reminderInterval floatValue], aType];
	//}
	NSString * reminderTitle = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_title"];
	if (!reminderTitle) {
		reminderTitle = @"Get Active!";
	}
	
	notif.alertBody = reminderBody;
	notif.alertAction = reminderTitle;
	notif.soundName = UILocalNotificationDefaultSoundName;
			
	[[UIApplication sharedApplication] scheduleLocalNotification: notif];
}

+(void) updateReminder {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	NSString * reminderEnabled = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_enabled"];
	
	StativityData * sd = [StativityData get];
	Activity * last = [sd getLastActivity];
	if (last) {
		NSDate * lastDate = last.start_time;
		int numDays = [Utilities getNumberOfDaysAgo: lastDate];
		if (numDays <= 1) {
			NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
			NSTimeInterval gmtTimeInterval = [lastDate timeIntervalSinceReferenceDate] - timeZoneOffset;
			NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
		
			lastDate = gmtDate;
			
			NSNumber * reminderInterval = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_interval"];
			if (!reminderInterval) {
				reminderInterval = [NSNumber numberWithInt: 23];
			}
		
			NSDate * notificationTime = [lastDate dateByAddingTimeInterval: 60 * 60 * [reminderInterval intValue]]; // 
			UILocalNotification * localNotif = [[UILocalNotification alloc] init];
			localNotif.timeZone = [NSTimeZone systemTimeZone];
			if (localNotif == nil) return;
			localNotif.fireDate = notificationTime;
			
			NSString * aType = @"activity";
			if ([last.type isEqualToString: @"Running"]) aType = @"run";
			if ([last.type isEqualToString: @"Cycling"]) aType = @"biking";
			if ([last.type isEqualToString: @"Walking"]) aType = @"walk";
			
			NSString * reminderTitle = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_title"];
			if (!reminderTitle) {
				reminderTitle = @"Get Active!";
			}
			NSString * reminderBody = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_body"];
			//if (!reminderBody) {
				reminderBody = [NSString stringWithFormat : @"It's been %.0f hours since your last %@. Is it time to get active again?", [reminderInterval floatValue], aType];
			//}
			
			localNotif.alertBody = reminderBody;
			localNotif.alertAction = reminderTitle;
			localNotif.soundName = UILocalNotificationDefaultSoundName;
			
			if(reminderEnabled && [reminderEnabled isEqualToString: @"y"]) {
				[[UIApplication sharedApplication] scheduleLocalNotification: localNotif];
			}
			
			[[NSUserDefaults standardUserDefaults] setValue: localNotif.fireDate forKey: @"reminder_date"];
			[[NSUserDefaults standardUserDefaults] setValue: reminderBody forKey:  @"reminder_body"];
			[[NSUserDefaults standardUserDefaults] setValue: reminderTitle forKey: @"reminder_title"];
			[[NSUserDefaults standardUserDefaults] setValue: reminderInterval forKey : @"reminder_interval"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[NSTimeZone resetSystemTimeZone];
		}
	}
}

+(NSString *) getNextReminderDate {
	NSString * retval = @"Never";
	NSString * reminderEnabled = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_enabled"];
	if (reminderEnabled && [reminderEnabled isEqualToString: @"y"]) {
		NSDate * reminderDate = [[NSUserDefaults standardUserDefaults] objectForKey: @"reminder_date"];
		if (reminderDate) {
			NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"EEEE, MMMM dd yyyy hh:mm:ss a"];
			retval =[formatter stringFromDate: reminderDate];
		}
		else {
			retval = @"Never";
		}
	}
	else {
		retval = @"Reminders disabled";
	}
	return retval;
}

@end
