//
//  DashboardItemFormatter.h
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DashboardItem.h"
#import "ActivityFormatter.h"

@interface DashboardItemFormatter : NSObject

// dashboard items : code - displayName
// d_longest - Longest activity (distance)
// t_longest - Longest activity (time)
// s_1k - fastest 1k (segment)
// s_1m - fastest 1m
// s_5k - fastest 5k
// s_3m - fastest 3m
// s_5m - fastest 5m
// s_10k - fastest 10k
// s_10m - fastest 10m
// s_h - fastest half
// s_f - fastest full 


// metadata
@property (nonatomic, strong) NSString * activityType;	// Running, Cycling, Walking
@property (nonatomic, strong) NSString * displayName;	//
@property (nonatomic, strong) NSString * itemCategory;  // Speed, Duration, Time
@property (nonatomic, strong) NSString * itemCode;		// 
@property (nonatomic, strong) NSNumber * itemOrder;     // order in the view
@property (nonatomic, strong) NSNumber * userSelected;  // y or n 
@property (nonatomic, strong) NSNumber * defaultOrder;

@property (nonatomic, strong) ActivityFormatter * periodActivity;
@property (nonatomic, strong) ActivityFormatter * allTimeActivity;


+(NSArray *) createItems;
-(DashboardItemFormatter *) initWithItem : (DashboardItem *) item;
-(void) loadForPeriod : (NSDate *) starting andEnding : (NSDate *) ending;

-(NSString *) getPeriodResult;
-(NSString *) getPeriodPace;
-(NSString *) getPeriodSpeed;
-(NSString *) getPeriodResultShort;
-(NSString *) getPeriodResultVeryShort;
-(NSString *) getPeriodWhen;
-(NSString *) getPRResult;
-(NSString *) getPRWhen;
-(NSString *) getAllTimeResult;
-(NSString *) getPeriodAgo;



@end
