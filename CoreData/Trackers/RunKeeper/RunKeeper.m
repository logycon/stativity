//
//  RunKeeper.m
//  RunKeeperTest
//
//  Created by Igor Nakshin on 7/14/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "RunKeeper.h"
#import "SBJson.h"
#import "Me.h"
#import "StativityData.h"
#import "Activity.h"
#import "ActivityDetail.h"
#import "ActivitySegment.h"
#import "ActivityFormatter.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "TargetConditionals.h"
#import "Flurry.h"
#import "RunKeeperJSONActivityPathPoint.h"
#import "RunKeeperJSONActivity.h"
#import "Endomondo.h"
#import "Flurry.h"
#import "Garmin.h"

@implementation RunKeeper

#define kRunKeeperClientID			@"2a977dad8234430b9fb6464ff9172ca9"
#define kRunKeeperClientSecret		@"7d3079faf5dd47138e6887ecbbfb8e57"
#define kRunKeeperAuthorizationUrl	@"https://runkeeper.com/apps/authorize"
#define kRunKeeperTokenUrl			@"https://runkeeper.com/apps/token"
//#define kRunKeeperRedirectUrl		@"rk2a977dad8234430b9fb6464ff9172ca9://oauth2"
#define kRunKeeperAccountType		@"RunKeeper.com"
#define kRunKeeperBasePath			@"https://api.runkeeper.com"

RunKeeper * _runkeeper;
MBProgressHUD *HUD;

+(RunKeeper *) sharedInstance {
	if (!_runkeeper) {
		_runkeeper = [[RunKeeper alloc] init];
	}
	return _runkeeper;
}

-(NSString *) getRedirectURI {
	return [NSString stringWithFormat:@"stativity%@://oauth2", kRunKeeperClientID ];
}

-(void) connect {
/*
Direct the user to the Health Graph API authorization endpoint. Be sure to include the following request parameters:
client_id: The unique identifier that your application received upon registration
response_type: The keyword 'code'
redirect_uri: The page on your site where the Health Graph API should redirect the user after accepting or denying the access request
Optionally, you can also include a state parameter with a URL-safe value that has meaning specific to your application. The authorization endpoint will return this value when responding to your application in step 2 below.

The Health Graph API will inform the user that your application would like access to his/her account and ask whether to allow the request. If the user permits, the Health Graph API will redirect him/her to the redirect_uri that you supplied above with the following parameters:
code: A one-time authorization code that you will need to obtain an access token
state: The value of the state parameter supplied in step 1 (omitted if your application did not supply a state parameter)
*/
	NSString * redirectURI = [self getRedirectURI];
	//NSLog(@"%@", redirectURI);
	NSString  *surl = [NSString stringWithFormat : @"%@?client_id=%@&response_type=%@&redirect_uri=%@",
		kRunKeeperAuthorizationUrl,
		kRunKeeperClientID,
		@"code",
		redirectURI];
		
	NSURL * url = [NSURL URLWithString: [surl stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL: url];
}

-(void) disconnect {
	[self setToken: nil];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"connectedToRK" object:nil];

}

// from application delegate
- (void)handleOpenURL:(NSURL *)url
{
	//NSLog(@"%@", url);
	NSString * redirectUrl = [NSString stringWithFormat:@"stativity%@://oauth2?code=", kRunKeeperClientID];
	NSString * surl = [url absoluteString];
	
	NSString *code = [surl stringByReplacingOccurrencesOfString: redirectUrl withString: @""];
	if (![code isEqualToString: @""]) {
		// get the token
		[self retrieveToken : code];
	}
	else {
		NSLog(@"no code");
	}
}

