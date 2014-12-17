//
//  ActivityFormatter.h
//  Stativity
//
//  Created by Igor Nakshin on 6/30/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Activity.h"
#import "ActivitySegment.h"

@interface ActivityFormatter : NSObject

@property (nonatomic, strong) NSString * activityId;
@property (nonatomic, strong) NSNumber * distance; // meters
@property (nonatomic, strong) NSNumber * duration; // seconds
@property (nonatomic, strong) NSNumber * calories;
@property (nonatomic, strong) NSDate * start_time;
@property (nonatomic, strong) NSNumber * segmentDuration;

+(ActivityFormatter *) initWithRun : (Activity *) run;
+(ActivityFormatter *) initWithSegment : (ActivitySegment *) segment;
+(ActivityFormatter *) initWithDuration : (NSNumber *) duration andDistance : (NSNumber *) distance;

-(NSString *) getSpeedFormatted;
-(NSString *) getPaceFormatted;
-(NSString *) getDistanceFormatted;
-(NSString *) getDurationFormatted;
-(NSString *) getSegmentDurationFormatted;
-(NSString *) getDurationFormattedVeryShort;
-(NSString *) getSegmentDurationFormattedVeryShort;
-(NSString *) getDistanceFormattedShort;
-(NSString *) getDurationFormattedShort;
-(NSString *) getSegmentDurationFormattedShort;
-(NSString *) getWhenFormatted;
-(NSString *) getWhenFormattedShort;
-(NSString *) getCommonDistance;

-(NSNumber *) getSpeed;
-(NSNumber *) getPace;
-(NSNumber *) getMinutes;
-(NSNumber *) getHours;
-(NSNumber *) getMiles;
-(NSNumber *) getKms;
-(NSNumber *) getDistanceInUnits;

@end
