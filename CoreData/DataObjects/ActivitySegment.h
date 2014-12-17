//
//  ActivitySegment.h
//  Stativity
//
//  Created by Igor Nakshin on 30/09/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ActivitySegment : NSManagedObject

@property (nonatomic, retain) NSString * activityId;
@property (nonatomic, retain) NSDate * activityTime;
@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * altitudeChange;
@property (nonatomic, retain) NSNumber * delta;
@property (nonatomic, retain) NSNumber * elevationChange;
@property (nonatomic, retain) NSNumber * endDistance;
@property (nonatomic, retain) NSNumber * heartRate;
@property (nonatomic, retain) NSNumber * meters;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * seconds;
@property (nonatomic, retain) NSNumber * segmentSeconds;
@property (nonatomic, retain) NSNumber * startDistance;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * units;
@property (nonatomic, retain) NSNumber * minHeartRate;
@property (nonatomic, retain) NSNumber * maxHeartRate;

@property (nonatomic, strong) NSNumber * rank;

-(NSString *) getSpeedFormatted;
-(NSString *) getPaceFormatted;
-(NSString *) getDistanceFormatted;
-(NSString *) getDurationFormatted;
-(NSString *) getWhenFormatted;

-(NSNumber *) getMinutes;
-(NSNumber *) getMiles;
-(NSNumber *) getDistanceInUnits;

@end
