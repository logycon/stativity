//
//  Garmin.m
//  Stativity
//
//  Created by Igor Nakshin on 9/1/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "Garmin.h"
#import "RunKeeper.h"
#import "Endomondo.h"
#import "StativityData.h"

@implementation Garmin

Garmin * _garmin;

+(Garmin *) sharedInstance {
	if (!_garmin) {
		_garmin = [[Garmin alloc] init];
	}
	return _garmin;
}

-(BOOL) connected {
	NSString * garminStatus = [[NSUserDefaults standardUserDefaults] objectForKey: @"garminStatus"];
	if (garminStatus && [garminStatus isEqualToString: @"y"]) {
		return YES;
	}
	else {
		return NO;
	}
}

-(void) disconnect {
	[[NSUserDefaults standardUserDefaults] setObject: @"n" forKey: @"garminStatus"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) loginUserToGarmin : (NSString *) email withPassword : (NSString *) password {
	BOOL retval = NO;
	
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
	NSData * responseData;
	NSHTTPURLResponse *response;
	NSError * error;
	NSURL * url = [NSURL URLWithString: @"https://connect.garmin.com/signin"];

	// first phase - get initial cookies
	[request setURL: url];
	
	[NSURLConnection 
		sendSynchronousRequest:request 
		returningResponse:&response 
		error:&error];
	
	NSDictionary * _headers = [response allHeaderFields];
	NSArray * all = [NSHTTPCookie 
		cookiesWithResponseHeaderFields: _headers 
		forURL: [NSURL URLWithString: @"https://connect.garmin.com"]];
			
	//NSLog(@"%d cookies", [all count]);
	
	// save initial cookies
	[[NSHTTPCookieStorage sharedHTTPCookieStorage]
		setCookies: all
		forURL: [NSURL URLWithString: @"https://connect.garmin.com"] 
		mainDocumentURL: nil];
	
	
	// second phase - login
	NSString * postString = @"login=login&login:loginUsernameField={user}&login:password={password}&login:signInButton=Sign+In&login:rememberMe=false&javax.faces.ViewState=j_id1";
 
	postString = [postString stringByReplacingOccurrencesOfString: @"{user}" withString: email];
	postString = [postString stringByReplacingOccurrencesOfString: @"{password}" withString: password];
	postString = [postString stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
	NSData *postData = [postString dataUsingEncoding: NSUTF8StringEncoding ] ; //allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	/*
	request = [[NSMutableURLRequest alloc]
		initWithURL: url
		cachePolicy: NSURLRequestReloadIgnoringCacheData 
		timeoutInterval: 60];*/

	[request setURL: url];
	[request setHTTPBody: postData];
	[request setHTTPMethod: @"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	NSArray * _cookies = [self getCookies];
	[request setAllHTTPHeaderFields: [NSHTTPCookie requestHeaderFieldsWithCookies: _cookies]];

	error = nil;
	response = nil;
	
	responseData = [NSURLConnection 
		sendSynchronousRequest:request 
		returningResponse:&response 
		error:&error];
		
	if (!error) {
		NSString * html = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		html = [html lowercaseString];
		NSRange textRange =[html rangeOfString: @"error"];
		if (textRange.location == NSNotFound) {
			// save cookies to shared storage
			NSDictionary * headers = [response allHeaderFields];
			NSArray * all = [NSHTTPCookie 
				cookiesWithResponseHeaderFields: headers 
				forURL: [NSURL URLWithString: @"garmin.com"]];
			
			NSLog(@"%d cookies", [all count]);
			
			[[NSHTTPCookieStorage sharedHTTPCookieStorage]
				setCookies: all
				forURL: [NSURL URLWithString: @"garmin.com"] 
				mainDocumentURL: nil];
			/*
			for(NSHTTPCookie * cookie in all) {
				NSLog(@"Name: %@ Value: %@, Expires: %@", cookie.name, cookie.value, cookie.expiresDate);
			}*/
			
			retval = YES;
		}
		else {
			NSLog(@"login failed");
			retval = NO;
		}
	}
	return retval;
}

-(NSArray *) getCookies {
	NSArray * cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
		//cookies ]
		//	cookiesForURL: [NSURL URLWithString: @"https://connect.garmin.com"]];
	
	if ([cookiesArray count] > 0) {
		//NSDictionary * headersArray = [NSHTTPCookie requestHeaderFieldsWithCookies: cookiesArray];
		return cookiesArray;
	}
	else {
		return nil;
	}

}

-(NSString *) connectUser:(NSString *)email withPassword:(NSString *)password {
	NSString * retval = @"";
	NSArray * cookies = nil; //[self getCookies];
	if (!cookies) {
		if ([self loginUserToGarmin: email withPassword: password]) {
			[[NSUserDefaults standardUserDefaults] setObject: @"y" forKey: @"garminStatus"];
			[[NSUserDefaults standardUserDefaults] setObject: email forKey : @"garminEmail"];
			[[NSUserDefaults standardUserDefaults] setObject: password forKey: @"garminPassword"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		else {
			retval = @"Incorrect user id or password";
			[[NSUserDefaults standardUserDefaults] setObject: @"n" forKey: @"garminStatus"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
	return retval;
}

-(int) getFitnessActivities : (NSString *) ofType {
	if (![self connected]) {
		[self runsLoadingFailed];
 		return NO;
    }
	
	NSString * email = [[NSUserDefaults standardUserDefaults] objectForKey: @"garminEmail"];
	NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey: @"garminPassword"];
	
	if ([self loginUserToGarmin: email withPassword: password]) {
		NSError * error;
		NSMutableURLRequest * request;
		NSHTTPURLResponse *response = nil;
		
		NSString * s_url = @"https://connect.garmin.com/proxy/activity-search-service-1.2/json/activities";
							
		NSURL * url = [NSURL URLWithString: s_url];
			
		NSArray * cookies = [self getCookies];
		request = [[NSMutableURLRequest alloc]
				initWithURL: url
				cachePolicy: NSURLRequestReloadIgnoringCacheData 
				timeoutInterval: 60];	
		[request setHTTPShouldHandleCookies: YES];
		[request setAllHTTPHeaderFields: [NSHTTPCookie requestHeaderFieldsWithCookies: cookies]];
						
		NSData * responseData = [NSURLConnection 
			sendSynchronousRequest: request
			returningResponse:&response 
			error:&error];
			
		if (!error) {
			NSString * html = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			NSLog(@"%@", html);
		}
		else {
			NSLog(@"error %@", error);
		}
	}
	return 0;
}


// todo
-(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type {
	StativityData * data = [StativityData get];
	[data removeActivitiesAfter: date ofType: type withContext: nil];
	return [self getFitnessActivities: type];
}

// todo
-(NSArray *) getActivityDetail : (NSString *) activityId {
	return nil;
}


-(void) runsLoadingFailed {
	[[NSNotificationCenter defaultCenter] 
		postNotificationName : @"failedLoadingData" 
		object : nil];
	
	if (![self connected]) {
		RunKeeper * rk = [RunKeeper sharedInstance];
		Endomondo * en = [Endomondo sharedInstance];
		
		if (![rk connected] && ![en connected]) {
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
