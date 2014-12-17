//
//  JSONActivityPathPoint.m
//  Stativity
//
//  Created by Igor Nakshin on 7/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "RunKeeperJSONActivityPathPoint.h"
#import "ActivityDetail.h"

@implementation RunKeeperJSONActivityPathPoint
	
@synthesize timestamp;
@synthesize altitude;
@synthesize longitude;
@synthesize latitude;
@synthesize type; // "start", "end", "gps", "pause", "resume", "manual"

-(NSDictionary *) fromDetail:(ActivityDetail *) detail andType:(NSString *)pointType {
	self.type = pointType;
	self.timestamp = [detail.timestamp copy];
	self.altitude = [detail.altitude copy];
	self.longitude = [detail.longitude copy];
	self.latitude = [detail.latitude copy];
	
	NSMutableDictionary * retval = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	
		self.type, @"type",
		self.timestamp, @"timestamp",
		self.altitude, @"altitude",
		self.longitude, @"longitude",
		self.latitude, @"latitude",
		nil];
	return [retval copy];

}

@end
