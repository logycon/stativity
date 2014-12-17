//
//  Endomondo.m
//  Stativity
//
//  Created by Igor Nakshin on 8/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "Endomondo.h"
#import "RunKeeper.h"
#import "MBProgressHUD.h"
#import "StativityData.h"
#import "Utilities.h"
#import "SBJsonParser.h"
#import "Flurry.h"
#import "Garmin.h"

@implementation Endomondo

Endomondo * _endomondo;
MBProgressHUD *HUD;

+(Endomondo *) sharedInstance {
	if (!_endomondo) {
		_endomondo = [[Endomondo alloc] init];
	}
	return _endomondo;
}

-(NSString *) getToken {
	NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey: @"endoToken"];
	return token;
}

-(void) setToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject: token forKey: @"endoToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	//NSLog(@"token set to %@", token);
}

-(BOOL) connected {
	NSString * token = [self getToken];
	BOOL retval =  (token && ![token isEqualToString: @""]);
	return retval;
}

-(void) disconnect {
	[self setToken: nil];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"connectedToEndo" object:nil];
}

-(void) connect {
	

}

-(NSString *) connectUser:(NSString *)email withPassword:(NSString *)password {
	NSString * retval = @"";
	
	NSString * strUrl = @"https://api.mobile.endomondo.com/mobile/auth?v=2.4&action=PAIR&email={email}&password={password}&country=USA&deviceId=iPhone&os=iOS&appVersion=1.0&appVariant=1.0&osVersion=5.1&model=a";
	strUrl = [strUrl stringByReplacingOccurrencesOfString: @"{email}" withString: email];
	strUrl = [strUrl stringByReplacingOccurrencesOfString: @"{password}" withString: password];
	NSURL * url = [NSURL URLWithString: strUrl];
	
	NSURLRequest * request = [[NSURLRequest alloc] initWithURL: url];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *responseData = [NSURLConnection 
		sendSynchronousRequest:request 
		returningResponse:&response 
		error:&error];
	
	if (!error) {
		NSString *resp = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		//NSLog(@"%@", resp);
		BOOL bError = NO;
		if ([resp isEqualToString: @"USER_EXISTS_PASSWORD_WRONG\n"]) {
			bError = YES;
			retval = @"Incorrect Password";
		}
		
		if ([resp isEqualToString: @"USER_UNKNOWN\n"]) {
			bError = YES;
			retval = @"Incorrect Email";
		}
		
		if (bError == NO) {
			retval = @""; // success
			
			NSString * authToken = @"";
			NSString * displayName = @"";
			NSString * secureToken = @"";
			NSArray * vals = [resp componentsSeparatedByString: @"\n"];
			for(int i = 0; i < [vals count]; i++) {
				NSArray * pair = [[vals objectAtIndex: i] componentsSeparatedByString: @"="];
				if ([pair count] == 2) {
					NSString * key = [pair objectAtIndex: 0];
					NSString * value = [pair objectAtIndex: 1];
					if ([key isEqualToString: @"authToken"]) {
						authToken = value;
					}
					if ([key isEqualToString: @"displayName"]) {
						displayName = value;
					}
					if ([key isEqualToString: @"secureToken"]) {
						secureToken = value;
					}
				}
			}
			
			if (![authToken isEqualToString: @""]) {
				[[NSUserDefaults standardUserDefaults] setObject: authToken forKey: @"endoToken"];
				[[NSUserDefaults standardUserDefaults] setObject: displayName forKey: @"endoDisplayName"];
				[[NSUserDefaults standardUserDefaults] setObject: secureToken forKey: @"endoSecureToken"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				retval = @"";
			}
			else {
				retval = @"Unexpected Response from Endomondo.";
			}
		}
	}
	else {
		retval = error.description;
	}
	
	return retval;
}

/*
		2:	'Cycling, sport',
		1:	'Cycling, transport',
		14:	'Fitness walking',
		15:	'Golfing',
		16:	'Hiking',
		9:	'Kayaking',
		10:	'Kite surfing',
		3:	'Mountain biking',
		17:	'Orienteering',
		19:	'Riding',
		5:	'Roller skiing',
		11:	'Rowing',
		0:	'Running',
		12:	'Sailing',
		4:	'Skating',
		6:	'Skiing, cross country',
		7:	'Skiing, downhill',
		8:	'Snowboarding',
		21:	'Spinning',
		20:	'Swimming',
		18:	'Walking',
		13:	'Windsurfing',
		22:	'Other',
		23:	'Aerobics',
		24:	'Badminton',
		25:	'Baseball',
		26:	'Basketball',
		27:	'Boxing',
		28:	'Climbing stairs',
		29:	'Cricket',
		30:	'Cross training',
		31:	'Dancing',
		32:	'Fencing',
		33:	'Football, American',
		34:	'Football, rugby',
		35:	'Football, soccer',
		49:	'Gymnastics',
		36:	'Handball',
		37:	'Hockey',
		48:	'Martial arts',
		38:	'Pilates',
		39:	'Polo',
		40:	'Scuba diving',
		41:	'Squash',
		42:	'Table tennis',
		43:	'Tennis',
		44:	'Volleyball, beach',
		45:	'Volleyball, indoor',
		46:	'Weight training',
		47:	'Yoga',
		50:	'Step counter'
*/
+(NSString *) sportToActivityType : (NSNumber * ) sport {
	NSString * retval = @"";
	
	if ([sport intValue] == 0) { // running
		retval = @"Running";
	}
	
	
	// cycling
	if ([sport intValue] == 1) {
		retval = @"Cycling";
	}
	if ([sport intValue] == 2) {
		retval = @"Cycling";
	}
	if ([sport intValue] == 3) {
		retval = @"Cycling";
	}
	
	// walking
	if ([sport intValue] == 14) {
		retval = @"Walking";
	}
	if ([sport intValue] == 16) {
		retval = @"Walking";
	}
	if ([sport intValue] == 18) {
		retval = @"Walking";
	}
	
	return retval;
	
}

-(int) getFitnessActivities : (NSString *) ofType {
	if (![self connected]) {
		[self runsLoadingFailed];
 		return NO;
    }
	
	StativityData * rk = [StativityData get];
	Activity * lastActivity = [rk getLastActivity];
	NSDate * lastActivityDate = nil;
	BOOL isPartial = NO;
	if (lastActivity) {
		isPartial = YES;
		lastActivityDate = lastActivity.start_time;
	}
	
	NSString * token = [self getToken];
	NSString * path = @"http://api.mobile.endomondo.com/mobile/api/workout/list?maxResults=999999999&authToken={token}&language=EN";
	path = [path stringByReplacingOccurrencesOfString: @"{token}" withString: token];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	UIViewController * activeController = [Utilities getActiveViewController];
	HUD = [MBProgressHUD showHUDAddedTo: activeController.view animated:YES];
	HUD.labelText = @"Getting Activities...";
	HUD.mode = MBProgressHUDModeIndeterminate;
	
	int newActivities __block = 0;
	//[request setDelegate: self];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURLRequest * request = [self createURLRequest: path];
			NSURLResponse *response = nil;
			NSError *error = nil;
			NSData *responseData = [NSURLConnection 
				sendSynchronousRequest:request 
				returningResponse:&response 
				error:&error];
			
			if (!error) {
				NSString *rawJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
				SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
				NSDictionary * dict = [jsonParser objectWithString: rawJSON];
				NSMutableArray * items = [[dict objectForKey: @"data"] mutableCopy];
				
				// remove unsupported activities
				for(int i = [items count] -1; i >= 0; i--) {
					NSDictionary * activityDict = [items objectAtIndex: i];
					NSNumber * sport = [activityDict objectForKey: @"sport"];
					NSString * activityType = [Endomondo sportToActivityType: sport];
					if ([activityType isEqualToString: @""]) {
						[items removeObject: activityDict];
					}
				}
				
				if (items) {
					StativityData * data = [StativityData get];
					newActivities = [data saveActivities : [items copy] partial : isPartial ofType : ofType fromSource: @"Endomondo"];
				}
				else {
					newActivities = 0;
				}
				NSNumber * newCount = [NSNumber numberWithInt: newActivities];
				[self performSelectorOnMainThread: @selector(notifyRunsLoaded:) withObject: newCount waitUntilDone: NO];
				
			}
			else{
				NSLog(@" error = %@", error);
				[self performSelectorOnMainThread: @selector(runsLoadingFailed) withObject:nil waitUntilDone:NO];
			}
		
						
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			[MBProgressHUD hideHUDForView: activeController.view animated:YES];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

		});
	});
	
	return newActivities;

}

