//
//  ActivitySegment.m
//  Stativity
//
//  Created by Igor Nakshin on 30/09/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "ActivitySegment.h"
#import "ActivityFormatter.h"

@implementation ActivitySegment

@dynamic activityId;
@dynamic activityTime;
@dynamic activityType;
@dynamic altitude;
@dynamic altitudeChange;
@dynamic delta;
@dynamic elevationChange;
@dynamic endDistance;
@dynamic heartRate;
@dynamic meters;
@dynamic order;
@dynamic seconds;
@dynamic segmentSeconds;
@dynamic startDistance;
@dynamic title;
@dynamic units;
@dynamic minHeartRate;
@dynamic maxHeartRate;

@synthesize rank;


-(NSString *) getSpeedFormatted {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getSpeedFormatted];
}

-(NSString *) getPaceFormatted {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getPaceFormatted];
}

-(NSString *) getDistanceFormatted {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getDistanceFormatted];
}

-(NSString *) getDurationFormatted {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getDurationFormatted];
}

-(NSString *) getWhenFormatted {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getWhenFormatted];

}

-(NSNumber *) getMinutes {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getMinutes];

}

-(NSNumber *) getMiles {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getMiles];
	
}

-(NSNumber *) getDistanceInUnits {
	ActivityFormatter * fmt = [ActivityFormatter initWithSegment: self];
	return [fmt getDistanceInUnits];

}


@end