-(void) retrieveToken : (NSString *) code {
/*
Make a POST request to the Health Graph API token endpoint. 

Include the following parameters in application/x-www-form-urlencoded format:

grant_type: The keyword 'authorization_code'
code: The authorization code returned in step 2
client_id: The unique identifier that your application received upon registration
client_secret: The secret that your application received upon registration
redirect_uri: The exact URL that you supplied when sending the user to the authorization endpoint above

The Health Graph API will respond, in application/json format, with the parameter 'access_token' 
set to a string that uniquely identifies the association of your application to the user's Health Graph/RunKeeper account. 
Include this string as an HTTP "bearer token" or as the 'access_token' parameter in any request that you make to the Health Graph API.

If the user refuses access to his/her account, the Health Graph API will 
respond to the initial authorization request by redirecting the user to the redirect_uri with the parameter 'error' 
set to 'access_denied.' (This response will also include the supplied state parameter, if any.)
*/
	NSString * surl = kRunKeeperTokenUrl;
	surl = [surl stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSURL *aUrl = [NSURL URLWithString: surl];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl];
		
	NSString *postString = [NSString 
		stringWithFormat: @"grant_type=authorization_code&code=%@&client_id=%@&client_secret=%@&redirect_uri=%@",
		code,
		kRunKeeperClientID,
		kRunKeeperClientSecret,
		[self getRedirectURI]];		
		
	postString = [postString stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
	//NSLog(@"%@", postString);	
	NSData *postData = [postString dataUsingEncoding: NSUTF8StringEncoding ] ; //allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
					
	[request setHTTPBody: postData];
	[request setHTTPMethod: @"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSError * error;
	NSURLResponse *response = nil;
	NSData *responseData = [NSURLConnection 
		sendSynchronousRequest:request 
		returningResponse:&response 
		error:&error];
	
	if (!error) {
		NSString *rawJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		//NSLog(@"response : %@",rawJSON);
		SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
		NSDictionary * dict = [jsonParser objectWithString: rawJSON];
		if (dict) {
			//NSString * token_type = [dict objectForKey: @"token_type"];
			NSString * token = [dict objectForKey: @"access_token"];
			if (token) {
				[self setToken: token];
				
				// disconnect Endomondo
				Endomondo * endo = [Endomondo sharedInstance];
				[endo disconnect];

				// disconnect Garmin
				Garmin * garmin = [Garmin sharedInstance];
				[garmin disconnect];
				
				[[[UIAlertView alloc] initWithTitle: @"Success" message: @"Connected!" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
				[[NSNotificationCenter defaultCenter] postNotificationName: @"connectedToRK" object:nil];
			}
			else {
				// something is wrong, not authorized
				[self setToken: @""];
			}
		}
	}
	else {
		NSLog(@"%@", error);
	}
}

-(void) setToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject: token forKey: @"rkToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	//NSLog(@"token set to %@", token);
}

-(NSString *) getToken {
	NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey: @"rkToken"];
	//NSLog(@"%@", token);
	return token;
}

-(BOOL) connected {
	NSString * token = [self getToken];
	BOOL retval =  (token && ![token isEqualToString: @""]);
	if (retval) {	
	}
	else {
		//NSLog(@"is not connected");
	}
	return retval;
}

-(NSURLRequest *) createURLRequest : (NSString *) path {
	//NSLog(@"createURLRequest %@", path);
	NSString * s_url = [NSString stringWithFormat: @"%@%@", kRunKeeperBasePath, path];
	NSURL * url = [NSURL URLWithString: s_url];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url];
	NSString * authorization = [NSString stringWithFormat: @"Bearer %@", [self getToken]];
	[request setValue : authorization forHTTPHeaderField: @"Authorization"];
	return [request copy];
}

/*
POST /fitnessActivities HTTP/1.1
Host: api.runkeeper.com
Authorization: Bearer xxxxxxxxxxxxxxxx
Content-Type: application/vnd.com.runkeeper.NewFitnessActivity+json
Content-Length: nnn

{
   "type": "Running",
   "equipment": "None",
   "start_time": "Sat, 1 Jan 2011 00:00:00",
   "notes": "My first late-night run",
   "path": [
   {
      "timestamp": 0,
      "altitude": 0,
      "longitude": -70.95182336425782,
      "latitude": 42.312620297384676,
      "type": "start"
   },
   {
      "timestamp": 8,
      "altitude": 0,
      "longitude": -70.95255292510987,
      "latitude": 42.31230294498018,
      "type": "end"
   }
   ],
   "post_to_facebook": true,
   "post_to_twitter": true
}
*/
-(void) postNewActivity : (NSString *) activityId {
	NSString * path = @"/fitnessActivities";
	NSString * s_url = [NSString stringWithFormat: @"%@%@", kRunKeeperBasePath, path];
	NSURL * url = [NSURL URLWithString: s_url];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url];
		
	RunKeeperJSONActivity * a = [[RunKeeperJSONActivity alloc] init];
	NSDictionary * dict = [a fromActivity: activityId];
	
	NSString * postString = [dict JSONRepresentation];
	//NSLog(@"%@", postString);
	
	//return;
		
	NSData *postData = [postString dataUsingEncoding: NSUTF8StringEncoding ] ; //allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
					
	[request setHTTPMethod: @"POST"];
	NSString * authorization = [NSString stringWithFormat: @"Bearer %@", [self getToken]];
	[request setValue : authorization forHTTPHeaderField: @"Authorization"];

	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];	
	[request setValue:@"application/vnd.com.runkeeper.NewFitnessActivity+json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody: postData];
	
	NSError * error;
	NSURLResponse *response = nil;
	NSData *responseData = [NSURLConnection 
		sendSynchronousRequest:request 
		returningResponse:&response 
		error:&error];
	
	if (!error) {
		NSString * response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSLog(@"%@", response);
	}
	else {
		NSLog(@"error");
	}
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 99) {
		if (buttonIndex == 0) {
			StativityData * sd = [StativityData get];
			[sd userRemoveAllActivities];
			[self disconnect];
		}
	}
}

