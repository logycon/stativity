//
//  ActivityDetail.m
//  Stativity
//
//  Created by Igor Nakshin on 8/9/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "ActivityDetail.h"


@implementation ActivityDetail

@dynamic activityId;
@dynamic altitude;
@dynamic distance;
@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;
@dynamic heartRate;

-(void) fromDict:(NSDictionary *)dict {
	self.distance = [NSNumber numberWithFloat: [[dict objectForKey: @"distance"] floatValue]];
	self.timestamp = [NSNumber numberWithFloat: [[dict objectForKey: @"timestamp"] floatValue]];
	self.altitude = [NSNumber numberWithFloat: [[dict objectForKey: @"altitude"] floatValue]];
	self.longitude = [NSNumber numberWithFloat: [[dict objectForKey: @"longitude"] floatValue]];
	self.latitude = [NSNumber numberWithFloat: [[dict objectForKey: @"latitude"] floatValue]];
	self.heartRate = [NSNumber numberWithFloat: [[dict objectForKey: @"heart_rate"] floatValue]];
	
	if (!self.altitude) self.altitude = 0;
	if (!self.longitude) self.longitude = 0;
	if (!self.latitude) self.latitude = 0;
	if (!self.heartRate) self.heartRate = 0;
}

@end
