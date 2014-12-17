//
//  RunKeeperWeek.h
//  Stativity
//
//  Created by Igor Nakshin on 7/12/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityWeek : NSObject

@property (nonatomic, strong) NSNumber * year;
@property (nonatomic, strong) NSNumber * weekNumber;
@property (nonatomic, strong) NSDate * weekStart;
@property (nonatomic, strong) NSDate * weekEnd;
@property (nonatomic, strong) NSNumber * value;
@property (nonatomic, strong) NSNumber * numberOfActivities;
@property (nonatomic, strong) NSNumber * totalDistance; // m
@property (nonatomic, strong) NSNumber * totalTime; // min
@property (nonatomic, strong) NSNumber * totalCalories; 
@property (nonatomic, strong) NSNumber * yearStart;
@property (nonatomic, strong) NSNumber * monthStart;
@property (nonatomic, strong) NSString * yearMonthStartName;
@property (nonatomic, strong) NSNumber * rank;
@property (nonatomic, strong) NSNumber * order;

+(NSArray *) getWeeks;
+(NSArray *) getWeeksBetween : (NSDate *) startDate and : (NSDate *) endDate;
+(NSArray *) getWeeklyStatsForActivityType : (NSString *) activityType;

-(NSString *) getDistanceFormatted;
-(NSString *) getDurationFormatted;
-(NSString *) getWhenFormatted;
-(NSNumber *) getDistanceInUnits;
-(NSNumber *) getMiles;

@end