// http://www.hbensalem.com/iphone-2/iphone-synchronous-and-asynchronous-json-parse/
-(BOOL) getUserProfile {
	if (![self connected]) {
		[self runsLoadingFailed];
 		return NO;
    }
	
	NSString * path = @"/profile";
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
		if (dict != nil) {
				
			BOOL elite =  [[dict objectForKey: @"elite"] boolValue];
			[Me setElite: elite];
			
			BOOL delete_health = [[dict objectForKey: @"delete_health"] boolValue];
			if (delete_health) {
				UIAlertView * alert = [[UIAlertView alloc]
				   initWithTitle: @"RunKeeper"
				   message: @"You have disconnected Stativity from your RunKeeper Account. RunKeeper data on your device will now be removed."
				   delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
				   alert.tag = 99;
				   [alert show];
				NSLog(@"delete everything");
			}
			
			#if !(TARGET_IPHONE_SIMULATOR)
				
			#endif
			
			return YES;
		}
		else {
			//NSLog(@"Bad response for %@", path);
			return NO;
		}
	}
	else {
		//NSLog(@"Error in getUserProfile %@", error);
		return NO;
	}

}

-(int) getFitnessActivities:(NSString *)ofType {
	if (![self connected]) {
		[self runsLoadingFailed];
 		return NO;
    }
	
	StativityData * rk = [StativityData get];
	Activity * lastActivity = [rk getLastActivity];
	BOOL isPartial = NO;
	NSString * noEarlierThen = @"";
	if (lastActivity) {
		isPartial = YES;
		NSDate * lastActivityDate = lastActivity.start_time;
		NSDateFormatter * df = [[NSDateFormatter alloc] init];
		[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		df.dateFormat = @"YYYY-MM-dd";
		noEarlierThen = [df stringFromDate: lastActivityDate];
	}
	
	NSString * path = @"/fitnessActivities?pageSize=99999999";//98672854";
	
	if (isPartial) {
		path = [path stringByAppendingFormat: @"&noEarlierThan=%@&modifiedNoEarlierThan=%@", noEarlierThen, noEarlierThen];
	}
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
				NSArray * items = [dict objectForKey: @"items"];
				if (items) {
					StativityData * data = [StativityData get];
					newActivities = [data saveActivities : items partial : isPartial ofType : ofType fromSource: @"RunKeeper"];
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
				//[self runsLoadingFailed];
			}
		
						
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			[MBProgressHUD hideHUDForView: activeController.view animated:YES];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

		});
	});
	
	return newActivities;
}


-(void) notifyRunsLoaded : (NSNumber *) newCount {
	[Flurry logEvent: @"RunKeeper Download"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"runsLoaded" object:newCount];
}

