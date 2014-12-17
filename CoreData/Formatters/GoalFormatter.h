//
//  GoalFormatter.h
//  Stativity
//
//  Created by Igor Nakshin on 7/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Goal.h"
#import "StativityData.h"
#import "Activity.h"
#import "ActivitySegment.h"


@interface GoalFormatter : NSObject

@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSNumber * goalDuration;
@property (nonatomic, retain) NSNumber * goalDistance;
@property (nonatomic, retain) NSString * goalUnits;
@property (nonatomic, retain) NSNumber * goalMeters;
@property (nonatomic, retain) NSString * bestActivityId;

@property (nonatomic, retain) Activity * bestActivity;
@property (nonatomic, retain) NSDate * bestStartTime;

+(GoalFormatter *) initWithGoal : (Goal *) goal;

-(Activity *) getActivityToBeat;
-(ActivitySegment *) getSegmentToBeat;

-(NSString *) getDistanceFormatted;
-(NSString *) getDurationFormatted;
-(NSString *) getSpeedFormatted;
-(NSString *) getPaceFormatted;

-(NSNumber *) getSpeed;
-(NSNumber *) getPace;
-(NSNumber *) getMinutes;
-(NSNumber *) getHours;
-(NSNumber *) getMiles;
-(NSNumber *) getDistanceInUnits;

@end
