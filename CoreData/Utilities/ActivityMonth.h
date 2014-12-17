//
//  RunKeeperMonth.h
//  Stativity
//
//  Created by Igor Nakshin on 7/19/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityMonth : NSObject

@property (nonatomic, strong) NSNumber * year;
@property (nonatomic, strong) NSNumber * monthNumber;
@property (nonatomic, strong) NSDate * monthStart;
@property (nonatomic, strong) NSDate * monthEnd;
@property (nonatomic, strong) NSNumber * value;
@property (nonatomic, strong) NSNumber * numberOfActivities;
@property (nonatomic, strong) NSNumber * totalDistance; // m
@property (nonatomic, strong) NSNumber * totalTime; // min
@property (nonatomic, strong) NSNumber * totalCalories; 
@property (nonatomic, strong) NSNumber * yearStart;
@property (nonatomic, strong) NSString * yearMonthStartName;
@property (nonatomic, strong) NSNumber * rank;
@property (nonatomic, strong) NSNumber * order;

+(NSArray *) getMonths;
+(NSArray *) getMonthsBetween : (NSDate *) startDate and : (NSDate *) endDate;
+(NSArray *) getMonthlyStatsForActivityType : (NSString *) activityType;

-(NSString *) getDistanceFormatted;
-(NSString *) getDurationFormatted;
-(NSString *) getWhenFormatted;
-(NSNumber *) getDistanceInUnits;
-(NSNumber *) getMiles;

@end
