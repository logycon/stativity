//
//  Activity.h
//  Stativity
//
//  Created by Igor Nakshin on 30/09/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Activity : NSManagedObject

@property (nonatomic, retain) NSNumber * averageGrade;
@property (nonatomic, retain) NSNumber * avgAltitude;
@property (nonatomic, retain) NSNumber * climb;
@property (nonatomic, retain) NSNumber * detailCount;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * heartRate;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * maxAltitude;
@property (nonatomic, retain) NSNumber * minAltitude;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * start_time;
@property (nonatomic, retain) NSNumber * stdevAltitude;
@property (nonatomic, retain) NSNumber * total_calories;
@property (nonatomic, retain) NSNumber * total_distance;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSNumber * minHeartRate;
@property (nonatomic, retain) NSNumber * maxHeartRate;

@property (nonatomic, retain) NSNumber * daysFromNow;
@property (nonatomic, retain) NSNumber * weeksFromNow;
@property (nonatomic, retain) NSNumber * monthsFromNow;
@property (nonatomic, retain) NSNumber * yearsFromNow;

-(void) fromDict : (NSDictionary *) rd;
-(void) fromEndomondoDict : (NSDictionary *) rd;
-(void) updateTimeComponents;

-(NSString *) getSpeedFormatted;
-(NSString *) getPaceFormatted;
-(NSString *) getDistanceFormatted;
-(NSString *) getDurationFormatted;
-(NSString *) getWhenFormatted;

-(NSNumber *) getMinutes;
-(NSNumber *) getMiles;
-(NSNumber *) getDistanceInUnits;

-(NSString *) getCommonDistance;

@end
