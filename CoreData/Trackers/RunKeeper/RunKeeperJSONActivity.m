//
//  JSONActivity.m
//  Stativity
//
//  Created by Igor Nakshin on 7/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "RunKeeperJSONActivity.h"
#import "RunKeeperJSONActivityPathPoint.h"
#import "Activity.h"
#import "ActivityDetail.h"
#import "StativityData.h"
#import "Utilities.h"

@implementation RunKeeperJSONActivity

@synthesize post_to_twitter;
@synthesize post_to_facebook;
@synthesize type;
@synthesize equipment;
@synthesize start_time;
@synthesize notes;
@synthesize path;


-(NSDictionary *) fromActivity:(NSString *)activityId {

	StativityData * rkd = [StativityData get];
	Activity * a = [rkd fetchActivity: activityId];
	
	self.type = [a.type copy];
	self.equipment = @"None";
	self.notes = @"";
	self.post_to_facebook = NO;
	self.post_to_twitter = NO;
	self.start_time = [a.start_time copy];
	
	self.path = [[NSMutableArray alloc] init];
	NSArray * details = [rkd fetchActivityDetail: activityId];
	for(int i = 0; i < [details count]; i++) {
		ActivityDetail * d = [details objectAtIndex:i];
		NSString * t = @"gps";
		if (i == 0) t = @"start";
		if (i == [details count] - 1) t = @"end";
		
		RunKeeperJSONActivityPathPoint * pt = [[RunKeeperJSONActivityPathPoint alloc] init];
		NSDictionary * dict = [pt fromDetail: d andType: t];
		
		[self.path addObject: dict];
	}
	
	
	NSString * started = [Utilities getDateAsString: a.start_time  
		withFormat: @"EEE, d MMM yyyy hh:mm:ss a"];
	
	NSMutableDictionary * retval = nil;
	if ([self.path count] > 0) {
		retval = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			self.type, @"type",
			self.equipment, @"equipment",
			self.notes, @"notes",
			@"false" , @"post_to_facebook",
			@"false" , @"post_to_twitter",
			started, @"start_time",
			self.path, @"path",
			nil];
	}
	else {
		retval = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			self.type, @"type",
			self.equipment, @"equipment",
			self.notes, @"notes",
			@"false" , @"post_to_facebook",
			@"false" , @"post_to_twitter",
			started, @"start_time",
			a.total_distance, @"total_distance",
			a.duration, @"duration",
			nil];
	}
	
	return [retval copy];
	
}


@end