-(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type {
	StativityData * data = [StativityData get];
	[data removeActivitiesAfter: date ofType: type withContext: nil];
	return [self getFitnessActivities: type];
}

-(NSArray *) getActivityDetail : (NSString *) activityId {
	if (![self connected]) {
		[self runsLoadingFailed];
		NSLog(@"getActivityDetail = not connected");
		return nil;
	}
	
	NSArray * retval = nil;
	NSString * uri = @"http://api.mobile.endomondo.com/mobile/readTrack?authToken={token}&language=EN&trackId={activityId}";
	uri = [uri stringByReplacingOccurrencesOfString: @"{token}" withString: [self getToken]];
	uri = [uri stringByReplacingOccurrencesOfString: @"{activityId}" withString: activityId];
	NSURLRequest * request = [self createURLRequest: uri];
	NSURLResponse * response = nil;
	NSError * error = nil;
	NSData * responseData = [NSURLConnection
		sendSynchronousRequest: request 
		returningResponse: &response 
		error: &error];
	
	if (!error) {
		NSString * raw = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		
		//NSNumber * climb = [NSNumber numberWithInt: 0];
		NSNumber * calories = [NSNumber numberWithInt: 0];
		
		NSMutableArray * detail = [[NSMutableArray alloc] init];
		NSDate * startTime = nil;
		NSArray * rows = [raw componentsSeparatedByString: @"\n"];
		
		NSDateFormatter * df = [[NSDateFormatter alloc] init];
		[df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[df setDateFormat: @"yyyy-MM-dd HH:mm:ss z"];
		[df setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: [NSTimeZone systemTimeZone].secondsFromGMT]];
		double secondsFromGmt = [NSTimeZone systemTimeZone].secondsFromGMT;
		for(int i = 0; i < [rows count] - 1; i++) {
			NSString * row = [rows objectAtIndex: i];
			NSArray * cols = [row componentsSeparatedByString: @";"];
			if (i > 0) { // first line is OK
				if (i == 1) { // second line is summary
					//NSLog(@"%@", cols);
					//NSNumber * seconds = [cols objectAtIndex:7];
					//NSNumber * distanceK = [cols objectAtIndex: 8];
					NSString * time = [cols objectAtIndex: 6];
					startTime = [df dateFromString: time];
					startTime = [startTime dateByAddingTimeInterval: secondsFromGmt];
					calories = [cols objectAtIndex: 9];
					//NSNumber * maxAlt = [cols objectAtIndex: 11];
					//NSNumber * minAlt = [cols objectAtIndex: 12];
					
					//[detail addObject: climb];
					//[detail addObject: calories];
					
				}
				else {
					if ((i > 2) && (i < [rows count] - 2)) {
						NSString * time = [cols objectAtIndex: 0];
						NSNumber * timestamp = [NSNumber numberWithFloat: 0];
						
						if (startTime) {
							NSDate * _curTime = [df dateFromString: time];
							_curTime = [_curTime dateByAddingTimeInterval: secondsFromGmt];
							double ti = [_curTime timeIntervalSinceDate: startTime];
							timestamp = [NSNumber numberWithDouble: ti];
						}
						
						NSNumber * lat = [cols objectAtIndex: 2];
						NSNumber * lng = [cols objectAtIndex: 3];
						NSNumber * km = [cols objectAtIndex: 4];
						NSNumber * meters = [NSNumber numberWithFloat: [km floatValue] * 1000.0];
						NSNumber * elevation = [cols objectAtIndex: 6];
						NSNumber * heartRate = [NSNumber numberWithFloat: 0];
						
						NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
						[dict setValue: meters forKey: @"distance"];
						[dict setValue: timestamp forKey : @"timestamp"];
						[dict setValue: elevation forKey : @"altitude"];
						[dict setValue: lat forKey : @"latitude"];
						[dict setValue: lng forKey : @"longitude"];
						[dict setValue: heartRate forKey: @"heart_rate"];
						
						[detail addObject: [dict copy]];
					}
				}
			}
		}
		
		retval = [detail copy];
		
	}
	else {
		NSLog(@"error = %@", error);
		retval = nil;
	}
	
	return retval;
}

-(NSURLRequest *) createURLRequest : (NSString *) path {
	//NSLog(@"createURLRequest %@", path);
	NSURL * url = [NSURL URLWithString: path];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url];
	return [request copy];
}

-(void) runsLoadingFailed {
	[[NSNotificationCenter defaultCenter] 
		postNotificationName : @"failedLoadingData" 
		object : nil];
	
	if (![self connected]) {
		RunKeeper * rk = [RunKeeper sharedInstance];
		Garmin * g = [Garmin sharedInstance];
		
		if (![rk connected] && ![g connected]) {
			UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: @"Not connected" 
				message: @"You are not connected any Tracker. Tap Setup and make selection in Choose My Tracker section." 
				delegate:nil 
				cancelButtonTitle: @"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}


-(void) notifyRunsLoaded : (NSNumber *) newCount {
	[Flurry logEvent:@"Endomondo Download"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"runsLoaded" object:newCount];
}

@end
