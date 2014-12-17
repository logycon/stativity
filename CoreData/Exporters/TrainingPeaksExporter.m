//
//  TrainingPeaksExporter.m
//  Stativity
//
//  Created by Igor Nakshin on 10/30/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "TrainingPeaksExporter.h"
#import "Activity.h"
#import "ActivityDetail.h"
#import "StativityData.h"

@implementation TrainingPeaksExporter

-(void) sendActivityWithID:(NSString *)activityId {
	StativityData * data = [StativityData get];
	Activity * activity = [data fetchActivity: activityId];
	NSArray * details = [data fetchActivityDetail: activityId];
	
	NSString * xml = @""; //@"<?xml version=\"1.0\"?>";
	xml = [xml stringByAppendingString: @"<pwx xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" version=\"1.0\" xmlns=\"http://www.peaksware.com/PWX/1/0\">"];
	xml = [xml stringByAppendingString: @"<workout>"];
	xml = [xml stringByAppendingString: @"	<sportType>Run</sportType>"];
	xml = [xml stringByAppendingString: @"	<cmt>Exported from Stativity</cmt>"];
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
	[df setDateFormat: @"YYYY-MM-dd"];
	NSString * date = [df stringFromDate: activity.start_time];
	[df setDateFormat: @"HH:mm:ss"];
	NSString * time = [df stringFromDate: activity.start_time];
	xml = [xml stringByAppendingFormat: @"<time>%@T%@</time>", date, time];
	xml = [xml stringByAppendingString: @"<summarydata>"];
	xml = [xml stringByAppendingString: @"  <beginning>0</beginning>"];
	xml = [xml stringByAppendingFormat: @"  <duration>%@</duration>", activity.duration];
	//xml = [xml stringByAppendingFormat: @"	<work>0</work>"];
	xml = [xml stringByAppendingFormat: @"  <dist>%@</dist>", activity.total_distance];
	xml = [xml stringByAppendingString: @"</summarydata>"];
	
	for(int i = 0; i < [details count]; i++) {
		ActivityDetail * detail = [details objectAtIndex: i];
		xml = [xml stringByAppendingString: @"<sample>"];
		xml = [xml stringByAppendingFormat: @"  <timeofset>%@</timeoffset>", detail.timestamp];
		xml = [xml stringByAppendingFormat: @"  <hr>%@</hr>", detail.heartRate];
		xml = [xml stringByAppendingFormat: @"  <dist>%@</dist>", detail.distance];
		xml = [xml stringByAppendingFormat: @"  <lat>%@</lat>", detail.latitude];
		xml = [xml stringByAppendingFormat: @"  <lon>%@</lon>", detail.longitude];
		xml = [xml stringByAppendingFormat: @"  <alt>%@</alt>", detail.altitude];
		xml = [xml stringByAppendingString: @"</sample>"];
	}
	
	xml = [xml stringByAppendingString: @"</workout>"];
	xml = [xml stringByAppendingString: @"</pwx>"];
	
	NSURL * url = [NSURL URLWithString: @"http://www.trainingpeaks.com/tpwebservices/service.asmx?op=ImportFileForUserV2"];
	//NSString * surl = @"https://www.trainingpeaks.com/TPWebServices/EasyFileUpload.ashx?username=kgu87&password=pass";
	//surl = [surl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	//NSURL * url = [NSURL URLWithString: surl];
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url];
	
	NSString * postString = @"username=kgu87&password=pass&byteData=";
	postString = [postString stringByAppendingString: xml];
	//NSString * postString = xml;
	//NSData *postData = [postString dataUsingEncoding: NSUTF8StringEncoding ] ; //allowLossyConversion:YES];
	NSData * postData = [postString dataUsingEncoding: NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	[request setHTTPMethod: @"POST"];
					     
	[request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	//[request setHTTPBody: postData];

	NSError * error;
	NSURLResponse *response = nil;
	NSData *responseData = [NSURLConnection 
		sendSynchronousRequest:request 
		returningResponse:&response 
		error:&error];
		
	NSString * strResponse = @"";
	if (!error) {
		strResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSLog(@"%@", strResponse);
	}
	else {
		NSLog(@"error");
	}
}

@end