-(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type {
	//NSLog(@"getFitnessActivities");
	if (![self connected]) {
		[self runsLoadingFailed];
		//NSLog(@"getFitnessActivities - not connected");
 		return NO;
    }
	
	NSString * noEarlierThen = @"";
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	df.dateFormat = @"YYYY-MM-dd";
	noEarlierThen = [df stringFromDate: date];
	
	NSString * path = @"/fitnessActivities?pageSize=99999999";//98672854";
	path = [path stringByAppendingFormat: @"&noEarlierThan=%@&modifiedNoEarlierThan=%@", noEarlierThen, noEarlierThen];	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	UIViewController * activeController = [Utilities getActiveViewController];
	MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo: activeController.view animated:YES];
	HUD.labelText = @"Getting Activities...";
	HUD.mode = MBProgressHUDModeIndeterminate;

	int newActivities __block = 0;
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
			NSArray * items = [dict objectForKey: @"items"];
			if (items) {
				StativityData * data = [StativityData get];
				// SAVE
				newActivities = [data saveActivities : items partial : YES ofType : type fromSource: @"RunKeeper"];
			}
			else {
				newActivities = 0;
			}
			
			if (error) {
				NSLog(@" error = %@", error);
				[self performSelectorOnMainThread: @selector(runsLoadingFailed) withObject:nil waitUntilDone:NO];
			}
			else { // post notification
				NSNumber * newCount = [NSNumber numberWithInt: newActivities];
				[self performSelectorOnMainThread: @selector(notifyRunsLoaded:) withObject: newCount waitUntilDone: NO];
			}
		}
						
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			[MBProgressHUD hideHUDForView: activeController.view animated:YES];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			

		});
	});
	
	return newActivities;

}

-(NSArray *) getActivityDetail : (NSString *) uri {
	if (![self connected]) {
		[self runsLoadingFailed];
		NSLog(@"getActivityDetail - not connected");
		return nil;
    }
	
	NSArray * retval = nil;
	
	NSURLRequest * request = [self createURLRequest: uri];
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
		NSArray * distances = (NSArray *) [dict objectForKey: @"distance"];
		NSArray * points = (NSArray *) [dict objectForKey: @"path"];
		NSArray * heartRate = (NSArray *) [dict objectForKey: @"heart_rate"];
		BOOL hasPoints = [distances count] == [points count];
		BOOL hasHeartRate = [heartRate count] > 0; //= [distances count] == [heartRate count];
		
		NSNumber * climb = (NSNumber *) [dict objectForKey: @"climb"];
		NSNumber * calories = (NSNumber *) [dict objectForKey: @"total_calories"];
		if (!climb) climb = [NSNumber numberWithInt: 0];
		if (!calories) calories = [NSNumber numberWithInt: 0];
		
		NSMutableArray * detail = [[NSMutableArray alloc] init];
		[detail addObject: climb];
		[detail addObject: calories];
		
		for(int i = 0; i < [distances count]; i++) {
			NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
			NSDictionary * dist = [distances objectAtIndex: i];
			[dict addEntriesFromDictionary: dist];
			if (hasPoints) {
				NSDictionary * point = [points objectAtIndex: i];
				[dict addEntriesFromDictionary: point];
			}
			
			if (hasHeartRate) {
				int lastHR = 0;
				for(int j = 0; j < [heartRate count]; j++) {
					NSDictionary * hr = [heartRate objectAtIndex: j];
					lastHR = [[hr objectForKey: @"heart_rate"] intValue];
					double distTimestamp = [[dist objectForKey: @"timestamp"] doubleValue];
					double hrTimestamp = [[hr objectForKey: @"timestamp"] doubleValue];
					if (distTimestamp == hrTimestamp) {
						[dict addEntriesFromDictionary: hr];
						break;
					}
				}
			}
			[detail addObject: dict];
		}
		
		retval = [detail copy];
	}
	else {
		NSLog(@" error = %@", error);
		retval = nil;
	}
	return retval;
}

-(void) runsLoadingFailed {
	[[NSNotificationCenter defaultCenter] 
		postNotificationName : @"failedLoadingData" 
		object : nil];
	
	if (![self connected]) {
		Endomondo * en = [Endomondo sharedInstance];
		Garmin * garmin = [Garmin sharedInstance];
		
		if (![en connected] && ![garmin connected]) {
			UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: @"Not connected" 
				message: @"You are not connected any Tracker. Tap Setup and make selection in Choose My Tracker section." 
				delegate:nil 
				cancelButtonTitle: @"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}

@end
